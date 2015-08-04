//
//  SearchData.h
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/20/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchData : NSObject

@property (nonatomic,copy) NSString *cityName;
@property (nonatomic,copy) NSString *countryName;
@property (nonatomic,copy) NSString *cityID;

+(NSMutableArray *)addPleaseWaitCell:(NSMutableArray *)array;

@end
