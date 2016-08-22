//
//  Location+CoreDataProperties.m
//  MyLocations
//
//  Created by  Jierism on 16/8/11.
//  Copyright © 2016年  Jierism. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Location+CoreDataProperties.h"

@implementation Location (CoreDataProperties)

@dynamic latitude;
@dynamic longtitude;
@dynamic date;
@dynamic locationDescription;
@dynamic category;
@dynamic placemark;
@dynamic photoId;

- (CLLocationCoordinate2D)coordinate
{
    
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longtitude doubleValue]);
}

- (NSString *)title
{
    if ([self.locationDescription length] > 0) {
        return self.locationDescription;
    }else{
        return @"(No Description)";
    }
}

- (NSString *)subtitle
{
    return self.category;
}

#pragma mark - 保存图片相关
- (BOOL)hasPhoto
{
    return (self.photoId != nil) && ([self.photoId integerValue] != -1);
}
// 新建文件夹存储图片
- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return documentsDirectory;
}

// 创建图片名称
- (NSString *)photoPath
{
    NSString *filename = [NSString stringWithFormat:@"Photo-%ld.jpg",(long)[self.photoId integerValue]];
    return [[self documentsDirectory] stringByAppendingPathComponent:filename];
}

// 通过从Documents文件夹加载图片文件，返回一个图片对象
- (UIImage *)photoImage
{
    NSAssert(self.photoId != nil,@"NO photo ID set");
    NSAssert([self.photoId integerValue] != -1, @"Photo ID is -1");
    return [UIImage imageWithContentsOfFile:[self photoPath]];
}

+ (NSInteger)nextPhotoId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger photoId = [defaults integerForKey:@"PhotoID"];
    [defaults setInteger:photoId+1 forKey:@"PhotoID"];
    [defaults synchronize];
    return photoId;
}
// 删除图片文件夹
- (void)removePhotoFile
{
    NSString *path = [self photoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error;
        if (![fileManager removeItemAtPath:path error:&error]) {
            NSLog(@"Error removing file: %@",error);
        }
    }
}

@end
