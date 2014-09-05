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
#import "DLDataRowObject.h"

@interface DLDataViewCell() {
  DLDataPointRowObject *_dataPointObject;
  DLDataRowObject *_dataObject;
  UILabel *_dataValue;
  
  UILabel *_dayValue;
  UILabel *_timeValue;
  
  UILabel *_editIcon;
  UILabel *_trashIcon;
  UILabel *_circleDeleteIcon;
  
  UILabel *_notesIcon;
  
  UIView *_whiteView;
  UIView *_whiteView2;
  
  DLCircleView *_circleDeleteBorder;
    DLCircleView *_circleTapRegion;
    DLCircleView *_trashTapRegion;
  
  BOOL _deleteActive;
  
  UITapGestureRecognizer *_deleteRecognizer;
  UIPanGestureRecognizer *_panRecognizer;
  
  double _distanceNum;
  double _timeNum;
  
  NSInteger _pageNum;
  NSInteger _units;
  
  NSString *_stringUnits;
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
    dataPointObject:(DLDataPointRowObject *)dataPointObject
            pageNum:(NSInteger) page
        stringUnits:(NSString *) units
         dataObject:(DLDataRowObject *)dataObject
{
  if (units) {
    _stringUnits = units;
  } else {
    _stringUnits = @"";
  }
  return [self initWithStyle:style
             reuseIdentifier:reuseIdentifier
                        name:name
                       value:value
                        time:time
                        type:type
                       notes:notes
             dataPointObject:dataPointObject
                     pageNum:page
                       units:0
                  dataObject:dataObject];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               name:(NSString *)name
              value:(NSString *)value
               time:(NSString *)time
               type:(NSString *)type
              notes:(NSString *)notes
    dataPointObject:(DLDataPointRowObject *)dataPointObject
            pageNum:(NSInteger) page
              units:(NSInteger) units
         dataObject:(DLDataRowObject *)dataObject;
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
      _timeValue.text = [time substringWithRange: NSMakeRange(splitLocation + 1, ([time length] - (splitLocation + 4)))];
      _timeValue.textAlignment = NSTextAlignmentRight;
      [self addSubview:_timeValue];
      
      [[[self contentView] superview] setClipsToBounds:YES];
      
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
        for ( ; i < value.length; i++)
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
        
        if (_timeNum == 0)
          _timeNum = 1;
        
        _distanceNum = [distance doubleValue];
        
        _dataValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 70, 22)];
        _dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        _dataValue.textAlignment = NSTextAlignmentRight;
        //_dataValue.text = [NSString stringWithFormat:@"%.01fm/s", (_distanceNum / _timeNum)];
        _type = type;
        [self changeLabelForPage:page units:units];
        _pageNum = page;
        _units = units;
        
        [self addSubview:_dataValue];
        
        if ([notes length] > 0) {
          _notesIcon = [[UILabel alloc] initWithFrame:CGRectMake(225, 13, 70, 22)];
          _notesIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
          _notesIcon.textColor = [UIColor blackColor];
          _notesIcon.text = [NSString fontAwesomeIconStringForEnum:FAFileTextO];
          [self addSubview:_notesIcon];
        }
      } else if ([type isEqualToString:@"Time"]){
        _dataValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 110, 22)];
        _dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
        _dataValue.text = [value stringByAppendingString:@"s"];
        [self addSubview:_dataValue];
        
        if ([notes length] > 0) {
          _notesIcon = [[UILabel alloc] initWithFrame:CGRectMake(235, 12, 70, 22)];
          _notesIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
          _notesIcon.textColor = [UIColor blackColor];
          _notesIcon.text = [NSString fontAwesomeIconStringForEnum:FAFileTextO];
          [self addSubview:_notesIcon];
        }
      } else {
        _dataValue = [[UILabel alloc] initWithFrame:CGRectMake(150, 13, 130, 22)];
        _dataValue.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
        if (_stringUnits) {
          _dataValue.text = [value stringByAppendingFormat:@" %@", _stringUnits];
        } else {
          _dataValue.text = value;
        }
        [_dataValue sizeToFit];
        [self addSubview:_dataValue];
        
        if ([notes length] > 0) {
          _notesIcon = [[UILabel alloc] initWithFrame:CGRectMake(150 + _dataValue.frame.size.width + 5, 12, 70, 22)];
          _notesIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
          _notesIcon.textColor = [UIColor blackColor];
          _notesIcon.text = [NSString fontAwesomeIconStringForEnum:FAFileTextO];
          [self addSubview:_notesIcon];
        }
      }
      
      _editIcon=[[UILabel alloc] initWithFrame:CGRectMake(290, 13, 20, 22)];
      _editIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _editIcon.text = [NSString fontAwesomeIconStringForEnum:FAPencilSquareO];
      
      _whiteView = [[UIView alloc] initWithFrame:CGRectMake(290, 13, 20, 22)];
      _whiteView.backgroundColor = [UIColor whiteColor];
      _whiteView.alpha = 1;
      
      _circleTapRegion = [[DLCircleView alloc] initWithFrame:CGRectMake(10, 4, 40, 40) strokeWidth:1.0 selectFill:YES selectColor:[UIColor clearColor] boundaryColor:[UIColor clearColor]];
      _circleTapRegion.alpha = 1.0;
      _circleTapRegion.backgroundColor = [UIColor clearColor];
      [self addSubview:_circleTapRegion];
      
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
      
      _trashTapRegion = [[DLCircleView alloc] initWithFrame:CGRectMake(280, 1, 40, 40) strokeWidth:1.0 selectFill:YES selectColor:[UIColor clearColor] boundaryColor:[UIColor clearColor]];
      _trashTapRegion.alpha = 1.0;
      _trashTapRegion.backgroundColor = [UIColor clearColor];
      [self addSubview:_trashTapRegion];
      
      _trashIcon = [[UILabel alloc] initWithFrame:CGRectMake(290, 13, 100, 22)];
      _trashIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _trashIcon.textColor = [UIColor redColor];
      _trashIcon.text = [NSString fontAwesomeIconStringForEnum:FATrashO];
      _trashIcon.alpha = 1;
      [self addSubview:_trashIcon];
      
      [self addSubview:_whiteView];
      [self addSubview:_editIcon];
      
      _whiteView.alpha = 1;
      
      _whiteView2 = [[UIView alloc] initWithFrame:CGRectMake(250, 13, 40, 22)];
      _whiteView2.backgroundColor = [UIColor whiteColor];
      [self addSubview:_whiteView2];
      
      UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
      
      touchRecognizer.numberOfTapsRequired = 1;
      
      [self addGestureRecognizer:touchRecognizer];
      
      UITapGestureRecognizer *deleteTouchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
      deleteTouchRecognizer.numberOfTapsRequired = 1;
      [_circleTapRegion addGestureRecognizer:deleteTouchRecognizer];
      
      UITapGestureRecognizer *deleteTouchRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
      deleteTouchRecognizer2.numberOfTapsRequired = 1;
      [_circleDeleteBorder addGestureRecognizer:deleteTouchRecognizer2];
      
      UITapGestureRecognizer * deleteRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TrashEditClicked:)];
      deleteRecognizer3.delegate = self;
      deleteRecognizer3.numberOfTapsRequired = 1;
      
      [_trashTapRegion addGestureRecognizer:deleteRecognizer3];
      
       _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedCell:)];
      _panRecognizer.delegate = self;
      [self addGestureRecognizer:_panRecognizer];
      _panRecognizer.cancelsTouchesInView = NO;
      
      _deleteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteRow:)];
      _deleteRecognizer.delegate = self;
      _deleteRecognizer.numberOfTapsRequired = 1;
      
      _trashIcon.userInteractionEnabled = YES;
      [_trashIcon addGestureRecognizer:_deleteRecognizer];
      
      _notes = notes;
      _title = value;
      _time = time;
      _dataObject = dataObject;
      _dataPointObject = dataPointObject;
      _type = type;
    }
    return self;
}

