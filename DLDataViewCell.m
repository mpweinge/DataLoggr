//
//  DLDataViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataViewCell.h"

@implementation DLDataViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      UILabel * date = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, 100, 22)];
      date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      date.text = @"Date";
      [self addSubview:date];
      
      UILabel * dataValue = [[UILabel alloc] initWithFrame:CGRectMake(100, 13, 100, 22)];
      dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      dataValue.text = @"Value";
      [self addSubview:dataValue];
      
      UILabel * chartName = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 100, 22)];
      chartName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      chartName.text = @"Units";
      [self addSubview:chartName];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
