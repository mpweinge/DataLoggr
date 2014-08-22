//
//  DLDataViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataViewCell.h"

@interface DLDataViewCell() {
  NSString * _title;
  NSString *_type;
}
@end

@implementation DLDataViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              value:(NSString *)value
               time:(NSString *)time
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      UILabel * date = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, 100, 22)];
      date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      date.text = time;
      [self addSubview:date];
      
      UILabel * dataValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 100, 22)];
      dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      dataValue.text = value;
      [self addSubview:dataValue];
      
      /*UILabel * chartName = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 100, 22)];
      chartName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      chartName.text = @"Units";
      [self addSubview:chartName];*/
    }
    return self;
}

-(NSString *)getTitle
{
  return _title;
}

-(NSString *)getType
{
  return _type;
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
