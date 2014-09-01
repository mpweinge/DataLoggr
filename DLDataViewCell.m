//
//  DLDataViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataViewCell.h"
#import "NSString+FontAwesome.h"
#import "DLCircleView.h"
#import "DLDataPointRowObject.h"

@interface DLDataViewCell() {
  DLDataPointRowObject *_dataObject;
  UILabel *_dataValue;
  
  UILabel *_dayValue;
  UILabel *_timeValue;
  
  UILabel *_editIcon;
  UILabel *_trashIcon;
  UILabel *_circleDeleteIcon;
  
  DLCircleView *_circleDeleteBorder;
  
  BOOL _deleteActive;
  
  UITapGestureRecognizer *_deleteRecognizer;
  
  double _distanceNum;
  double _timeNum;
}
@end

@implementation DLDataViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               name:(NSString *)name
              value:(NSString *)value
               time:(NSString *)time
               type:(NSString *)type
              notes:(NSString *)notes
         dataObject:(DLDataPointRowObject *)dataObject;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      _deleteActive = NO;
      _deleteRecognizer = nil;
      // Initialization code
      _dayValue = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 80, 22)];
      _dayValue.textAlignment = NSTextAlignmentRight;
      _dayValue.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      
      //Search for comma in string to separate date from time
      int splitLocation = [time rangeOfString:@","].location;
      _dayValue.text = [time substringToIndex:splitLocation];
      
      [self addSubview:_dayValue];
      
      _timeValue = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 100, 22)];
      _timeValue.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
      _timeValue.text = [time substringFromIndex:splitLocation + 1];
      _timeValue.textAlignment = NSTextAlignmentRight;
      [self addSubview:_timeValue];
      
      
      if ([type isEqualToString:@"GPS"]) {
        // Grab the first value
        
        int timeColonIdx = 0;
        int timeCommaIdx = 0;
        int distanceColonIdx = 0;
        int distanceCommaIdx = 0;
        int i = 0;
        
        //Read in the time
        for (i = 0; i < value.length; i++)
        {
          // Find the colon first
          if ([value characterAtIndex:i] == ':') {
            timeColonIdx = i;
          } else if ( [value characterAtIndex:i] == ',') {
            timeCommaIdx = i;
            break;
          }
        }
        
        i++;
        
        //Read in the distance
        for ( i; i < value.length; i++)
        {
          // Find the colon first
          if ([value characterAtIndex:i] == ':') {
            distanceColonIdx = i;
          } else if ( [value characterAtIndex:i] == ',') {
            distanceCommaIdx = i;
            break;
          }
        }
        
        i++;
        
        NSString *time = [value substringWithRange:NSMakeRange(timeColonIdx + 2, (timeCommaIdx - timeColonIdx - 2))];
        NSString *distance = [value substringWithRange:NSMakeRange(distanceColonIdx + 2, (distanceCommaIdx - distanceColonIdx - 2))];
        
        _timeNum = [time doubleValue];
        _distanceNum = [distance doubleValue];
        
        _dataValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 70, 22)];
        _dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        _dataValue.textAlignment = NSTextAlignmentRight;
        _dataValue.text = [NSString stringWithFormat:@"%.01f m/s", (_distanceNum / _timeNum)];
        
        [self addSubview:_dataValue];
        
      } else {
        _dataValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 100, 22)];
        _dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
        _dataValue.text = value;
        [self addSubview:_dataValue];
      }
      
      _editIcon=[[UILabel alloc] initWithFrame:CGRectMake(290, 13, 100, 22)];
      _editIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _editIcon.text = [NSString fontAwesomeIconStringForEnum:FAPencilSquareO];
      [self addSubview:_editIcon];
      
      _circleDeleteBorder = [[DLCircleView alloc] initWithFrame:CGRectMake(20, 14, 20, 20) strokeWidth:1.0 selectFill:YES selectColor:[UIColor lightGrayColor]];
      _circleDeleteBorder.alpha = 1.0;
      _circleDeleteBorder.backgroundColor = [UIColor clearColor];
      [self addSubview:_circleDeleteBorder];
      
      _circleDeleteIcon = [[UILabel alloc] initWithFrame:CGRectMake(23, 14, 20, 20)];
      _circleDeleteIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
      _circleDeleteIcon.text = [NSString fontAwesomeIconStringForEnum:FABan];
      _circleDeleteIcon.alpha = 1.0;
      [self addSubview:_circleDeleteIcon];
      
      _trashIcon = [[UILabel alloc] initWithFrame:CGRectMake(290, 13, 100, 22)];
      _trashIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _trashIcon.textColor = [UIColor redColor];
      _trashIcon.text = [NSString fontAwesomeIconStringForEnum:FATrashO];
      _trashIcon.alpha = 0;
      [self addSubview:_trashIcon];
      
      UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
      
      touchRecognizer.numberOfTapsRequired = 1;
      
      [self addGestureRecognizer:touchRecognizer];
      
      UITapGestureRecognizer *deleteTouchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
      
      deleteTouchRecognizer.numberOfTapsRequired = 1;
      
      [_circleDeleteBorder addGestureRecognizer:deleteTouchRecognizer];
      
      _notes = notes;
      _title = value;
      _time = time;
      _dataObject = dataObject;
    }
    return self;
}

-(void) DeleteClicked : (UITapGestureRecognizer *)tapClicked
{
  if (_deleteActive ){
    _deleteActive = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
      _trashIcon.alpha = 0;
      _editIcon.alpha = 1;
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
    }];
    
    [_trashIcon removeGestureRecognizer:_deleteRecognizer];
    
  } else {
    _deleteActive = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
      _trashIcon.alpha = 1;
      _editIcon.alpha = 0;
      _circleDeleteIcon.textColor = [UIColor redColor];
    }];
    
    if (!_deleteRecognizer) {
      _deleteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteRow:)];
      _deleteRecognizer.delegate = self;
      _deleteRecognizer.numberOfTapsRequired = 1;
    }
    
    _trashIcon.userInteractionEnabled = YES;
    [_trashIcon addGestureRecognizer:_deleteRecognizer];
    
  }
}

-(void) graphViewDidScroll:(NSUInteger)pageNum
{
  if (pageNum == 0) {
    _dataValue.text = [NSString stringWithFormat:@"%.01f m/s", (_distanceNum / _timeNum)];
  } else if (pageNum == 1) {
    _dataValue.text = [NSString stringWithFormat:@"%.01f m",_distanceNum ];
  } else {
    
    int numMinutes = _timeNum / 60;
    int numMinutesTen = numMinutes / 10;
    
    int numSeconds = (_timeNum - numMinutes * 60);
    int numSecondsTen = numSeconds / 10;
    
    int numMilli = (_timeNum - numSeconds) * 100;
    int numMilliTen = numMilli / 10;
    numMilli -= numMilliTen * 10;
    
    numMinutes -= numMinutesTen * 10;
    numSeconds -= numSecondsTen * 10;
    
    _dataValue.text = [NSString stringWithFormat:@"%i%i:%i%i.%i%i s", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
  }
}

-(void) DeleteRow : (UIGestureRecognizer *)gestureRecognizer
{
  [self.delegate DeleteRowClicked:self];
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
  _dayValue.text = _time;
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
