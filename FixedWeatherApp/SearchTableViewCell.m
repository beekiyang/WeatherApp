//
//  SearchTableViewCell.m
//  FixedWeatherApp
//
//  Created by Bee Yang on 6/20/15.
//  Copyright (c) 2015 Bee Yang. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"myCells"];
    if (self) {
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

-(void) drawThisData:(SearchData *)searchData{
    self.textLabel.text = searchData.cityName;
    self.detailTextLabel.text = searchData.countryName;
}

@end
