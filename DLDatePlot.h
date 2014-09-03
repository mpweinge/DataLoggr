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
//@public
    //CPTXYGraph *localGraph;
  @private
    NSArray *plotData;
}

-(void)generateData : (NSMutableArray *)dataPoints
                type: (NSString *)type
            isLinear:(BOOL) isLinear
               units:(NSInteger) units;

-(void)generateData : (NSMutableArray *)dataPoints
                type: (NSString *)type
            valueNum:(int) val
            isLinear:(BOOL) isLinear
               units:(NSInteger) units;

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated;

@property (nonatomic, readwrite, assign) CPTGraphHostingView *hostView;
@property (nonatomic, readwrite) CPTXYGraph *graph;

@end

