//
//  FirstViewController.m
//  MyLocations
//
//  Created by  Jierism on 16/8/6.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailViewController.h"
#import "NSMutableString+AddText.h"
#import <AudioToolbox/AudioServices.h>

@interface CurrentLocationViewController ()<UITabBarControllerDelegate>


@end

@implementation CurrentLocationViewController{
    // 获取地理位置有关的实例变量
    CLLocationManager *_locationManager;
    CLLocation *_location; // 用于显示坐标信息
    BOOL _updatingLocation;
    NSError *_lastLocationError; // 错误信息
    
    // 进行地理编码有关的实例变量
    CLGeocoder *_geocoder;  // 地理编码
    CLPlacemark *_placemark;    // 地址结果
    BOOL _performingReverseGeocoding;
    NSError *_lastGeocodingError;
    
    UIButton *_logoButton;
    BOOL _logoVisible;
    
    UIActivityIndicatorView *_spinner;
    
    SystemSoundID _soundID; // 添加声音
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.translucent = NO;
    [self loadSoundEffect];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateLabels];
    [self configureGetButton];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestWhenInUseAuthorization];
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}




// 用Core Location来接收信息
- (IBAction)getLocation:(id)sender {
    
    if (_logoVisible) {
        [self hideLogoView];
    }
    
    if (_updatingLocation) {
        [self stopLocationManager];
    }else{
        _location = nil;
        _lastLocationError = nil;
        _placemark = nil;
        _lastGeocodingError = nil;
        
        [self startLocationManager];
    }
    
    [self updateLabels];
    [self configureGetButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailViewController *controller = (LocationDetailViewController *)navigationController.topViewController;
        
        controller.coordinate = _location.coordinate;
        controller.placemark = _placemark;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark -CLLocationManagerDelegate
// 获取地理信息错误时，显示错误信息
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败：%@",error);
    // 表示目前location manager无法获取一个位置信息
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    // 若出现更严重的错误则执行下面代码
    [self stopLocationManager];
    _lastLocationError = error;
    
    [self updateLabels];
    [self configureGetButton];
    
}


// 将地理信息存储在一个数组
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = [locations lastObject]; // 取出数组最后一个值，即最新的值
    NSLog(@"已更新坐标，当前位置：%@",newLocation);
    
    // 如果获取最近一个位置信息对象的时间大于5s，那么它就是一个所谓的缓存结果，对我们无用
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    // 使用位置信息对象的horizontalAccuracy属性来判断的结果是否比之前的结果更为准确。
    // 如果这个属性变量值小于0，说明测量结果无效，将其忽略
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    if (_location != nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    // 判断是否第一次获取位置信息 || 更大的horizontalAccuracy值意味着精度更低，最新的位置信息的精度要高
    if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            NSLog(@"成功完成定位");
            [self stopLocationManager];
            [self configureGetButton];
        }
        
        if (distance > 0) {
            _performingReverseGeocoding = NO;
        }
        
        if (!_performingReverseGeocoding) {
            NSLog(@"Going to geoccode");
            _performingReverseGeocoding = YES;
            
            [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                NSLog(@"*** Found placemarks:%@,error:%@",placemarks,error);
                
                // 这里采取了防御性编程
                _lastGeocodingError = error;
                if (error == nil && [placemarks count] > 0) {
                    if (_placemark == nil) {
                        NSLog(@"FIRST TIME!");
                        [self playSoundEffect];
                    }
                    _placemark = [placemarks lastObject];
                }else{
                    _placemark = nil;
                }
                
                _performingReverseGeocoding = NO;
                [self updateLabels];
            }];
            
        }
    }else if (distance <1.0){// 如果当前读数的坐标和前一个读数没有明显差异, 且从收到前一个读数到现在已经超过10秒了, 那么是时候停手了。此时我们可以假定已经不可能获得更精确的位置信息,因此停止继续获取位置信息的努力。
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        if (timeInterval > 10) {
            NSLog(@"*** 强制完成！ ");
            [self stopLocationManager];
            [self updateLabels];
            [self configureGetButton];
        }
    }
    
    
}

// 把地理信息显示在标签上
- (void)updateLabels
{
    if (_location != nil) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",_location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f",_location.coordinate.longitude];
        self.tagButton.hidden = NO;
        self.messageLabel.text = @"";
        self.latitudeTextLabel.hidden = NO;
        self.longitudeTextLabel.hidden = NO;
        
        if (_placemark != nil) {
            self.addressLabel.text = [self stringFromPlacemark:_placemark];
        }else if (_performingReverseGeocoding){
            self.addressLabel.text = @"寻找中...";
        }else if (_lastGeocodingError != nil){
            self.addressLabel.text = @"寻找错误！！！";
        }else{
            self.addressLabel.text = @"啥都没找到";
        }
        
    }else{
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
        self.latitudeTextLabel.hidden = YES;
        self.longitudeTextLabel.hidden = YES;

        
        NSString *statusMessage;
        if (_lastLocationError != nil) {
            if ([_lastLocationError.domain isEqualToString:kCLErrorDomain] && _lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"对不起，用户禁用了定位功能";
            }else{
                statusMessage = @"对不起，获取位置信息错误";
            }
        }else if (![CLLocationManager locationServicesEnabled]){
            statusMessage = @"对不起，用户禁用了定位功能";
        }else if (_updatingLocation){
            statusMessage = @"定位中...";
        }else{
            statusMessage = @"";
            [self showLogoView];
        }
        self.messageLabel.text = statusMessage;
    }
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 设置范围
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        // 超过1分钟没有找到位置信息，则停止location manager并发送一个错误
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}


