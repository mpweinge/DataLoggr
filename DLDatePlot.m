//
//  DatePlot.m
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "DLDatePlot.h"
#import "DLDataPointRowObject.h"

@implementation DLDatePlot
{
  NSDate *_minDate;
  NSDate *_maxDate;
  float _maxY;
}

-(id)init
{
    if ( (self = [super init]) ) {
        //self.title   = @"Date Plot";
        //self.section = kLinePlots;
    }
    
    return self;
}

-(void)generateData : (NSMutableArray *)dataPoints isTime: (BOOL)_isTimeData
{
  
  //Find minimum (start) date
  _minDate = nil;
  
  //Find maximum (end) date
  _maxDate = nil;
  
  _maxY = 0;
  
  for (DLDataPointRowObject* currObj in dataPoints)
  {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:currObj.DataTime];
    
    if(!_minDate) {
      _minDate = dateFromString;
    }
    
    if (!_maxDate) {
      _maxDate = dateFromString;
    }
    
    if ([dateFromString earlierDate:_minDate] == dateFromString) {
      _minDate = dateFromString;
    }
    
    if ([dateFromString laterDate:_maxDate] == dateFromString) {
      _maxDate = dateFromString;
    }
  }
  
  //Scale linearly
        //const NSTimeInterval oneDay = 24 * 60 * 60;
  
  NSMutableArray *newData = [NSMutableArray array];
  
  int idx = 0;
      
  for (DLDataPointRowObject* currObj in dataPoints)
  {
    NSString * time = currObj.DataTime;
    NSString * value = currObj.DataValue;
    
    idx++;
  
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:time];
    
    NSNumber *y;
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if (_isTimeData)
    {
      NSString *minutes = [value substringWithRange:NSMakeRange(0, 2)];
      NSString *seconds = [value substringWithRange:NSMakeRange(3, 2)];
      NSString *milliSeconds = [value substringWithRange:NSMakeRange(6, 2)];
      
      NSNumber *iMinutes = [f numberFromString:minutes];
      NSNumber *iSeconds = [f numberFromString:seconds];
      NSNumber *iMilliSeconds = [f numberFromString:milliSeconds];
      
      y = @([iMinutes intValue] * 60 + [iSeconds intValue] + [iMilliSeconds floatValue] / 100);
      
      
    } else {
      y = [f numberFromString:value];
    }
    
    if ([y floatValue] > _maxY) {
      _maxY = [y floatValue];
    }
    
    NSTimeInterval dateDiff = [dateFromString timeIntervalSinceDate:_minDate];
    dateDiff += (24 * 60 * 60) * idx;
    NSNumber *x = [NSNumber numberWithFloat:dateDiff];
    
    [newData addObject:
     @{ @(CPTScatterPlotFieldX): x,
        @(CPTScatterPlotFieldY): y }
     ];
  }
  
  plotData = newData;
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_minDate ];
  
#ifdef NSCalendarIdentifierGregorian
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
#endif
    NSDate *refDate = [gregorian dateFromComponents:dateComponents];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    
    layerHostingView.hostedGraph = graph;
    [graph applyTheme:theme];
    
    graph.title = @"TEST";
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round( bounds.size.height / CPTFloat(20.0) );
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.5) );
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    CGFloat boundsPadding = round( bounds.size.width / CPTFloat(20.0) ); // Ensure that padding falls on an integral pixel
    
    graph.paddingLeft = boundsPadding;
    
    if ( graph.titleDisplacement.y > 0.0 ) {
        graph.paddingTop = graph.titleTextStyle.fontSize * 2.0;
    }
    else {
        graph.paddingTop = boundsPadding;
    }
    
    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
    
    /*[self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];*/
  
    NSTimeInterval dateDiff = [_maxDate timeIntervalSinceDate:_minDate];
    int dayDiff = dateDiff / oneDay;
    if (dayDiff < 1) {
        dayDiff = 1;
    }
  
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(dayDiff * oneDay * 5)];
  
  NSTimeInterval yLow = -1.0;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(yLow) length:CPTDecimalFromFloat(_maxY)];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromFloat(oneDay);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    x.labelRotation             = M_PI_4;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay);
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
}

/*-(void)dealloc
{
    [plotData release];
    [super dealloc];
}*/

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return plotData[index][@(fieldEnum)];
}

@end
