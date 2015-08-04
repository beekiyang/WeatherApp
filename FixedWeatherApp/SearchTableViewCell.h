//
//  SearchTableViewCell.h
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/20/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchData.h"

@interface SearchTableViewCell : UITableViewCell

-(void) drawThisData:(SearchData *)searchData;

@end
