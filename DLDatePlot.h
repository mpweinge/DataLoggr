//
//  DatePlot.h
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"

@interface DLDatePlot : NSObject<CPTPlotSpaceDelegate,
CPTPlotDataSource,
CPTScatterPlotDelegate>
{
@private
    CPTXYGraph *localGraph;
    NSArray *plotData;
}

-(void)generateData : (NSMutableArray *)dataPoints isTime: (BOOL)_isTimeData;
-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated;

@property (nonatomic, readwrite, assign) CPTGraphHostingView *hostView;

@end