- (void) layoutSubviews {
  [[self contentView] setClipsToBounds:YES];
  [super layoutSubviews];
}

- (void) TrashEditClicked:(UIGestureRecognizer *)gestureRecognizer
{
  if (_deleteActive)
  {
    [self DeleteRow:gestureRecognizer];
  } else {
    [self tappedCell:gestureRecognizer];
  }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  if (([gestureRecognizer class] == [UITapGestureRecognizer class]) ||
    ([otherGestureRecognizer class] == [UITapGestureRecognizer class]) )
  {
    return NO;
  } else if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
    return YES;
  }
  return NO;
}

-(void) DeleteClicked : (UITapGestureRecognizer *)tapClicked
{
  if (_deleteActive ){
    _deleteActive = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
      CGRect frame =_editIcon.frame;
      frame.origin.x = 290;
      _editIcon.frame = frame;
      _whiteView.frame = frame;
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
    }];
    
  } else {
    _deleteActive = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
      CGRect frame =_editIcon.frame;
      frame.origin.x = 270;
      _editIcon.frame = frame;
      _whiteView.frame = frame;
      _circleDeleteIcon.textColor = [UIColor redColor];
    }];
  }
}

-(void) graphViewDidScroll:(NSUInteger)pageNum
{
  _pageNum = pageNum;
  [self changeLabelForPage:pageNum units:_units];
}

-(void) didChangeUnits:(NSInteger) units
{
  if ([_type isEqualToString:@"GPS"]) {
    [self changeLabelForPage:_pageNum units:units];
    _units = units;
  }
}

-(void) didChangeUnitString:(NSString *) unitString
{
  _stringUnits = unitString;
  
  _dataValue.text = [_title stringByAppendingFormat:@" %@", _stringUnits];
}

