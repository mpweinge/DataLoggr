//
//  DLHomeTableViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLHomeTableViewCell.h"
#import "NSString+FontAwesome.h"
//#import "UIHomeGestureRecognizer.h"
#import "DLCircleView.h"

@interface DLHomeTableViewCell ()
{
  UILabel *_chartIcon;
  UILabel *_chartName;
  UILabel *_advanceIcon;
  UILabel *_lastModifiedTime;
  
  UILabel *_editIcon;
  UILabel *_circleDeleteIcon;
  
  DLCircleView *_circleDeleteBorder;
  UILabel *_trashIcon;
  
  BOOL _deleteActive;
}
@end

@implementation DLHomeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            caption:(NSString *)caption
               icon:(FAIcon)icon
               type:(NSString *)type
          rowObject:(DLDataRowObject *)rowObject
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
      _icon = icon;
      
      _rowObject = rowObject;
      
        // Initialization code
      _chartIcon=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 42)];
      _chartIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:28];
      _chartIcon.text = [NSString fontAwesomeIconStringForEnum:icon];
      [self addSubview:_chartIcon];
      
      _chartName = [[UILabel alloc] initWithFrame:CGRectMake(60, 1, 300, 22)];
      _chartName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      _chartName.text = caption;
      [self addSubview:_chartName];
      
      _lastModifiedTime = [[UILabel alloc] initWithFrame:CGRectMake(70, 21, 300, 22)];
      _lastModifiedTime.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:10.0];
      _lastModifiedTime.text = @"Last modified: FakeDateHere";
      [self addSubview:_lastModifiedTime];
      
      _advanceIcon=[[UILabel alloc] initWithFrame:CGRectMake(300, 13, 100, 22)];
      _advanceIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _advanceIcon.textColor = [UIColor blueColor];
      _advanceIcon.text = [NSString fontAwesomeIconStringForEnum:FAAngleRight];
      [self addSubview:_advanceIcon];
      
      _editIcon = [[UILabel alloc] initWithFrame:CGRectMake(290, 13, 100, 22)];
      _editIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _editIcon.textColor = [UIColor blackColor];
      _editIcon.text = [NSString fontAwesomeIconStringForEnum:FAPencilSquareO];
      _editIcon.alpha = 0;
      [self addSubview:_editIcon];
      
      _circleDeleteBorder = [[DLCircleView alloc] initWithFrame:CGRectMake(20, 11, 20, 20) strokeWidth:1.0 selectFill:YES selectColor:[UIColor lightGrayColor]];
      _circleDeleteBorder.alpha = 0;
      _circleDeleteBorder.backgroundColor = [UIColor clearColor];
      [self addSubview:_circleDeleteBorder];
      
      _circleDeleteIcon = [[UILabel alloc] initWithFrame:CGRectMake(23, 11, 20, 20)];
      _circleDeleteIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
      _circleDeleteIcon.text = [NSString fontAwesomeIconStringForEnum:FABan];
      _circleDeleteIcon.alpha = 0;
      [self addSubview:_circleDeleteIcon];
      
      _trashIcon = [[UILabel alloc] initWithFrame:CGRectMake(290, 13, 100, 22)];
      _trashIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _trashIcon.textColor = [UIColor redColor];
      _trashIcon.text = [NSString fontAwesomeIconStringForEnum:FATrashO];
      _trashIcon.alpha = 0;
      [self addSubview:_trashIcon];
      
      
      _title = caption;
      _type = type;
    }

  UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
  
  touchRecognizer.numberOfTapsRequired = 1;
  
  [self addGestureRecognizer:touchRecognizer];
  
  return self;
}

-(void) setTitle:(NSString *)title
{
  _title = title;
  _chartName.text = title;
}

- (void) setIcon:(FAIcon)icon
{
  _icon = icon;
  _chartIcon.text = [NSString fontAwesomeIconStringForEnum:icon];
}

-(void) animateForEdit
{
  [UIView animateKeyframesWithDuration:0.5
                                 delay:0.0
                               options:UIViewKeyframeAnimationOptionLayoutSubviews
                            animations:^{
                              CGRect chartIconFrame = _chartIcon.frame;
                              chartIconFrame.origin.x += 30;
                              _chartIcon.frame = chartIconFrame;
                              
                              CGRect chartNameFrame = _chartName.frame;
                              chartNameFrame.origin.x += 30;
                              chartNameFrame.origin.y += 10;
                              _chartName.frame = chartNameFrame;
                              
                              _lastModifiedTime.alpha = 0;
                              _advanceIcon.alpha = 0;
                              _circleDeleteIcon.alpha = 1.0;
                              _circleDeleteBorder.alpha = 1.0;
                              _editIcon.alpha = 1;
                            }completion:^(BOOL success){
                              UITapGestureRecognizer * deleteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
                              deleteRecognizer.delegate = self;
                              deleteRecognizer.numberOfTapsRequired = 1;
                              
                              [_circleDeleteBorder addGestureRecognizer:deleteRecognizer];
                            }];
}

-(void) DeleteClicked: (UITapGestureRecognizer *)tapClicked
{
  if (_deleteActive ){
    _deleteActive = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
      _trashIcon.alpha = 0;
      _editIcon.alpha = 1;
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
    }];
    
  } else {
    _deleteActive = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
      _trashIcon.alpha = 1;
      _editIcon.alpha = 0;
      _circleDeleteIcon.textColor = [UIColor redColor];
    }];
    
    UITapGestureRecognizer * deleteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteRow:)];
    deleteRecognizer.delegate = self;
    deleteRecognizer.numberOfTapsRequired = 1;

    _trashIcon.userInteractionEnabled = YES;
    [_trashIcon addGestureRecognizer:deleteRecognizer];

  }
}

-(void) unAnimateForEdit
{
  [UIView animateKeyframesWithDuration:0.5
                                 delay:0.0
                               options:UIViewKeyframeAnimationOptionLayoutSubviews
                            animations:^{
                              CGRect chartIconFrame = _chartIcon.frame;
                              chartIconFrame.origin.x -= 30;
                              _chartIcon.frame = chartIconFrame;
                              
                              CGRect chartNameFrame = _chartName.frame;
                              chartNameFrame.origin.x -= 30;
                              chartNameFrame.origin.y -= 10;
                              _chartName.frame = chartNameFrame;
                              
                              _lastModifiedTime.alpha = 1.0;
                              _editIcon.alpha = 0;
                              _circleDeleteIcon.alpha = 0;
                              _advanceIcon.alpha = 1.0;
                              _trashIcon.alpha = 0;
                              _circleDeleteBorder.alpha = 0;
                            }completion:^(BOOL success){
    
                            }];
}

-(void) DeleteRow:(UITapGestureRecognizer *)gestureRecognizer
{
  [self.delegate DeleteRowClicked:self];
}

-(void) holdOnCell : (UIGestureRecognizer *)gestureRecognizer
{
  self.backgroundColor = [UIColor lightGrayColor];
}

-(void) tappedCell : (UIGestureRecognizer *)gestureRecognizer
{
  [self.delegate CellViewTouched:self];
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
