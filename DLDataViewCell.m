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
  DLDataPointRowObject *_dataObject;
  UILabel *_dataValue;
  UILabel *_dateValue;
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
      _dateValue = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, 100, 22)];
      _dateValue.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      _dateValue.text = time;
      [self addSubview:_dateValue];
      
      _dataValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 100, 22)];
      _dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      _dataValue.text = value;
      [self addSubview:_dataValue];
      
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

-(DLDataPointRowObject *) dataPoint
{
  return _dataObject;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void) updateCellText
{
  _dataValue.text = _title;
  _dateValue.text = _time;
}

- (void) setTitle:(NSString *)title
{
  _title = title;
  [self updateCellText];
}

- (void) setType:(NSString *)type
{
  _type = type;
  [self updateCellText];
}

- (void) setNotes:(NSString *)notes
{
  _notes = notes;
  [self updateCellText];
}

- (void) setTime:(NSString *)time
{
  _time = time;
  [self updateCellText];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
