//
//  Location+CoreDataProperties.h
//  MyLocations
//
//  Created by  Jierism on 16/8/11.
//  Copyright © 2016年  Jierism. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)<MKAnnotation>

@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longtitude;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *locationDescription;
@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic,retain) NSNumber *photoId;

+ (NSInteger) nextPhotoId;
- (BOOL)hasPhoto;
- (NSString *)photoPath;
- (UIImage *)photoImage;
- (void)removePhotoFile;

@end

NS_ASSUME_NONNULL_END
