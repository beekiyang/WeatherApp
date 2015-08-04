//
//  CityData.h
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/16/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityData : NSObject

@property (nonatomic,copy) NSString *cityName;
@property (nonatomic,copy) NSString *countryName;
@property (nonatomic,copy) NSString *mainDescription;
@property (nonatomic,copy) NSString *subDescription;
@property (nonatomic,copy) NSString *currentTemp;
@property (nonatomic,copy) NSString *minTemp;
@property (nonatomic,copy) NSString *maxTemp;
@property (nonatomic,copy) NSString *humidity;
@property (nonatomic,copy) NSString *iconID;
@property (nonatomic,copy) NSString *cityID;
@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;

@end