- (void) changeLabelForPage:(NSInteger) page units:(NSInteger) units
{
  if ([_type isEqualToString:@"GPS"]) {
    switch (units) {
      case 0: {
        switch (page) {
          case 0: {
             _dataValue.text = [NSString stringWithFormat:@"%.01fm/s", (_distanceNum / _timeNum)];
            break;
          }
          case 1: {
             _dataValue.text = [NSString stringWithFormat:@"%.01fm", _distanceNum];
            break;
          }
          case 2: {
            
            int numMinutes = _timeNum / 60;
            int numMinutesTen = numMinutes / 10;
            
            int numSeconds = (_timeNum - numMinutes * 60);
            int numSecondsTen = numSeconds / 10;
            
            int numMilli = (_timeNum - numSeconds) * 100;
            int numMilliTen = numMilli / 10;
            numMilli -= numMilliTen * 10;
            
            numMinutes -= numMinutesTen * 10;
            numSeconds -= numSecondsTen * 10;
            
            _dataValue.text = [NSString stringWithFormat:@"%i%i:%i%i.%i%is", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
            break;
          }
          default: {
            assert(0);
          }
        }
        break;
      }
      case 1: {
        switch (page) {
          case 0: {
            _dataValue.text = [NSString stringWithFormat:@"%.01fmi/hr", (_distanceNum / _timeNum * 2.23694)];
            break;
          }
          case 1: {
            _dataValue.text = [NSString stringWithFormat:@"%.01fmi", _distanceNum * 0.000621371];
            break;
          }
          case 2: {
            
            int numMinutes = _timeNum / 60;
            int numMinutesTen = numMinutes / 10;
            
            int numSeconds = (_timeNum - numMinutes * 60);
            int numSecondsTen = numSeconds / 10;
            
            int numMilli = (_timeNum - numSeconds) * 100;
            int numMilliTen = numMilli / 10;
            numMilli -= numMilliTen * 10;
            
            numMinutes -= numMinutesTen * 10;
            numSeconds -= numSecondsTen * 10;
            
            _dataValue.text = [NSString stringWithFormat:@"%i%i:%i%i.%i%is", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
            break;
          }
          default: {
            assert(0);
          }
        }
        break;
      }
      case 2: {
        switch (page) {
          case 0: {
            _dataValue.text = [NSString stringWithFormat:@"%.01fkm/hr", (_distanceNum / _timeNum * 3.6)];
            break;
          }
          case 1: {
            _dataValue.text = [NSString stringWithFormat:@"%.01fkm", _distanceNum /1000];
            break;
          }
          case 2: {
            
            int numMinutes = _timeNum / 60;
            int numMinutesTen = numMinutes / 10;
            
            int numSeconds = (_timeNum - numMinutes * 60);
            int numSecondsTen = numSeconds / 10;
            
            int numMilli = (_timeNum - numSeconds) * 100;
            int numMilliTen = numMilli / 10;
            numMilli -= numMilliTen * 10;
            
            numMinutes -= numMinutesTen * 10;
            numSeconds -= numSecondsTen * 10;
            
            _dataValue.text = [NSString stringWithFormat:@"%i%i:%i%i.%i%is", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
            break;
          }
          default: {
            assert(0);
          }
        }
        break;
      }
      default: {
        assert(0);
      }
    }
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

-(void) pannedCell: (UIPanGestureRecognizer *)panRecognizer
{
  CGPoint translation = [panRecognizer translationInView:self];
  
  CGRect editFrame = _editIcon.frame;
  editFrame.origin.x += (translation.x / 4);
  
  if (editFrame.origin.x < 270) {
    editFrame.origin.x = 270;
    _deleteActive = YES;
    [UIView animateWithDuration:0.5 animations:^{
      _circleDeleteIcon.textColor = [UIColor redColor];
    }];
  } else if (editFrame.origin.x > 290) {
    editFrame.origin.x = 290;
    [UIView animateWithDuration:0.5 animations:^{
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
    }];
  } else if ((editFrame.origin.x > 280) && ([panRecognizer state] == UIGestureRecognizerStateEnded)) {
    _deleteActive = NO;
    editFrame.origin.x = 290;
    [UIView animateWithDuration:0.2 animations:^{
      _editIcon.frame = editFrame;
      _whiteView.frame = editFrame;
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
    }];
    return;
  } else if([panRecognizer state] == UIGestureRecognizerStateEnded){
    _deleteActive = YES;
    editFrame.origin.x = 270;
    [UIView animateWithDuration:0.2 animations:^{
      _editIcon.frame = editFrame;
      _whiteView.frame = editFrame;
      _circleDeleteIcon.textColor = [UIColor redColor];
    }];
    return;
  }
  
  _editIcon.frame = editFrame;
  
  _whiteView.frame = editFrame;
  
  [panRecognizer setTranslation:CGPointMake(0, 0) inView:self];
}

-(DLDataPointRowObject *) dataPoint
{
  return _dataPointObject;
}

-(DLDataRowObject *) dataObject
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
