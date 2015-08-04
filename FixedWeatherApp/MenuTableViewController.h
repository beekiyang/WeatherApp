//
//  MenuTableViewController.h
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/15/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewController : UITableViewController

@property (strong, nonatomic) NSString *tempUnit;
@property (strong, nonatomic) NSString *lastUpdate;
@property (nonatomic,assign) BOOL updated;
@property (nonatomic,assign) int refreshWaitTime;

+(MenuTableViewController *) sharedMenu;

@end
