//
//  WeatherTableTableViewController.m
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/8/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import "WeatherTableTableViewController.h"
#import "Reachability.h"
#import "WeatherTableViewCell.h"
#import "MenuTableViewController.h"
#import "SearchViewController.h"
#import "WebViewController.h"
#import "CityData.h"
#import "XMLReader.h"

@interface WeatherTableTableViewController (){
    NSString *pathToMyCities;
    NSString *pathToJSON;
    NSMutableArray *citiesArray;
    NSMutableArray *weatherDataObjectesArray;
    NSDateFormatter *dateFormatter;
    NSDate *lastModifiedDate;
    int cityCount;
    NSTimer *autoRefreshTimer;
}

@end

@implementation WeatherTableTableViewController{
    MenuTableViewController *menu;
    SearchViewController *search;
    WebViewController *webView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *pathToCache = [searchPath objectAtIndex:0];
        pathToMyCities = [pathToCache stringByAppendingPathComponent:@"myCities.data"];
        pathToJSON = [pathToCache stringByAppendingPathComponent:@"weather.json"];
        citiesArray = [[NSMutableArray alloc]init];
        weatherDataObjectesArray = [[NSMutableArray alloc]init];
        
        UIBarButtonItem *settings = [[UIBarButtonItem alloc]initWithTitle:@"\u2699" style:UIBarButtonItemStyleDone target:self action:@selector(pushMenu)];
        UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushAdd)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:settings, add, nil]];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:24]};
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(saveLoadRefresh)];
        
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
        
        dateFormatter = [[NSDateFormatter alloc]init];
        
        menu = [MenuTableViewController sharedMenu];
        search = [[SearchViewController alloc]init];
        webView = [[WebViewController alloc]init];
        autoRefreshTimer = [[NSTimer alloc]init];
        lastModifiedDate = [[NSDate alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if (![defaults boolForKey:@"first"]) {
//        [defaults setBool:YES forKey:@"first"];
//        [self firstLaunch];
//    } else {
//        [self refreshTable];
//    }
    [self firstLaunch];
    
    autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(autoRefresh) userInfo:nil repeats:YES];
    
    [self.tableView registerClass:[WeatherTableViewCell class] forCellReuseIdentifier:@"myCities"];
    
    //NSLog(@"Dictionary: %@",dictionary);
    
    /*
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormat setLocale:posix];
    [dateFormat setDateFormat:@"EEE, MMM d, yyyy"];
    NSDate *theDate = [NSDate date];
    NSString *finalDate = [dateFormat stringFromDate:theDate];
    [dateFormat setTimeStyle:NSDateFormatterMediumStyle];
    NSString *finalTime = [dateFormat stringFromDate:theDate];
    NSLog(@"%@ and %@",finalDate, finalTime);
     */ //date stuff
    
}

-(void)viewDidAppear:(BOOL)animated{
    if (menu.updated == YES) {
        [self saveLoadRefresh];
        menu.updated = NO;
    }
    
    if (search.updated == YES) {
        [self.tableView setHidden:YES];
        [citiesArray insertObject:[NSString stringWithFormat:@"%@",search.tempID] atIndex:0];
        search.tempID = nil;
        [self saveCities];
        [self saveLoadRefresh];
        [self.tableView setHidden:NO];
        search.updated = NO;
    }
    NSLog(@"Main View Appeared!");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cityCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCities" forIndexPath:indexPath];
    
    if (menu.tempUnit == nil) {
        cell.degreeChar = @"C";
    } else{
        if ([menu.tempUnit isEqualToString:@"metric"]) {
            cell.degreeChar = @"C";
        } else cell.degreeChar = @"F";
    }
    
    [cell drawThisData:[weatherDataObjectesArray objectAtIndex:indexPath.row]];
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
         return 150;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [citiesArray removeObjectAtIndex:indexPath.row];
        cityCount--;
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self saveCities];
//        [self saveLoadRefresh];  // TODO check if required
    } else {
//        NSLog(@"Unhandled editing style! %d", editingStyle);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cityID = [NSString stringWithFormat:@"%@",[(CityData *)[weatherDataObjectesArray objectAtIndex:indexPath.row]cityID]];
    NSString *cityName = [NSString stringWithFormat:@"%@",[(CityData *)[weatherDataObjectesArray objectAtIndex:indexPath.row]cityName]];
    [webView loadWebPage:cityID withCityNamed:cityName];
    [self.navigationController pushViewController:webView animated:YES];
}

#pragma mark - Custom functions

-(void)pushMenu{
    [self.navigationController pushViewController:menu animated:YES];
}

-(void)pushAdd{
    [self presentViewController:search animated:YES completion:nil];
}

