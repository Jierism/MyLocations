//
//  AppDelegate.m
//  MyLocations
//
//  Created by  Jierism on 16/8/6.
//  Copyright © 2016年  Jierism. All rights reserved.
//


#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "CurrentLocationViewController.h"
#import "LocationsViewController.h"
#import "MapViewController.h"

NSString * const ManagedObjectContextSaveDidFailNotification =  @"ManagedObjectContextSaveDidFailNotification";

@interface AppDelegate ()<UIAlertViewDelegate>

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self customizeAppearance];
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    CurrentLocationViewController *currentLocationViewController = (CurrentLocationViewController *)tabBarController.viewControllers[0];
    
    // 调用managedObjectContext的getter方法，懒加载，初始化Core Data堆
    currentLocationViewController.managedObjectContext = self.managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fatalCoreDataError:) name:ManagedObjectContextSaveDidFailNotification object:nil];
    
    UINavigationController *navigationController = (UINavigationController *)tabBarController.viewControllers[1];
    LocationsViewController *locationsViewController = (LocationsViewController *)navigationController.viewControllers[0];
    locationsViewController.managedObjectContext = self.managedObjectContext;
    
    MapViewController *mapViewController = (MapViewController *)tabBarController.viewControllers[2];
    mapViewController.managedObjectContext = self.managedObjectContext;
    
    return YES;
}

- (void)fatalCoreDataError:(NSNotificationCenter *)notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Internal Error", nil) message:NSLocalizedString(@"There was a fatal error in the app it cannot continue.\n\nPress OK to terminate the app.Sorry for the inconveninence.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alertView show];
}

// 修改外观
- (void)customizeAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],}];
    [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -Core Data
// 以下代码用于加载之前所定义的数据模型，并连接到一个SQLite数据存储中。
// 实际上任何采用Core Data的应用，以下代码的内容都是相同的。
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return documentsDirectory;
}

- (NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}


// 1、懒加载，在需要的时候创建Context对象。
-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        // 2、懒加载persistentStoreCoordinator，处理SQLite数据存储的对象
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

// 3、访问sel.managedObjectModel，懒加载数据模型，完成后就可以使用Core Data了！
// 仅仅通过使用self.managedObjectContext属性，我们就设置了一个事件链，初始化整个Core Data堆，这就是懒加载的威力
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                       initWithManagedObjectModel:self.managedObjectModel];
        NSError *error;
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Error adding persistent store %@,%@",error,[error userInfo]);
            
            abort();
        }
    }
    return _persistentStoreCoordinator;
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    abort();
}


@end
