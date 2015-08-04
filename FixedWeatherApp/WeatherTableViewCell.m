//
//  WeatherTableViewCell.m
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/8/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import "WeatherTableViewCell.h"
#import "MenuTableViewController.h"

@implementation WeatherTableViewCell{
    UIImageView *imageView;
    UILabel *cityLabel;
    UILabel *descriptionLabel;
    UILabel *currentTempLabel;
    UILabel *minTempLabel;
    UILabel *maxTempLabel;
    UILabel *humidityLabel;
    NSString *countryString;
    MKMapView *myMap;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
        //imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];

        cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, self.contentView.frame.size.width-75, 40)];
        cityLabel.font = [UIFont boldSystemFontOfSize:30.0];
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 44, self.contentView.frame.size.width-75, 30)];
        descriptionLabel.font = [UIFont systemFontOfSize:18.0];
        
        currentTempLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 45, 60, 30)];
        currentTempLabel.font = [UIFont boldSystemFontOfSize:14.0];
        minTempLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105, 60, 30)];
        minTempLabel.font = [UIFont systemFontOfSize:11.0];
        minTempLabel.numberOfLines = 2;
        minTempLabel.textAlignment = NSTextAlignmentCenter;
        maxTempLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 75, 60, 30)];
        maxTempLabel.font = [UIFont systemFontOfSize:11.0];
        maxTempLabel.numberOfLines = 2;
        maxTempLabel.textAlignment = NSTextAlignmentCenter;
        
        humidityLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 63, self.contentView.frame.size.width-75, 30)];
        humidityLabel.font = [UIFont systemFontOfSize:14.0];
        
        countryString = [[NSString alloc]init];
        
        [self.contentView addSubview:cityLabel];
        [self.contentView addSubview:descriptionLabel];
        [self.contentView addSubview:currentTempLabel];
        [self.contentView addSubview:minTempLabel];
        [self.contentView addSubview:maxTempLabel];
        [self.contentView addSubview:humidityLabel];
        
        if (_degreeChar == nil) {
            _degreeChar = @"C";
        }
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
            [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization) to:self.locationManager from:self forEvent:nil];
        }
        
        myMap = [[MKMapView alloc] initWithFrame:CGRectMake(80, 90, self.contentView.frame.size.width - 90, 50)];
        myMap.mapType = MKMapTypeStandard;
        myMap.delegate = self;
        myMap.scrollEnabled = YES;
        [self.contentView addSubview:myMap];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) drawThisData:(CityData *) cityData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"countryHidden"]) { // cosmetics
        countryString = @"";
    } else{
        countryString = [NSString stringWithFormat:@", %@",cityData.countryName];
    }
    
    imageView.image = [UIImage imageNamed:cityData.iconID];
    cityLabel.text = [NSString stringWithFormat:@"%@%@",cityData.cityName, countryString];
    descriptionLabel.text = [NSString stringWithFormat:@"%@ - %@",
                            cityData.mainDescription,[cityData.subDescription lowercaseString]];
    currentTempLabel.text = [NSString stringWithFormat:@"%0.2f\u00B0%@",[cityData.currentTemp floatValue], _degreeChar];
    minTempLabel.text = [NSString stringWithFormat:@"min\n%0.2f\u00B0%@",[cityData.minTemp floatValue], _degreeChar];
    maxTempLabel.text = [NSString stringWithFormat:@"max\n%0.2f\u00B0%@",[cityData.maxTemp floatValue], _degreeChar];
    
    humidityLabel.text = [NSString stringWithFormat:@"Humidity: %@%%",cityData.humidity];
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake([cityData.latitude doubleValue], [cityData.longitude doubleValue]), MKCoordinateSpanMake(0.05, 0.05));
    [myMap setRegion:region];

    /*
    NSMutableAttributedString * tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"min %@\u00B0%@, max %@\u00B0%@, %@\u00B0%@",
            [[dict objectForKey:@"main"]objectForKey:@"temp_min"], self.degreeChar,
            [[dict objectForKey:@"main"]objectForKey:@"temp_max"], self.degreeChar,
            [[dict objectForKey:@"main"]objectForKey:@"temp"], self.degreeChar
            ]];
    
    //NSRange midrange = [tempString.string rangeOfString:@"-"];
    NSRange range;
    range.length = (unsigned long)(16 + [[[dict objectForKey:@"main"]objectForKey:@"temp_min"] length] + [[[dict objectForKey:@"main"]objectForKey:@"temp_max"] length]);
    range.location = range.length - 1;
    
    [tempString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:32]} range:NSMakeRange(0, range.location)];
    
    //[tempString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:32]}range:midrange];
    
    [tempString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]}range:NSMakeRange(range.location + range.length, tempString.length - range.location - range.length)];
    
    temperatureLabel.attributedText = tempString;
    */
    
}

@end