-(void)firstLaunch{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:pathToMyCities]) {
        // load XML to citiesArray
        NSData *xmlData = [NSData dataWithContentsOfFile:pathToMyCities];
        NSDictionary *xmlDict = [XMLReader dictionaryForXMLData:xmlData error:nil];
        [citiesArray removeAllObjects];
        
        for(NSDictionary *dict in [[[xmlDict objectForKey:@"plist"] objectForKey:@"array"] objectForKey:@"string"]){
            NSString *str = [dict objectForKey:@"text"];
            [citiesArray addObject:str];
        }
        //NSLog(@"citiesArray = %@",citiesArray);
        [self saveLoadRefresh];
        NSLog(@"Local city data exists! Loading data...");
    } else {
        if (netStatus != NotReachable) {
            // add default cities for first time launch
            [citiesArray addObject:@"5809844"];
            [citiesArray addObject:@"5037649"];
            [citiesArray addObject:@"4887398"];
            [citiesArray addObject:@"4356847"];
            [citiesArray addObject:@"2643743"];
            
            [self saveCities];
            
            [self saveLoadRefresh];
            NSLog(@"Local city data nonexistant! Using default first-launch cities...");
        } else{
            // TODO(?) error - no internet (there is already a "no internet" alert when trying to download data)
        }
    }
}

-(void)saveCities{
    [citiesArray writeToFile:pathToMyCities atomically:YES];
}

-(void)saveLoadRefresh{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:@"tempUnit"] == @"metric") {
//        tempUnit = @"metric"; // imperial
//    } else{
//        tempUnit = menu.tempUnit;
//    }
    
    NSString *citiesString = [self citiesArrayToString:citiesArray];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/group?id=%@&units=%@&APPID=4148d7d47136abf8c7c1bcdb4766c9f0",citiesString,[defaults objectForKey:@"tempUnit"]]]];
    
//    NSData *theData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/group?id=%@&units=%@",citiesString,tempUnit]]];
//    [theData writeToFile:pathToJSON atomically:YES];
//    [self loadData];
    NSLog(@"Starting data download...");
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if ([data length] >0 && connectionError == nil)
        {
            NSLog(@"Data successfully downloaded.");
            [data writeToFile:pathToJSON atomically:YES];
            [self performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:YES];
        }
        else if ([data length] == 0 && connectionError == nil)
        {
            NSLog(@"Nothing was downloaded.");
        }
        else if (connectionError != nil){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection" message:@"Cannot connect to internet" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            [self performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:YES];
            NSLog(@"Error = %@", connectionError);
        }
        
    }];
}

-(void)loadData{
    [weatherDataObjectesArray removeAllObjects];
    NSData *fileData = [NSData dataWithContentsOfFile:pathToJSON];
    
    if (fileData != nil) {
    NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableContainers error:nil];
    for(NSDictionary *cityDict in [dictData objectForKey:@"list"]){
        CityData *cityData = [[CityData alloc]init];
        cityData.cityName = [cityDict objectForKey:@"name"];
        cityData.countryName = [[cityDict objectForKey:@"sys"] objectForKey:@"country"];
        cityData.mainDescription = [[[cityDict objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"];
        cityData.subDescription = [[[cityDict objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"description"];
        cityData.currentTemp = [[cityDict objectForKey:@"main"] objectForKey:@"temp"];
        cityData.minTemp = [[cityDict objectForKey:@"main"] objectForKey:@"temp_min"];
        cityData.maxTemp = [[cityDict objectForKey:@"main"] objectForKey:@"temp_max"];
        cityData.humidity = [[cityDict objectForKey:@"main"] objectForKey:@"humidity"];
        cityData.iconID = [[[cityDict objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"];
        cityData.cityID = [cityDict objectForKey:@"id"];
        cityData.latitude = [[cityDict objectForKey:@"coord"] objectForKey:@"lat"];
        cityData.longitude = [[cityDict objectForKey:@"coord"] objectForKey:@"lon"];
        
        [weatherDataObjectesArray addObject:cityData];
    }
    cityCount = [[dictData objectForKey:@"cnt"] intValue];
    [self dataTimeStamp];
    [self refreshTable];
    } // TODO -  if fieData == nil
}

-(void)refreshTable{
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
}

-(NSString *) citiesArrayToString:(NSMutableArray *) array{
    NSString *finalString = @"";
    
    for (int i = 0; i < array.count; i++) {
        if (i < (array.count - 1)) {
            finalString = [finalString stringByAppendingFormat:[NSString stringWithFormat:@"%@,",[array objectAtIndex:i]]];
        } else{
            finalString = [finalString stringByAppendingFormat:[NSString stringWithFormat:@"%@",[array objectAtIndex:i]]];
        }
    }
    //NSLog(@"citiesString = %@",finalString);
    return finalString;
}

-(void)dataTimeStamp{
    NSDictionary *att = [[NSFileManager defaultManager] attributesOfItemAtPath:pathToJSON error:nil];
    lastModifiedDate = [att fileModificationDate];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:lastModifiedDate];
    menu.lastUpdate = currentTime;
}

-(void)autoRefresh{
    NSTimeInterval differenceOfDate = [[NSDate date] timeIntervalSinceDate:lastModifiedDate];
//    NSLog(@"Auto-Refresh: Difference of date %f", differenceOfDate);
//    NSLog(@"Refresh wait time %i seconds",menu.refreshWaitTime);
    if (differenceOfDate >= menu.refreshWaitTime) {
        [self saveLoadRefresh];
        NSLog(@"Auto-Refresh tiggered");
    }
}

@end
