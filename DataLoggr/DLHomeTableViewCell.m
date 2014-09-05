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
#import "DLDatabaseManager.h"

@interface DLHomeTableViewCell ()
{
  UILabel *_chartIcon;
  UILabel *_chartName;
  UILabel *_advanceIcon;
  UILabel *_lastModifiedTime;
  
  UILabel *_editIcon;
  UILabel *_circleDeleteIcon;
  
  DLCircleView *_circleDeleteBorder;
  DLCircleView *_circleTapRegion;
  DLCircleView *_trashTapRegion;
  
  UIView *_whiteView;
  UIView *_whiteView2;
  
  UILabel *_trashIcon;
  
  BOOL _deleteActive;
  
  UITapGestureRecognizer *_deleteRecognizer;
  UIPanGestureRecognizer *_panRecognizer;
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
      
      //Fetch the most recent data value for the cell
      NSString * lastModifiedTime = [[DLDatabaseManager getSharedInstance] fetchLastUpdatedTime:caption];
      
      _lastModifiedTime = [[UILabel alloc] initWithFrame:CGRectMake(70, 21, 300, 22)];
      _lastModifiedTime.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:10.0];
      
      if ([lastModifiedTime length] > 17) {
        _lastModifiedTime.text = [NSString stringWithFormat:@"Last modified: %@", [lastModifiedTime substringToIndex: 18]];
      } else {
        _lastModifiedTime.text = [NSString stringWithFormat:@"Last modified: %@", lastModifiedTime];

      }
      [self addSubview:_lastModifiedTime];
      
      _advanceIcon=[[UILabel alloc] initWithFrame:CGRectMake(300, 13, 100, 22)];
      _advanceIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _advanceIcon.textColor = [UIColor blueColor];
      _advanceIcon.text = [NSString fontAwesomeIconStringForEnum:FAAngleRight];
      [self addSubview:_advanceIcon];
      
      _editIcon = [[UILabel alloc] initWithFrame:CGRectMake(290, 13, 20, 22)];
      _editIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _editIcon.textColor = [UIColor blackColor];
      _editIcon.text = [NSString fontAwesomeIconStringForEnum:FAPencilSquareO];
      _editIcon.alpha = 0;
      _editIcon.backgroundColor = [UIColor whiteColor];
      
      _whiteView = [[UIView alloc] initWithFrame:CGRectMake(290, 13, 20, 22)];
      _whiteView.backgroundColor = [UIColor whiteColor];
      _whiteView.alpha = 0;
      
      _circleTapRegion = [[DLCircleView alloc] initWithFrame:CGRectMake(10, 1, 40, 40) strokeWidth:1.0 selectFill:YES selectColor:[UIColor clearColor] boundaryColor:[UIColor clearColor]];
      _circleTapRegion.alpha = 0;
      _circleTapRegion.backgroundColor = [UIColor clearColor];
      [self addSubview:_circleTapRegion];
      
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
      
      _trashTapRegion = [[DLCircleView alloc] initWithFrame:CGRectMake(280, 1, 40, 40) strokeWidth:1.0 selectFill:YES selectColor:[UIColor clearColor] boundaryColor:[UIColor clearColor]];
      _trashTapRegion.alpha = 0;
      _trashTapRegion.backgroundColor = [UIColor clearColor];
      [self addSubview:_trashTapRegion];
      
      _trashIcon = [[UILabel alloc] initWithFrame:CGRectMake(290, 13, 100, 22)];
      _trashIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _trashIcon.textColor = [UIColor redColor];
      _trashIcon.text = [NSString fontAwesomeIconStringForEnum:FATrashO];
      _trashIcon.alpha = 0.0;
      [self addSubview:_trashIcon];
      
      [self addSubview:_whiteView];
      [self addSubview:_editIcon];
      
      _whiteView2 = [[UIView alloc] initWithFrame:CGRectMake(250, 13, 40, 22)];
      _whiteView2.backgroundColor = [UIColor whiteColor];
      [self addSubview:_whiteView2];
      
      _title = caption;
      _type = type;
    }

  UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
  
  touchRecognizer.numberOfTapsRequired = 1;
  
  [self addGestureRecognizer:touchRecognizer];
  
  return self;
}

