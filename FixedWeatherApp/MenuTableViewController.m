//
//  MenuTableViewController.m
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/15/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import "MenuTableViewController.h"
#import "WeatherTableTableViewController.h"

@interface MenuTableViewController (){
    int tableCellHeight;
    UISegmentedControl *tempSeg;
    UISwitch *countrySwitch;
    UILabel *updateLabel;
    UISegmentedControl *refreshSeg;
    
    NSString *currentTemp;
    int currentRefresh;
    BOOL currentCountry;
}

@end

@implementation MenuTableViewController

static MenuTableViewController *sharedMenu;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Menu";
        tableCellHeight = 44;
        _updated = NO;
        
        updateLabel = [[UILabel alloc]init];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"tempUnit"]) {
            [defaults setObject:@"metric" forKey:@"tempUnit"];
            [defaults synchronize];
        }
        if (![defaults objectForKey:@"countryHidden"]) {
            [defaults setBool:NO forKey:@"countryHidden"];
            [defaults synchronize];
        }
        if (![defaults objectForKey:@"refreshTime"]) {
            [defaults setInteger:600 forKey:@"refreshTime"];
            [defaults synchronize];
        }
        _tempUnit = [defaults objectForKey:@"tempUnit"];
        _refreshWaitTime = [defaults integerForKey:@"refreshTime"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"myCells"];
    
    self.tableView.allowsSelection = NO;
    
    NSLog(@"tempUnit for menu = %@",_tempUnit);
}

-(void)viewDidAppear:(BOOL)animated{
    if(_lastUpdate != nil){
        updateLabel.text = [NSString stringWithFormat:@"Last update: %@",_lastUpdate];
    } else{
        updateLabel.text = nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentTemp = [defaults objectForKey:@"tempUnit"];
    currentCountry = [defaults boolForKey:@"countryHidden"];
    currentRefresh = [defaults integerForKey:@"refreshTime"];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //check if any changes in the manu was made
    if (currentTemp != _tempUnit) {
        _updated = YES;
    }
    if (currentRefresh != _refreshWaitTime) {
        _updated = YES;
    }
    if (currentCountry != [defaults boolForKey:@"countryHidden"]) {
        [defaults setBool:countrySwitch.on forKey:@"countryHidden"];
        _updated = YES;
    }
    
}

+(MenuTableViewController *) sharedMenu{
    static MenuTableViewController *sharedMenu = nil;
    @synchronized(self) {
        if (sharedMenu == nil)
            sharedMenu = [[self alloc] init];
    }
    return sharedMenu;
}

-(void)tempUnitToggle{ //segmented control for temperature units
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (tempSeg.selectedSegmentIndex) {
        case 0:
            [defaults setObject:@"metric" forKey:@"tempUnit"];
            break;
        case 1:
            [defaults setObject:@"imperial" forKey:@"tempUnit"];
        default:
            break;
    }
    [defaults synchronize];
    _tempUnit = [defaults objectForKey:@"tempUnit"];
    
    NSLog(@"tempUnit \u0394 %@",_tempUnit);
}

-(void)refreshToggle{ //segmented control for auto-refresh times
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (refreshSeg.selectedSegmentIndex) {
        case 0:
            [defaults setInteger:600 forKey:@"refreshTime"];
            break;
        case 1:
            [defaults setInteger:1800 forKey:@"refreshTime"];
            break;
        case 2:
            [defaults setInteger:3600 forKey:@"refreshTime"];
            break;
        default:
            break;
    }
    [defaults synchronize];
//    NSLog(@"class of refreshTime = %i",(int)[defaults integerForKey:@"refreshTime"]);
    _refreshWaitTime = (int)[defaults integerForKey:@"refreshTime"];
    
    NSLog(@"Auto-Refresh Time: %i seconds",_refreshWaitTime);
}

-(void)countryToggle{ // switch for hiding country name
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (countrySwitch.on) {
        [defaults setBool:YES forKey:@"countryHidden"];
    } else{
        [defaults setBool:NO forKey:@"countryHidden"];
    }
    [defaults synchronize];
    
    NSLog(@"countryHidden = %d",[defaults boolForKey:@"countryHidden"]);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCells" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        UILabel *tempLabel = [[UILabel alloc]init];
        tempLabel.frame = CGRectMake(20, 7, self.view.frame.size.width - 40, 30);
        tempLabel.text = @"Temperature Unit";
        
        tempSeg = [[UISegmentedControl alloc]initWithItems:@[@"\u00B0C   ",@"\u00B0F   "]];
        tempSeg.frame = CGRectMake(self.view.frame.size.width - tempSeg.intrinsicContentSize.width - 15, (tableCellHeight - tempSeg.intrinsicContentSize.height)/2, tempSeg.intrinsicContentSize.width, 30);
        [tempSeg addTarget:self action:@selector(tempUnitToggle) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:tempLabel];
        [self.view addSubview:tempSeg];
        
        if ([_tempUnit isEqualToString:@"metric"]) { // cosmetics
            tempSeg.selectedSegmentIndex = 0;
        } else{
            tempSeg.selectedSegmentIndex = 1;
        }
    }
    
    if (indexPath.row == 1) {
        UILabel *refreshLabel = [[UILabel alloc]init];
        refreshLabel.frame = CGRectMake(20, tableCellHeight + 5, self.view.frame.size.width - 40, 30);
        refreshLabel.text = @"Auto Refresh Every";
        
        updateLabel.frame = CGRectMake(20, tableCellHeight + 27, self.view.frame.size.width - 40, 15);
        updateLabel.text = _lastUpdate;
        [updateLabel setFont:[UIFont systemFontOfSize:10]];
        
        refreshSeg = [[UISegmentedControl alloc]initWithItems:@[@"10 min",@"30 min",@"1 hour"]];
        refreshSeg.frame = CGRectMake(self.view.frame.size.width - refreshSeg.intrinsicContentSize.width - 15, (tableCellHeight - refreshSeg.intrinsicContentSize.height)/2 + tableCellHeight, refreshSeg.intrinsicContentSize.width, 30);
        [refreshSeg addTarget:self action:@selector(refreshToggle) forControlEvents:UIControlEventValueChanged];
        
        switch (_refreshWaitTime) {
            case 600:
                refreshSeg.selectedSegmentIndex = 0;
                break;
            case 1800:
                refreshSeg.selectedSegmentIndex = 1;
                break;
            case 3600:
                refreshSeg.selectedSegmentIndex = 2;
                break;
            default:
                break;
        }
        
        [self.view addSubview:refreshLabel];
        [self.view addSubview:updateLabel];
        [self.view addSubview:refreshSeg];
    }
    
    if (indexPath.row == 2) {
        UILabel *countryLabel = [[UILabel alloc]init];
        countryLabel.frame = CGRectMake(20, tableCellHeight * 2 + 7, self.view.frame.size.width - 40, 30);
        countryLabel.text = @"Hide Country Name";
        
        countrySwitch = [[UISwitch alloc]init];
        countrySwitch.frame = CGRectMake(self.view.frame.size.width - countrySwitch.intrinsicContentSize.width - 15, (tableCellHeight - countrySwitch.intrinsicContentSize.height)/2 + tableCellHeight*2, countrySwitch.intrinsicContentSize.width, 30);
        [countrySwitch addTarget:self action:@selector(countryToggle) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:countryLabel];
        [self.view addSubview:countrySwitch];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:@"countryHidden"]) { // cosmetics
            countrySwitch.on = YES;
        } else{
            countrySwitch.on = NO;
        }
    }
    
    //NSLog(@"Index path: %@", indexPath);
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight; //defined in init
}

@end
