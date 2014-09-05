//
//  DLTitleTableViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLGraphViewCell.h"
#import "CorePlot-CocoaTouch.h"
#import "DLDatePlot.h"
#import "CPTTheme.h"
#import "DLCircleView.h"
#import "NSString+FontAwesome.h"
#import "DLDatabaseManager.h"
#import "DLDataRowObject.h"

@implementation DLGraphViewCell 
{
    DLDatePlot *_datePlot;
  DLDatePlot *_datePlot2;
  DLDatePlot *_datePlot3;
  NSMutableArray *_indicatorCircles;
  
  NSMutableArray *_dataPoints;
  
  UISwitch * _linearScale;
  NSString *_type;
  UILabel * _downCaret;
  DLCircleView *_caretCircle;
  DLCircleView *_caretTouchCircle;
  BOOL _caretDown;
  BOOL _switchON;
  NSInteger _units;
  DLDataRowObject *_dataObject;
  
  UITextField *_unitsName;
  UILabel *_backgroundText;
  
  BOOL _textFieldEmpty;
  BOOL _didEdit;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
         dataPoints:(NSMutableArray *)dataPoints
               type:(NSString *) type
         dataObject:(DLDataRowObject *) dataObject
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      _dataObject = dataObject;
      _textFieldEmpty = YES;
      UISegmentedControl *segmentControl;
      if ([type isEqualToString:@"GPS"])
      {
        segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"m/s", @"mi/hr", @"km/hr", nil]];
        
        if ([dataObject.UnitsName isEqualToString:@"mi/hr"]) {
          [segmentControl setSelectedSegmentIndex:1];
          _units = 1;
        } else if ([dataObject.UnitsName isEqualToString:@"km/hr"]) {
          [segmentControl setSelectedSegmentIndex:2];
          _units = 2;
        } else {
          [segmentControl setSelectedSegmentIndex:0];
          _units = 0;
        }
        
      } else if ([type isEqualToString:@"Time"]) {
        segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"s", @"min", @"hr", nil]];
        
        if ([dataObject.UnitsName isEqualToString:@"min"]) {
          [segmentControl setSelectedSegmentIndex:1];
          _units = 1;
        } else if ([dataObject.UnitsName isEqualToString:@"hr"]) {
          [segmentControl setSelectedSegmentIndex:2];
          _units = 2;
        } else {
          [segmentControl setSelectedSegmentIndex:0];
          _units = 0;
        }
      }
      
      _switchON = dataObject.isLinear;
      
      // If type is GPS, we actually want to have 3 graphs in one cell with scrolling
      if ([type isEqualToString:@"GPS"]) {
        
        CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 360, 310)];
        _datePlot = [[DLDatePlot alloc] init];
        _datePlot.hostView = hostView;
        [_datePlot generateData: dataPoints type:type valueNum:0 isLinear:_switchON units:_units];
        [_datePlot renderInLayer:hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        
        CPTGraphHostingView *hostView2 = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(360, 0, 360, 310)];
        _datePlot2 = [[DLDatePlot alloc] init];
        _datePlot2.hostView = hostView2;
        [_datePlot2 generateData: dataPoints type:type valueNum:1 isLinear:_switchON units:_units];
        [_datePlot2 renderInLayer:hostView2 withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        
        CPTGraphHostingView *hostView3 = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(720, 0, 360, 310)];
        _datePlot3 = [[DLDatePlot alloc] init];
        _datePlot3.hostView = hostView3;
        [_datePlot3 generateData: dataPoints type:type valueNum:2 isLinear:_switchON units:_units];
        [_datePlot3 renderInLayer:hostView3 withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        
        CGRect graphScrollViewFrame = CGRectMake(0, 0, 360, 310);
        UIScrollView *graphScrollView = [[UIScrollView alloc] initWithFrame:graphScrollViewFrame];
        [graphScrollView addSubview:hostView];
        [graphScrollView addSubview:hostView2];
        [graphScrollView addSubview:hostView3];
        graphScrollView.contentSize = CGSizeMake(1080, 50);
        graphScrollView.contentOffset = CGPointMake(0,0);
        graphScrollView.showsHorizontalScrollIndicator = YES;
        graphScrollView.backgroundColor = [UIColor clearColor];
        graphScrollView.pagingEnabled = YES;
        graphScrollView.delegate = self;
        [self addSubview:graphScrollView];
        
        _indicatorCircles = [NSMutableArray array];
        
        for (int i = 0; i < 3; i++)
        {
          DLCircleView* currCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(140 + 20 * i,290,10,10) strokeWidth: 1.0 selectFill:YES selectColor:[UIColor lightGrayColor]];
          [_indicatorCircles addObject: currCircle];
          currCircle.backgroundColor = [UIColor clearColor];
          currCircle.selected = (i == 0);
          [self addSubview:currCircle];
        }
      } else {
        
        CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 360, 310)];
        _datePlot = [[DLDatePlot alloc] init];
        _datePlot.hostView = hostView;
        [_datePlot generateData: dataPoints type:type isLinear:_switchON units:_units];
        
        if ([type isEqualToString:@"Time"]) {
          [_datePlot renderInLayer:hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        } else {
          [_datePlot renderInLayer:hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES stringUnits:dataObject.UnitsName];
        }
       
        _datePlot2 = nil;
        _datePlot3 = nil;
        [self addSubview:hostView];
      }
      
      //Add "more" button
      _downCaret = [[UILabel alloc] initWithFrame:CGRectMake(290, 270, 50, 50)];
      _downCaret.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _downCaret.textColor = [UIColor blueColor];
      _downCaret.text = [NSString fontAwesomeIconStringForEnum:FACaretDown];
      
      _caretCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(283, 283, 25, 25) strokeWidth:1.0 selectFill:NO selectColor:[UIColor blueColor] boundaryColor:[UIColor blueColor]];
      _caretCircle.backgroundColor = [UIColor clearColor];
      _caretCircle.selected = NO;
      
      //Add another view to just capture touch events
      _caretTouchCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(273, 273, 45, 45) strokeWidth:1.0 selectFill:NO selectColor:[UIColor clearColor] boundaryColor:[UIColor clearColor]];
      _caretTouchCircle.backgroundColor = [UIColor clearColor];
      UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downCaretClicked:)];
      tapRecognizer2.numberOfTouchesRequired = 1;
      [_caretTouchCircle addGestureRecognizer:tapRecognizer2];
      
      [self addSubview:_caretTouchCircle];
      
      [self addSubview:_caretCircle];
      [self addSubview:_downCaret];

      UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downCaretClicked:)];
      tapRecognizer.numberOfTouchesRequired = 1;
      [_caretCircle addGestureRecognizer:tapRecognizer];
      
      _linearScale = [[UISwitch alloc] initWithFrame:CGRectMake(180, 360, 50, 50)];
      _linearScale.alpha = 0;
      [_linearScale setOn:_switchON animated:NO];
      [_linearScale addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
      
      UILabel * unitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 308, 70, 50)];
      unitsLabel.text = @"Units: ";
      unitsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      [self addSubview:unitsLabel];
      
      UILabel * scaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 350, 170, 50)];
      scaleLabel.text = @"Scale points linearly: ";
      scaleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      [self addSubview:scaleLabel];
      
      [segmentControl addTarget:self action:@selector(segmentedControlChanged:)forControlEvents:UIControlEventValueChanged];
      [segmentControl setWidth:60 forSegmentAtIndex:0];
      [segmentControl setWidth:60 forSegmentAtIndex:1];
      [segmentControl setWidth:60 forSegmentAtIndex:2];
      segmentControl.frame = CGRectMake(80,318,180,30);
      segmentControl.momentary = NO;
      
      if (([type isEqualToString:@"GPS"]) || ([type isEqualToString:@"Time"]) ) {
        [self addSubview:segmentControl];
      } else {
        // Create a text view
        _unitsName = [[UITextField alloc] initWithFrame:CGRectMake(60, 310, 350, 50)];
        _unitsName.borderStyle = UITextBorderStyleNone;
        _unitsName.returnKeyType = UIReturnKeyDone;
        _unitsName.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        _unitsName.autocorrectionType = UITextAutocorrectionTypeNo;
        _unitsName.delegate = self;
        _unitsName.keyboardType = UIKeyboardTypeDefault;
        _unitsName.textColor = [UIColor blackColor];
        _unitsName.text = _dataObject.UnitsName;
        
        _backgroundText = [[UILabel alloc] initWithFrame:CGRectMake(60, 308, 350, 50)];
        _backgroundText.textColor = [UIColor lightGrayColor];
        _backgroundText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        _backgroundText.text = @"Unitless";
        
        if ([_dataObject.UnitsName length] > 0) {
          _textFieldEmpty = NO;
          _backgroundText.hidden = YES;
        }
        
        [self addSubview:_unitsName];
        [self addSubview:_backgroundText];
      }
      

      _dataPoints = dataPoints;
      _type = type;
      [self addSubview:_linearScale];
    }
    return self;
}