- (void)stopLocationManager
{
    if (_updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

- (void)didTimeOut:(id)obj
{
    NSLog(@"*** oops，超时了");
    if (_location == nil) {
        [self stopLocationManager];
        _lastLocationError = [NSError errorWithDomain:@"MyLocationErrorDomain" code:1 userInfo:nil];
        [self updateLabels];
        [self configureGetButton];
    }
}

- (void)configureGetButton
{
    if (_updatingLocation) {
        [self.getButton setTitle:@"停止定位" forState:UIControlStateNormal];
        
        if (_spinner == nil) {
            _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            _spinner.center = CGPointMake(self.messageLabel.center.x, self.messageLabel.center.y + _spinner.bounds.size.height / 2.0f + 15.0f);
            [_spinner startAnimating];
            [self.containerView addSubview:_spinner];
        }
    }else{
        [self.getButton setTitle:@"获取当前所在位置" forState:UIControlStateNormal];
        
        [_spinner removeFromSuperview];
        _spinner = nil;
    }
}

// 生成地址信息
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    NSMutableString *line1 = [NSMutableString stringWithCapacity:100];
    [line1 addText:thePlacemark.subThoroughfare withSeparator:@""];
    [line1 addText:thePlacemark.thoroughfare withSeparator:@" "];
    
    NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
    [line2 addText:thePlacemark.locality withSeparator:@""];
    [line2 addText:thePlacemark.administrativeArea withSeparator:@" "];
    
    if ([line1 length] == 0) {
        [line2 appendString:@"\n "];
        return line2;
    }else{
        [line1 appendString:@"\n"];
        [line1 appendString:line2];
        return line1;
    }
    
}


#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    tabBarController.tabBar.translucent = (viewController != self);
    return YES;
}

#pragma mark - Logo View
- (void)showLogoView
{
    if (_logoVisible) {
        return;
    }
    
    _logoVisible = YES;
    self.containerView.hidden = YES;
    
    _logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_logoButton setBackgroundImage:[UIImage imageNamed:@"Logo"] forState:UIControlStateNormal];
    [_logoButton sizeToFit];
    [_logoButton addTarget:self action:@selector(getLocation:) forControlEvents:UIControlEventTouchUpInside];
    _logoButton.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f - 49.0f);
    [self.view addSubview:_logoButton];
}

- (void)hideLogoView
{
    if (!_logoVisible) {
        return;
    }
    _logoVisible = NO;
    self.containerView.hidden = NO;
    
    // logo移动
    self.containerView.center = CGPointMake(self.view.bounds.size.width * 2.0f, 40.0f + self.containerView.bounds.size.height / 2.0f);
    CABasicAnimation *panelMover = [CABasicAnimation animationWithKeyPath:@"position"];
    panelMover.removedOnCompletion = NO;
    panelMover.fillMode = kCAFillModeForwards;
    panelMover.duration = 0.6;
    
    panelMover.fromValue = [NSValue valueWithCGPoint:self.containerView.center];
    panelMover.toValue = [NSValue valueWithCGPoint:CGPointMake(160.0f, self.containerView.center.y)];
    panelMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    panelMover.delegate = self;
    [self.containerView.layer addAnimation:panelMover forKey:@"panelMover"];
    
    CABasicAnimation *logoMover = [CABasicAnimation animationWithKeyPath:@"position"];
    logoMover.removedOnCompletion = NO;
    logoMover.fillMode = kCAFillModeForwards;
    logoMover.duration = 0.5;
    logoMover.toValue = [NSValue valueWithCGPoint:CGPointMake(-160.0f, _logoButton.center.y)];
    logoMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_logoButton.layer addAnimation:logoMover forKey:@"logoMover"];
    
    CABasicAnimation *logoRotator = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    logoRotator.removedOnCompletion = NO;
    logoRotator.fillMode = kCAFillModeForwards;
    logoRotator.duration = 0.5;
    logoRotator.fromValue = @0.0f;
    logoRotator.toValue = @(-2.0f * M_PI);
    logoRotator.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_logoButton.layer addAnimation:logoRotator forKey:@"logoRotator"];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.containerView.layer removeAllAnimations];
    self.containerView.center = CGPointMake(self.view.bounds.size.width / 2.0f, 40.0f + self.containerView.bounds.size.height / 2.0f);
    [_logoButton.layer removeAllAnimations];
    [_logoButton removeFromSuperview];
    _logoButton = nil;
}

#pragma mark - Sound Effect
- (void) loadSoundEffect
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Sound.caf" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    if (fileURL == nil) {
        NSLog(@"NSURL is nil for path: %@",path);
        return;
    }
    
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &_soundID);
    if (error != kAudioServicesNoError) {
        NSLog(@"Error code %ld loading sound ai path: %@",error,path);
        return;
    }
}

- (void)unloadSoundEffect
{
    AudioServicesDisposeSystemSoundID(_soundID);
    _soundID = 0;
}

- (void)playSoundEffect
{
    AudioServicesPlaySystemSound(_soundID);
}

@end
