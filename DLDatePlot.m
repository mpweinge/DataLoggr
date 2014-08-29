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
  
  //NSMutableArray *newDataPoints = [NSMutableArray array];
  
  /*for (int i = 0; i < 20; i++)
  {
    NSString *value;
    if ( i < 10 ) {
        value = [NSString stringWithFormat:@"00:00:0%i", i];
    } else {
      value = [NSString stringWithFormat:@"00:00:%i", i];
    }
    NSString *time;
    if (i < 9) {
      time = [NSString stringWithFormat:@"8/25/14, 1:0%i am", (i+1)];
    } else {
      time = [NSString stringWithFormat:@"8/25/14, 1:%i am", i+1 ];
    }
    DLDataPointRowObject *newObj = [[DLDataPointRowObject alloc] initWithName:@"TEST" value:value time:time notes:@""];
    [newDataPoints addObject:newObj];
  }*/
  
  /*for (int i = 0; i < 20; i++)
  {
    NSString *value;
    if ( i < 10 ) {
      value = [NSString stringWithFormat:@"00:00:0%i", i];
    } else {
      value = [NSString stringWithFormat:@"00:00:%i", i];
    }
    NSString *time;
    if (i < 9) {
      time = [NSString stringWithFormat:@"8/25/14, %i:00 am", (i+1)];
    } else {
      time = [NSString stringWithFormat:@"8/26/14, %i:00 am", i - 9 ];
    }
    DLDataPointRowObject *newObj = [[DLDataPointRowObject alloc] initWithName:@"TEST" value:value time:time notes:@""];
    [newDataPoints addObject:newObj];
  }*/
  
  /*for (int i = 0; i < 20; i++)
  {
    NSString *value;
    if ( i < 10 ) {
      value = [NSString stringWithFormat:@"00:00:0%i", i];
    } else {
      value = [NSString stringWithFormat:@"00:00:%i", i];
    }
    NSString *time;
    //if (i < 9) {
      time = [NSString stringWithFormat:@"8/%i/14, 1:00 am", (i+1)];
    DLDataPointRowObject *newObj = [[DLDataPointRowObject alloc] initWithName:@"TEST" value:value time:time notes:@""];
    [newDataPoints addObject:newObj];
  }*/
  
  //dataPoints = newDataPoints;
  
  for (DLDataPointRowObject* currObj in dataPoints)
  {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *dateFromString = [[NSDate alloc] init];
    // time = @"08/26/14";
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
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *dateFromString = [[NSDate alloc] init];
   // time = @"08/26/14";
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
    //dateDiff *= -1;
    //dateDiff += (24 * 60 * 60) * idx;
    NSNumber *x = [NSNumber numberWithFloat:dateDiff];
    
    if (_minDate == _maxDate) {
      NSNumber *x = [NSNumber numberWithFloat:(dateDiff + (idx-1))];
      [newData addObject:@{ @(CPTScatterPlotFieldX): x,
                            @(CPTScatterPlotFieldY): y }];
    } else {
      [newData addObject:
       @{ @(CPTScatterPlotFieldX): x,
          @(CPTScatterPlotFieldY): y }
       ];
    }
    
    if ([dataPoints count] == 1) {
      NSNumber *x = [NSNumber numberWithFloat:(dateDiff + 1)];
      [newData addObject:@{ @(CPTScatterPlotFieldX): x,
                            @(CPTScatterPlotFieldY): y }];
    }
  }
  
  plotData = newData;
  
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_minDate ];
  
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
    graph.plotAreaFrame.borderLineStyle = nil;
    
    //graph.title = @"TEST";
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round( bounds.size.height / CPTFloat(20.0) );
    
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
  
    NSTimeInterval dateDiff = [_maxDate timeIntervalSinceDate:_minDate];
    float dayDiff = (int)(dateDiff / oneDay);
  
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow       = -dayDiff * oneDay / 5.0;
  
    if (dateDiff == 0) {
      dateDiff = [plotData count] - 1;
    }
  
  if (dayDiff < 4 ) {
    dayDiff = dateDiff / oneDay;
    xLow = -dayDiff * oneDay / 3.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble( fabs(xLow) + (dayDiff * oneDay) * 1.5 )];
  }
  
  NSTimeInterval yLow = -(fabs(_maxY) / 7.0);
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(yLow) length:CPTDecimalFromFloat(fabs(_maxY) + 2 * (fabs(_maxY) / 5.0))];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
  if ( dayDiff < 4 ) {
    x.majorIntervalLength         = CPTDecimalFromFloat( (dayDiff * oneDay) * 1);
  } else {
    x.majorIntervalLength         = CPTDecimalFromFloat( (dayDiff * oneDay) / 4.0);
  }
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
  
  if (dayDiff < 4) {
    dateFormatter.timeStyle = kCFDateFormatterShortStyle;
  }
  
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    //x.labelRotation             = M_PI_4;
  
    CPTXYAxis *y = axisSet.yAxis;

    y.majorIntervalLength         = CPTDecimalFromDouble((fabs(_maxY)) / 5.0);
    y.minorTicksPerInterval       = 4;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
    NSNumberFormatter *yAxisFormatter = [[NSNumberFormatter alloc] init];

    if ( fabs(_maxY) < 5.0) {
      [yAxisFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
      [yAxisFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
      int digitNum = -1 * log10f(_maxY / 5) + 1;
      [yAxisFormatter setMinimumFractionDigits:digitNum];
      [yAxisFormatter setMaximumFractionDigits:digitNum];
      
     // plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow + xLow / 5 * digitNum) length:CPTDecimalFromDouble( fabs(dayDiff * oneDay) + 2 * (fabs(dayDiff * oneDay) / 5.0) )];
    } else {
      [yAxisFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
      [yAxisFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
      [yAxisFormatter setMinimumFractionDigits:0];
      [yAxisFormatter setMaximumFractionDigits:0];
    }
    y.labelFormatter = yAxisFormatter;
  
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor redColor];
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