-(void) segmentedControlChanged:(UISegmentedControl *)segmentControl
{
  NSString * selectedSegment = [segmentControl titleForSegmentAtIndex:segmentControl.selectedSegmentIndex];
  
  if ([_type isEqualToString:@"GPS"]) {
    if ([selectedSegment isEqualToString:@"m/s"]) {
      _units = 0;
      [_datePlot generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot2 generateData:_dataPoints type:_type valueNum:1 isLinear:_switchON units:_units];
      [_datePlot3 generateData:_dataPoints type:_type valueNum:2 isLinear:_switchON units:_units];
    } else if ([selectedSegment isEqualToString:@"mi/hr"]) {
      _units = 1;
      [_datePlot generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot2 generateData:_dataPoints type:_type valueNum:1 isLinear:_switchON units:_units];
      [_datePlot3 generateData:_dataPoints type:_type valueNum:2 isLinear:_switchON units:_units];
    } else {
      _units = 2;
      [_datePlot generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot2 generateData:_dataPoints type:_type valueNum:1 isLinear:_switchON units:_units];
      [_datePlot3 generateData:_dataPoints type:_type valueNum:2 isLinear:_switchON units:_units];
    }
    
    [_datePlot renderInLayer:_datePlot.hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
    [_datePlot2 renderInLayer:_datePlot2.hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
    [_datePlot3 renderInLayer:_datePlot3.hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
    
  } else {
    if ([selectedSegment isEqualToString:@"s"]) {
      _units = 0;
      [_datePlot generateData:_dataPoints type:_type isLinear:_switchON units:_units];
    } else if ([selectedSegment isEqualToString:@"min"]) {
      _units = 1;
      [_datePlot generateData:_dataPoints type:_type isLinear:_switchON units:_units];
    } else {
      _units = 2;
      [_datePlot generateData:_dataPoints type:_type isLinear:_switchON units:_units];
    }
    [_datePlot renderInLayer:_datePlot.hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
  }
  
  [_delegate didChangeUnits:_units];
  
  [[DLDatabaseManager getSharedInstance] updateOldRow:_dataObject withNewUnits:selectedSegment];
  _dataObject.UnitsName = selectedSegment;
}

-(void) downCaretClicked:(UITapGestureRecognizer *)recognizer
{
  [_delegate moreClicked : !_caretDown];
  if (!_caretDown) {
    _linearScale.alpha = 1.0;
    
    /*CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_downCaret.layer addAnimation:animation forKey:@"changeTextTransition"];
    */
    // Change the text
    
    [UIView animateWithDuration:0.3 animations:^{
      CGRect caretFrame = _downCaret.frame;
      caretFrame.origin.y += 100;
      _downCaret.frame = caretFrame;
      
      CGRect caretCircleFrame = _caretCircle.frame;
      caretCircleFrame.origin.y += 100;
      _caretCircle.frame = caretCircleFrame;
      
      CGRect caretTouchCircleFrame = _caretTouchCircle.frame;
      caretTouchCircleFrame.origin.y += 100;
      _caretTouchCircle.frame = caretTouchCircleFrame;
    } completion:^(BOOL didComplete){
      _downCaret.text = [NSString fontAwesomeIconStringForEnum:FACaretUp];
      _linearScale.alpha = 1.0;
    }];
  } else {
    [UIView animateWithDuration:0.3 animations:^{
      CGRect caretFrame = _downCaret.frame;
      caretFrame.origin.y -= 100;
      _downCaret.frame = caretFrame;
      
      CGRect caretCircleFrame = _caretCircle.frame;
      caretCircleFrame.origin.y -= 100;
      _caretCircle.frame = caretCircleFrame;
      
      CGRect caretTouchCircleFrame = _caretTouchCircle.frame;
      caretTouchCircleFrame.origin.y -= 100;
      _caretTouchCircle.frame = caretTouchCircleFrame;
    } completion:^(BOOL didComplete){
      _downCaret.text = [NSString fontAwesomeIconStringForEnum:FACaretDown];
    }];
  }
  _caretDown = !_caretDown;
}

-(void) changeSwitch:(id) sender
{
  BOOL switchON = [sender isOn];
  _switchON = switchON;
  if ([_type isEqualToString:@"GPS"]) {
    [_datePlot generateData:_dataPoints type:_type valueNum:0 isLinear:switchON units:_units];
  } else {
    [_datePlot generateData:_dataPoints type:_type isLinear:switchON units:_units];
  }
  [_datePlot.graph reloadData];
  
  if (_datePlot2) {
    [_datePlot2 generateData:_dataPoints type:_type valueNum:1 isLinear:switchON units:_units];
    [_datePlot3 generateData:_dataPoints type:_type valueNum:2 isLinear:switchON units:_units];
    [_datePlot2.graph reloadData];
    [_datePlot3.graph reloadData];
  }
  
  [[DLDatabaseManager getSharedInstance] updateOldRow:_dataObject withNewLinear:switchON];
  _dataObject.isLinear = switchON;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  static NSInteger previousPage = 0;
  CGFloat pageWidth = scrollView.frame.size.width;
  NSInteger page = scrollView.contentOffset.x / pageWidth;
  if (previousPage != page) {
    ((DLCircleView *)_indicatorCircles[page]).selected = YES;
    ((DLCircleView *)_indicatorCircles[previousPage]).selected = NO;
    
    [((DLCircleView *)_indicatorCircles[page]) setNeedsDisplay];
    [((DLCircleView *)_indicatorCircles[previousPage]) setNeedsDisplay];
    
    previousPage = page;
    
    [_delegate scrollViewDidChangePage:page];
  }
}

-(void)scrollToY:(float)y
{
  [UIView beginAnimations:@"registerScroll" context:NULL];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDuration:0.4];
  [self superview].transform = CGAffineTransformMakeTranslation(0, y);
  [UIView commitAnimations];
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
  [self scrollToY:-150];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  [self scrollToY:0];
  
  [[DLDatabaseManager getSharedInstance] updateOldRow:_dataObject withNewUnits:textField.text];
  _dataObject.UnitsName = textField.text;
  
  [_datePlot renderInLayer:_datePlot.hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES stringUnits:_dataObject.UnitsName];
  
  [_delegate didChangeUnitString:textField.text];
  
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  if ((range.location == 0) && ([string isEqualToString:@""]) && (textField.text.length == 1))
  {
    _backgroundText.hidden = NO;
    
    UITextPosition *beginning = [textField beginningOfDocument];
    [textField setSelectedTextRange:[textField textRangeFromPosition:beginning
                                                          toPosition:beginning]];
    _textFieldEmpty = true;
    textField.text = @"";
  } else if (_textFieldEmpty) {
    _backgroundText.hidden = YES;
    _textFieldEmpty = false;
  }
  
  _didEdit = YES;
  
  return YES;
}


- (void)awakeFromNib
{
    // Initialization code
}

@end
