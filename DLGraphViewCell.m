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
  BOOL _caretDown;
  BOOL _switchON;
  NSInteger _units;
  DLDataRowObject *_dataObject;
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
        [_datePlot renderInLayer:hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        _datePlot2 = nil;
        _datePlot3 = nil;
        [self addSubview:hostView];
      }
      
      //Add "more" button
      _downCaret = [[UILabel alloc] initWithFrame:CGRectMake(290, 270, 50, 50)];
      _downCaret.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      _downCaret.textColor = [UIColor blueColor];
      _downCaret.text = [NSString fontAwesomeIconStringForEnum:FACaretDown];
      
      _caretCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(281, 280, 30, 30) strokeWidth:1.0 selectFill:NO selectColor:[UIColor blueColor] boundaryColor:[UIColor blueColor]];
      _caretCircle.backgroundColor = [UIColor clearColor];
      _caretCircle.selected = NO;
      [self addSubview:_caretCircle];
      [self addSubview:_downCaret];
      
      
      UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downCaretClicked:)];
      tapRecognizer.numberOfTouchesRequired = 1;
      [_caretCircle addGestureRecognizer:tapRecognizer];
      
      _linearScale = [[UISwitch alloc] initWithFrame:CGRectMake(180, 360, 50, 50)];
      _linearScale.alpha = 0;
      [_linearScale setOn:_switchON animated:NO];
      [_linearScale addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
      
      UILabel * unitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, 70, 50)];
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
      segmentControl.frame = CGRectMake(80,310,180,30);
      segmentControl.momentary = NO;
      
      if (([type isEqualToString:@"GPS"]) || ([type isEqualToString:@"Time"]) )
        [self addSubview:segmentControl];
      

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
      [_datePlot2 generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot3 generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
    } else if ([selectedSegment isEqualToString:@"mi/hr"]) {
      _units = 1;
      [_datePlot generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot2 generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot3 generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
    } else {
      _units = 2;
      [_datePlot generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot2 generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
      [_datePlot3 generateData:_dataPoints type:_type valueNum:0 isLinear:_switchON units:_units];
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
    [UIView animateWithDuration:0.3 animations:^{
      CGRect caretFrame = _downCaret.frame;
      caretFrame.origin.y += 100;
      _downCaret.frame = caretFrame;
      
      CGRect caretCircleFrame = _caretCircle.frame;
      caretCircleFrame.origin.y += 100;
      _caretCircle.frame = caretCircleFrame;
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

- (void)awakeFromNib
{
    // Initialization code
}

@end
