//
//  DLDataTypeViewController.m
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-20.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataIconView.h"
#import "NSString+FontAwesome.h"
#import "DLCircleView.h"

@implementation DLDataIconView
{
    NSString *_title;
    FAIcon _icon;
    BOOL _depressed;
    DLCircleView *_circleView;
    UILabel *_timeIconLabel;
}

-(id) initWithFrame:(CGRect) frame
               icon:(FAIcon) icon
              title:(NSString*)title
{
    self = [super initWithFrame: frame];
    if (self)
    {
        _title = title;
        _icon = icon;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconClicked:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
        _depressed = false;
        self.backgroundColor = [UIColor clearColor];
      //self.layer.borderColor = [UIColor whiteColor].CGColor;
      //self.layer.borderWidth = 2.0f;
    }
    return self;
}

- (void) iconClicked:(UITapGestureRecognizer *)tapRecognizer
{
  _depressed = !_depressed;
  
  [_delegate iconClicked:self];
}

- (NSString *) getTitle
{
    if (_title) {
        return _title;
    }
    else {
        return [NSString stringForFAIcon:_icon];
    }
}

- (void) setSelected: (BOOL) isSelected
{
    _selected = isSelected;
    _depressed =_selected;
  
    // Animate the view to be selected
    [self animateViewSelected: isSelected];
}

- (void) animateViewSelected: (BOOL) isSelected
{
  [self setNeedsLayout];
  /*if (isSelected) {
    //Change the selected icon to have a blue background
    _circleView.setSelected = YES;
    _timeIconLabel
  } else {
    [UIView animateWithDuration:5 animations:^{
      _circleView.backgroundColor = [UIColor blueColor];
    }];
  }*/
}

- (void)layoutSubviews
{
  _timeIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
  _timeIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24 ];
  _timeIconLabel.text = [NSString fontAwesomeIconStringForEnum:_icon];
  _timeIconLabel.backgroundColor = [UIColor clearColor];
  
    if (_title != nil) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 100, 50)];
        timeLabel.text = _title;
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        [timeLabel sizeToFit];
        CGRect _newTimeFrame = timeLabel.frame;
        _newTimeFrame.origin.x += (25 - timeLabel.frame.size.width / 2);
        timeLabel.frame = _newTimeFrame;
        [self addSubview:timeLabel];
      
      _circleView = [[DLCircleView alloc] initWithFrame:CGRectMake(0,0,50,50)];
      _circleView.alpha = 1.0;
      //_circleView.layer.cornerRadius = 25;
      _circleView.selected = _selected;
      _circleView.backgroundColor = [UIColor clearColor];
      //_circleView.layer.borderColor = [[UIColor clearColor] CGColor];
      //_circleView.layer.borderWidth = 2.0f;
      [self addSubview:_circleView];
      
      if (_selected) {
        _timeIconLabel.textColor = [UIColor whiteColor];
      } else {
        _timeIconLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
      }
    } else {
      if (_selected) {
        _timeIconLabel.textColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1.0];
      } else {
        _timeIconLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
      }
    }
  
    [_timeIconLabel sizeToFit];
    CGRect _newTimeFrame = _timeIconLabel.frame;
    _newTimeFrame.origin.x += (25 - _timeIconLabel.frame.size.width / 2 );
    _newTimeFrame.origin.y += (25 - _timeIconLabel.frame.size.height / 2);
    _timeIconLabel.frame = _newTimeFrame;
  
   // _timeIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, 50)];
    [self addSubview:_timeIconLabel];
}

@end
