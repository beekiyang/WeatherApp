//
//  WeatherTableViewCell.h
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/8/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CityData.h"

@interface WeatherTableViewCell : UITableViewCell <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) NSString *degreeChar;
@property (nonatomic, strong) CLLocationManager *locationManager;

-(void) drawThisData:(CityData *) cityData;


@end
