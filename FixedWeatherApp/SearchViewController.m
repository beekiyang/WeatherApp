//
//  SearchViewController.m
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/18/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import "SearchData.h"
#import "WeatherTableTableViewController.h"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>{
    UITableView *tableView;
    UITextField *searchField;
    NSMutableArray *searchDataObjectsArray;
    UIButton *closeButton;
    UIButton *currentLocationButton;
    int searchCount;
    BOOL usingCurrentLocation;
}

@end

@implementation SearchViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tempID = [[NSString alloc]init];
        searchField = [[UITextField alloc]init];
        searchDataObjectsArray = [[NSMutableArray alloc]init];
        searchCount = 0;
        _updated = 0;
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.delegate = self;
        _location = [[CLLocation alloc] init];
        usingCurrentLocation = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *fieldBorder = [[UILabel alloc]initWithFrame:CGRectMake(5, 55, self.view.frame.size.width - 10, 30)];
    [fieldBorder.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [fieldBorder.layer setBorderWidth:1.0];
    fieldBorder.layer.cornerRadius = 5;
    
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(10, 55, self.view.frame.size.width - 20, 30)];
//    [searchField.layer setBorderColor:[[UIColor blueColor] CGColor]];
//    [searchField.layer setBorderWidth:1.0];
//    searchField.layer.cornerRadius = 5;
//    searchField.clipsToBounds = YES;
    searchField.delegate = self;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.placeholder = @"Enter city name";
    [searchField setReturnKeyType:UIReturnKeyGo];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 90, self.view.frame.size.width - 20, self.view.frame.size.height - 90)];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    currentLocationButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 20, self.view.frame.size.width/3*2 - 10, 30)];
    [currentLocationButton setTitle:@"Use My Location" forState:UIControlStateNormal];
    currentLocationButton.layer.cornerRadius = 5;
    currentLocationButton.layer.borderWidth = 1;
    currentLocationButton.layer.borderColor = [UIColor blueColor].CGColor;
    currentLocationButton.titleLabel.textColor = [UIColor blueColor];
    [currentLocationButton addTarget:self action:@selector(useCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [currentLocationButton addTarget:self action:@selector(buttonHeld:) forControlEvents:UIControlEventTouchDown];
    [currentLocationButton addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpOutside];
    
    closeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3*2 + 5, 20, self.view.frame.size.width/3 - 10, 30)];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 5;
    closeButton.layer.borderWidth = 1;
    closeButton.layer.borderColor = [UIColor blueColor].CGColor;
    closeButton.titleLabel.textColor = [UIColor blueColor];
    [closeButton addTarget:self action:@selector(cleanUp) forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(buttonHeld:) forControlEvents:UIControlEventTouchDown];
    [closeButton addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpOutside];
    
    [tableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:@"myCells"];
    
    [self.view addSubview:fieldBorder];
    [self.view addSubview:searchField];
    [self.view addSubview:tableView];
    [self.view addSubview:closeButton];
    [self.view addSubview:currentLocationButton];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        _coder = [[CLGeocoder alloc]init];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    currentLocationButton.titleLabel.textColor = [UIColor blueColor];
    closeButton.titleLabel.textColor = [UIColor blueColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self searchStart:textField.text];
    [self resignFirstResponder];
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return searchCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCells" forIndexPath:indexPath];

//    cell.textLabel.text = [NSString stringWithFormat:@"Hello - %ld", (long)indexPath.row +1];
//    cell.imageView.image = [UIImage imageNamed:@"img5.png"];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    cell.detailTextLabel.text = @"Detail Text";
    [cell drawThisData:[searchDataObjectsArray objectAtIndex:indexPath.row]];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _tempID = ((SearchData *)[searchDataObjectsArray objectAtIndex:indexPath.row]).cityID;
    _updated = YES;
    
    [self cleanUp];
}

-(void)searchStart:(NSString *) searchText{
    
    NSString *finalSearch = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    // http://api.openweathermap.org/data/2.5/find?q=London&type=like&APPID=4148d7d47136abf8c7c1bcdb4766c9f0
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/find?q=%@&type=like&APPID=4148d7d47136abf8c7c1bcdb4766c9f0",finalSearch]]];

    NSLog(@"Starting search..");
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if ([data length] >0 && connectionError == nil)
        {
            NSLog(@"Search successfully completed.");
            [self performSelectorOnMainThread:@selector(parseAndDisplayData:) withObject:data waitUntilDone:YES];
        }
        else if ([data length] == 0 && connectionError == nil)
        {
            NSLog(@"Searched no results.");
            // data = nil;
            // [self performSelectorOnMainThread:@selector(parseAndDisplayData:) withObject:data waitUntilDone:YES];
        }
        else if (connectionError != nil){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection" message:@"Cannot connect to internet" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            NSLog(@"Error = %@", connectionError);
        }
        
    }];

}

-(void)parseAndDisplayData:(NSData *)data{
    [searchDataObjectsArray removeAllObjects];
    
    NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    for(NSDictionary *tempDict in [dictData objectForKey:@"list"]){
        SearchData *searchData = [[SearchData alloc]init];
        searchData.cityName = [tempDict objectForKey:@"name"];
        searchData.countryName = [[tempDict objectForKey:@"sys"] objectForKey:@"country"];
        searchData.cityID = [tempDict objectForKey:@"id"];
        
        [searchDataObjectsArray addObject:searchData];
    }
    searchCount = [[dictData objectForKey:@"count"] intValue];
    
    if (usingCurrentLocation) {
        _tempID = [[searchDataObjectsArray objectAtIndex:0] cityID];
        _updated = YES;
        [self cleanUp];
    }else{
        [self refreshTable];
    }
}

-(void)refreshTable{
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
}

-(void)useCurrentLocation{
    [_locationManager startUpdatingLocation];
    NSLog(@"Use Current Location button clicked!");
    
    searchDataObjectsArray = [SearchData addPleaseWaitCell:searchDataObjectsArray];
    searchCount = 1;
    [self refreshTable];
}

-(void)cleanUp{
    searchField.text = nil;
    [searchDataObjectsArray removeAllObjects];
    searchCount = 0;
    closeButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    [self refreshTable];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)buttonHeld:(UIButton *)button{
    button.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:1 alpha:1];
    button.titleLabel.textColor = [UIColor whiteColor];
}
-(void)buttonRelease:(UIButton *)button{
    button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    button.titleLabel.textColor = [UIColor blueColor];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = locations.lastObject;
//    NSLog(@"%@", self.location.coordinate);
    
    
    [self.coder reverseGeocodeLocation:locations.lastObject completionHandler:^(NSArray *placemarks, NSError *error) {
        if(!error){
            if ([[placemarks objectAtIndex:0] locality]) {
                [_locationManager stopUpdatingLocation];
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSLog(@"Current city = %@",placemark.locality);
                usingCurrentLocation = YES;
                [self searchStart:placemark.locality];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not determine your current location" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }
            
            
        } else {
            NSLog(@"Error");
        }
    }];
}

@end
