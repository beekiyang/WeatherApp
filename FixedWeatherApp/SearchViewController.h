//
//  SearchViewController.h
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/18/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController : UIViewController

@property (nonatomic,assign) BOOL updated;
@property (strong, nonatomic) NSString *tempID;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLGeocoder *coder;

@end
