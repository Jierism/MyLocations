//
//  LocationDetailViewController.h
//  MyLocations
//
//  Created by  Jierism on 16/8/9.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class Location;

@interface LocationDetailViewController : UITableViewController

@property (assign,nonatomic) CLLocationCoordinate2D coordinate;
@property (strong,nonatomic) CLPlacemark *placemark;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) Location *locationToEdit;

@end