-(void) TrashEditClicked
{
  if (_deleteActive) {
    [self DeleteRow:nil];
  } else {
    [self tappedCell:nil];
  }
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

- (void) animateForEdit : (BOOL) animate
{
  if (animate) {
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
                              _trashTapRegion.alpha = 1.0;
                              _editIcon.alpha = 1;
                              _whiteView.alpha = 1;
                            }completion:^(BOOL success){
                              UITapGestureRecognizer * deleteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
                              deleteRecognizer.delegate = self;
                              deleteRecognizer.numberOfTapsRequired = 1;
                              
                              [_circleDeleteBorder addGestureRecognizer:deleteRecognizer];
                              
                              
                              UITapGestureRecognizer * deleteRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
                              deleteRecognizer2.delegate = self;
                              deleteRecognizer2.numberOfTapsRequired = 1;
                              
                              [_circleTapRegion addGestureRecognizer:deleteRecognizer2];
                              
                              UITapGestureRecognizer * deleteRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TrashEditClicked)];
                              deleteRecognizer3.delegate = self;
                              deleteRecognizer3.numberOfTapsRequired = 1;
                              
                              [_trashTapRegion addGestureRecognizer:deleteRecognizer3];
                              
                              _trashIcon.alpha = 1;
                              _circleTapRegion.alpha = 1.0;
                            }];
  } else {
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
    _circleTapRegion.alpha = 1.0;
    _trashTapRegion.alpha = 1.0;
    _editIcon.alpha = 1;
    _whiteView.alpha = 1;
    _trashIcon.alpha = 1;
    
    UITapGestureRecognizer * deleteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
    deleteRecognizer.delegate = self;
    deleteRecognizer.numberOfTapsRequired = 1;
    
    [_circleDeleteBorder addGestureRecognizer:deleteRecognizer];
    
    UITapGestureRecognizer * deleteRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeleteClicked:)];
    deleteRecognizer2.delegate = self;
    deleteRecognizer2.numberOfTapsRequired = 1;
    
    [_circleTapRegion addGestureRecognizer:deleteRecognizer2];
    
    UITapGestureRecognizer * deleteRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TrashEditClicked)];
    deleteRecognizer3.delegate = self;
    deleteRecognizer3.numberOfTapsRequired = 1;
    
    [_trashTapRegion addGestureRecognizer:deleteRecognizer3];
  }
  
  _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedCell:)];
  _panRecognizer.delegate = self;
  [self addGestureRecognizer:_panRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  if (([gestureRecognizer class] == [UITapGestureRecognizer class]) ||
      ([otherGestureRecognizer class] == [UITapGestureRecognizer class]) )
  {
    return NO;
  } else if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
    return YES;
  }
  return NO;
}

-(void) DeleteClicked: (UITapGestureRecognizer *)tapClicked
{
  if (_deleteActive ){
    _deleteActive = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
      //_editIcon.alpha = 1.0;
      //_whiteView.alpha = 1.0;
      CGRect frame =_editIcon.frame;
      frame.origin.x = 290;
      _editIcon.frame = frame;
      _whiteView.frame = frame;
      _circleDeleteIcon.textColor = [UIColor lightGrayColor];
    }];
    
    [_trashIcon removeGestureRecognizer:_deleteRecognizer];
    
  } else {
    _deleteActive = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
      //_trashIcon.alpha = 1;
      //_editIcon.alpha = 0;
      CGRect frame =_editIcon.frame;
      frame.origin.x = 270;
      _editIcon.frame = frame;
      _whiteView.frame = frame;
      //_whiteView.alpha = 0;
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

-(void) unAnimateForEdit : (NSTimeInterval ) delay
{
  _trashIcon.alpha = 0;
  _circleTapRegion.alpha = 0;
  
  [UIView animateKeyframesWithDuration:0.5
                                 delay:delay
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
                              _whiteView.alpha = 0;
                              _circleDeleteIcon.alpha = 0;
                              _advanceIcon.alpha = 1.0;
                              _circleDeleteBorder.alpha = 0;
                              _trashTapRegion.alpha = 0;
                            }completion:^(BOOL success){
                              _deleteActive = NO;
                              _circleDeleteIcon.textColor = [UIColor lightGrayColor];
                              CGRect editFrame = _editIcon.frame;
                              editFrame.origin.x = 290;
                              _editIcon.frame = editFrame;
                              _whiteView.frame = editFrame;
                            }];
  
  [self removeGestureRecognizer:_panRecognizer];
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
  [self.delegate CellViewTouched:(DLDataViewCell *)self];
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
