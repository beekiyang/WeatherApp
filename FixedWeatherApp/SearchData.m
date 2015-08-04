//
//  SearchData.m
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/20/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import "SearchData.h"

@implementation SearchData

+(NSMutableArray *)addPleaseWaitCell:(NSMutableArray *)array{
    [array removeAllObjects];
    SearchData *searchDataPlaceHolder = [[SearchData alloc]init];
    searchDataPlaceHolder.cityName = @"Please wait...";
    searchDataPlaceHolder.countryName = @"";
    searchDataPlaceHolder.cityID = @"";
    [array addObject:searchDataPlaceHolder];
    
    return array;
}

@end
