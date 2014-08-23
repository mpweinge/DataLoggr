//
//  DLDataViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataViewCell.h"
#import "NSString+FontAwesome.h"

@interface DLDataViewCell() {
  NSString *_title;
  NSString *_type;
  NSString *_notes;
  NSString *_time;
  DLDataPointRowObject *_dataObject;
}
@end

@implementation DLDataViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               name:(NSString *)name
              value:(NSString *)value
               time:(NSString *)time
              notes:(NSString *)notes
         dataObject:(DLDataPointRowObject *)dataObject;
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
      
      UILabel* advanceIcon=[[UILabel alloc] initWithFrame:CGRectMake(300, 13, 100, 22)];
      advanceIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      advanceIcon.text = [NSString fontAwesomeIconStringForEnum:FAPencil];
      [self addSubview:advanceIcon];
      
      UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
      
      touchRecognizer.numberOfTapsRequired = 1;
      
      [self addGestureRecognizer:touchRecognizer];
      
      _notes = notes;
      _title = value;
      _time = time;
      _dataObject = dataObject;
    }
    return self;
}

-(void) tappedCell : (UIGestureRecognizer *)gestureRecognizer
{
  [self.delegate CellViewTouched:self];
}

-(NSString *)getTitle
{
  return _title;
}

-(NSString *)getType
{
  return _type;
}

- (NSString *)getNotes
{
  return _notes;
}

-(DLDataPointRowObject *) dataPoint
{
  return _dataObject;
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
