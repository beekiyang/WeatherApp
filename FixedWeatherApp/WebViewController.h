//
//  WebViewController.h
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/22/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

-(void)loadWebPage:(NSString *)cityID withCityNamed: (NSString * )cityName;

@end
