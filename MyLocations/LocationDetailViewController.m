//
//  LocationDetailViewController.m
//  MyLocations
//
//  Created by  Jierism on 16/8/9.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location.h"
#import "Location+CoreDataProperties.h"
#import "NSMutableString+AddText.h"


@interface LocationDetailViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;


@end

@implementation LocationDetailViewController
{
    NSString *_descriptionText;
    NSString *_categortName;
    NSDate *_date;
    UIImage *_image;
    UIActionSheet *_actionSheet;
    UIImagePickerController *_imagePicker;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _descriptionText = @"";
        _categortName = @"No Category";
        _date = [NSDate date];
        
        // 当应用进入后天时调用的方法
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground
{
    if (_imagePicker != nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
    if (_actionSheet != nil) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
        _actionSheet = nil;
    }
    [self.descriptionTextView resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置界面
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.descriptionTextView.backgroundColor = [UIColor blackColor];
    self.photoLabel.textColor = [UIColor whiteColor];
    self.photoLabel.highlightedTextColor = self.photoLabel.textColor;
    self.addressLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    self.addressLabel.highlightedTextColor = self.addressLabel.textColor;
    
    if (self.locationToEdit != nil) {
        self.title = @"编辑地址";
    }
    
    if ([self.locationToEdit hasPhoto]) {
        UIImage *existingImage = [self.locationToEdit photoImage];
        if (existingImage != nil) {
            [self showImage:existingImage];
        }
    }
    
    self.descriptionTextView.text = _descriptionText;
    self.descriptionTextView.text = @"";
    self.categoryLabel.text = _categortName;
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.longitude];
    
    if (self.placemark != nil) {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
        
    }else{
        self.addressLabel.text = @"NO Address Found";
    }
    self.dateLabel.text = [self formatDate:_date];
    
    // 触碰界面其他位置时关闭虚拟键盘
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)showImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
   self.imageView.frame = CGRectMake(10, 10, 260, 260);
    //NSLog(@"%@",self.imageView.frame);
    self.photoLabel.hidden = YES;
}


- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath !=nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    [self.descriptionTextView resignFirstResponder];
}

- (void)setLocationToEdit:(Location *)newlocationToEdit
{
    if (_locationToEdit != newlocationToEdit) {
        _locationToEdit = newlocationToEdit;
        
        _descriptionText = _locationToEdit.locationDescription;
        _categortName = _locationToEdit.category;
        _date = _locationToEdit.date;
        
        self.coordinate = CLLocationCoordinate2DMake(
                                                     [_locationToEdit.latitude doubleValue],
                                                     [_locationToEdit.longtitude doubleValue]);
        
        self.placemark = _locationToEdit.placemark;
    }
}

// 反编码地址格式
- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark
{
    NSMutableString *line = [NSMutableString stringWithCapacity:100];
    [line addText:placemark.subThoroughfare withSeparator:@""];
    [line addText:placemark.thoroughfare withSeparator:@" "];
    [line addText:placemark.locality withSeparator:@", "];
    [line addText:placemark.administrativeArea withSeparator:@", "];
    [line addText:placemark.postalCode withSeparator:@" "];
    [line addText:placemark.country withSeparator:@", "];
    return line;
}

- (NSString *)formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil;
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return  [formatter stringFromDate:theDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self closeScreen];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCategory"]) {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.selectedCategoryName = _categortName;
    }
}

// 选中并退出
- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue
{
    CategoryPickerViewController *viewController = segue.sourceViewController;
    _categortName = viewController.selectedCategoryName;
    self.categoryLabel.text = _categortName;
}



- (IBAction)done:(id)sender {
    
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    
    Location *location = nil;
    if (self.locationToEdit != nil) {
        hudView.text = @"Updated";
        location = self.locationToEdit;
    }else{
        hudView.text = @"Tagged";
        
        // 将数据放到Core Data中
        // 1
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        location.photoId = @-1;
    }

    // 2
    location.locationDescription = _descriptionText;
    location.category = _categortName;
    location.latitude = @(self.coordinate.latitude); // 用@()方式将经度纬度信息转换成NSNumber对象
    location.longtitude = @(self.coordinate.longitude);
    location.date = _date;
    location.placemark = self.placemark;
    // 保存图片
    if (_image != nil) {
        // 1
        if (![location hasPhoto]) {
            location.photoId = @([Location nextPhotoId]);
        }
        
        // 2
        NSData *data = UIImageJPEGRepresentation(_image, 0.5);
        NSError *error;
        if (![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error writing file:%@",error);
        }
    }
    
    // 3 将context的内容保存到数据存储
    NSError *error;
    if (![self.managedObjectContext save:&error]) {// 如果发生错误，save：方法会返回NO，调用abort方法终止程序
//        NSLog(@"Error:%@",error);
//        abort();
        FATAL_CORE_DATA_ERROR(error);// 先弹出alert信息，用户取消后再终止程序
        return;
    }
    
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
}

- (void)closeScreen
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
    }else if (indexPath.section == 1){
        if (self.imageView.hidden) {
            return 44;
        }else{
            return 280;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 2){
        CGRect rect = CGRectMake(100, 10, 205, 10000);
        // 设置frame适应205points的宽度，可以让文本自动换行
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return  self.addressLabel.frame.size.height + 20;
    }else{
        return 44;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    _descriptionText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _descriptionText = textView.text;
}

// 当用户触碰第一个cell的任何位置时，应用应自动激活text view，即便触碰的对象不是text view本身，优化用户体验。
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    }else if (indexPath.section == 1 && indexPath.row == 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showPhotoMenu]; // 添加照片
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    cell.selectedBackgroundView = selectionView;
    if (indexPath.row == 2) {
        UILabel *addressLabel = (UILabel *)[cell viewWithTag:100];
        addressLabel.textColor = [UIColor whiteColor];
        addressLabel.highlightedTextColor = addressLabel.textColor;
    }
}

#pragma mark - 选择照片有关方法

- (void)takePhoto
{
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.view.tintColor = self.view.tintColor;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:nil];
    
}

// 从相册里选择照片
- (void)choosePhotoFromLibrary
{
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.view.tintColor = self.view.tintColor;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:nil];

}

- (void)showPhotoMenu
{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take Photo",@"Choose From Library", nil];
        
        [_actionSheet showInView:self.view];
    }else{
        [self choosePhotoFromLibrary];
    }
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    _image = info[UIImagePickerControllerEditedImage];
    [self showImage:_image];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhoto];
    }else if (buttonIndex == 1){
        [self choosePhotoFromLibrary];
    }
    _actionSheet = nil;
}

@end
