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

@implementation DLGraphViewCell
{
    DLDatePlot *_datePlot;
  DLDatePlot *_datePlot2;
  DLDatePlot *_datePlot3;
  NSMutableArray *_indicatorCircles;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
         dataPoints:(NSMutableArray *)dataPoints
               type:(NSString *) type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      // If type is GPS, we actually want to have 3 graphs in one cell with scrolling
      if ([type isEqualToString:@"GPS"]) {
        
        CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 360, 310)];
        _datePlot = [[DLDatePlot alloc] init];
        _datePlot.hostView = hostView;
        [_datePlot generateData: dataPoints type:type valueNum:0];
        [_datePlot renderInLayer:hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        
        CPTGraphHostingView *hostView2 = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(360, 0, 360, 310)];
        _datePlot2 = [[DLDatePlot alloc] init];
        _datePlot2.hostView = hostView2;
        [_datePlot2 generateData: dataPoints type:type valueNum:1];
        [_datePlot2 renderInLayer:hostView2 withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        
        CPTGraphHostingView *hostView3 = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(720, 0, 360, 310)];
        _datePlot3 = [[DLDatePlot alloc] init];
        _datePlot3.hostView = hostView3;
        [_datePlot3 generateData: dataPoints type:type valueNum:2];
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
        [_datePlot generateData: dataPoints type:type];
        [_datePlot renderInLayer:hostView withTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme ] animated:YES];
        
        [self addSubview:hostView];
      }
    }
    return self;
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
