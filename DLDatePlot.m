//
//  DatePlot.m
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "DLDatePlot.h"
#import "DLDataPointRowObject.h"
#import "CPTTextLayer.h"

@implementation DLDatePlot
{
  NSDate *_minDate;
  NSDate *_maxDate;
  float _maxY;
  int _val;
}

-(id)init
{
    if ( (self = [super init]) ) {
        //self.title   = @"Date Plot";
        //self.section = kLinePlots;
      _val = -1;
    }
    
    return self;
}

-(void)generateData : (NSMutableArray *)dataPoints type: (NSString *)type valueNum:(int) val
{
  assert([type isEqualToString:@"GPS"]);
  
  _val = val;
  
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

    //Read until colon for time:
    int colonIdx = 0;
    int commaIdx = 0;
    int i = 0;
    for (i = 0; i < [value length]; i++ )
    {
      if ([value characterAtIndex:i] == ':') {
        colonIdx = i;
      } else if ([value characterAtIndex:i] == ',') {
        commaIdx = i;
        break;
      }
    }

    NSString *floatSubstr= [value substringWithRange:NSMakeRange(colonIdx + 2, commaIdx - colonIdx - 2)];
    
    float timeValue = [ floatSubstr floatValue];
    
    i +=2;
    
    for (i; i < [value length]; i++ )
    {
      if ([value characterAtIndex:i] == ':') {
        colonIdx = i;
      } else if ([value characterAtIndex:i] == ',') {
        commaIdx = i;
        break;
      }
    }
    
    NSString *distSubstr= [value substringWithRange:NSMakeRange(colonIdx + 2, commaIdx - colonIdx - 2)];
    
    float distValue = [ distSubstr floatValue];
    
    if (timeValue < 0)
      timeValue *= -1;
    
    if (val == 0) {
      y = @(distValue / timeValue);
    } else if (val == 1) {
      y = @(distValue);
    } else if (val == 2) {
      y = @(timeValue);
    } else {
      assert(0);
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
    
    /*if ([dataPoints count] == 1) {
      NSNumber *x = [NSNumber numberWithFloat:(dateDiff + 1)];
      [newData addObject:@{ @(CPTScatterPlotFieldX): x,
                            @(CPTScatterPlotFieldY): y }];
    }*/
  }
  
  plotData = newData;
}

-(void)generateData : (NSMutableArray *)dataPoints type: (NSString *)type
{
  _val = -1;
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
    
    if ([type isEqualToString:@"Time"])
    {
      NSString *minutes = [value substringWithRange:NSMakeRange(0, 2)];
      NSString *seconds = [value substringWithRange:NSMakeRange(3, 2)];
      NSString *milliSeconds = [value substringWithRange:NSMakeRange(6, 2)];
      
      NSNumber *iMinutes = [f numberFromString:minutes];
      NSNumber *iSeconds = [f numberFromString:seconds];
      NSNumber *iMilliSeconds = [f numberFromString:milliSeconds];
      
      y = @([iMinutes intValue] * 60 + [iSeconds intValue] + [iMilliSeconds floatValue] / 100);
      
      
    } else if ([type isEqualToString:@"GPS"]){
      //Read until colon for time:
      int colonIdx = 0;
      int commaIdx = 0;
      int i = 0;
      for (i = 0; i < [value length]; i++ )
      {
        if ([value characterAtIndex:i] == ':') {
          colonIdx = i;
        } else if ([value characterAtIndex:i] == ',') {
          commaIdx = i;
          break;
        }
      }
      
      NSString *floatSubstr= [value substringWithRange:NSMakeRange(colonIdx + 2, commaIdx - colonIdx - 2)];
      
      float timeValue = [ floatSubstr floatValue];
      
      if (timeValue < 0)
        timeValue *= -1;
      
      /*for (i; i < [value length]; i++ )
      {
        if ([value characterAtIndex:i] == ':') {
          colonIdx = i;
        } else if ([value characterAtIndex:i] == ',') {
          commaIdx = i;
          break;
        }
      }
      
      float distValue = [value substringWithRange:[NSRange NSMakeRange(colonIdx, commaIdx - colonIdx)]];*/
      
      y = @(timeValue);
      
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
    
    /*if ([dataPoints count] == 1) {
      NSNumber *x = [NSNumber numberWithFloat:(dateDiff + 1)];
      [newData addObject:@{ @(CPTScatterPlotFieldX): x,
                            @(CPTScatterPlotFieldY): y }];
    }*/
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
  
    if (_val >= 0) {
      if (_val == 0) {
        graph.title = @"Distance vs Time";
      } else if (_val == 1) {
        graph.title = @"Distance";
      } else if (_val == 2) {
        graph.title = @"Time";
      } else {
        assert(0);
      }
    }
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
    xLow = 0;
    
    if ([plotData count] == 1) {
      plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5) length:CPTDecimalFromDouble(1)];
    } else {
      plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble( fabs(xLow) + (dayDiff * oneDay)  )];
    }
  } else {
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble( fabs(xLow) + (dayDiff * oneDay))];
  }
  
  graph.plotAreaFrame.paddingTop = 2.0f;
  graph.plotAreaFrame.paddingRight = 55.0f;
  graph.plotAreaFrame.paddingBottom = 30.0f;
  graph.plotAreaFrame.paddingLeft = 44.0f;
  
  NSTimeInterval yLow = 0;
  
  if (_maxY == 0) {
    _maxY = 1.0;
  }
  
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(yLow) length:CPTDecimalFromFloat(fabs(_maxY) + 2 * (fabs(_maxY) / 5.0))];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
  
  if ( dayDiff < 4 ) {
    if ([plotData count] == 1) {
      x.majorIntervalLength = CPTDecimalFromInt(1);
    } else {
      x.majorIntervalLength         = CPTDecimalFromFloat( (dayDiff * oneDay) * 1);
    }
  } else {
    x.majorIntervalLength         = CPTDecimalFromFloat( (dayDiff * oneDay) / 4.0);
  }
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.minorTicksPerInterval       = 0;
  
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
  
  if (dayDiff < 4) {
    dateFormatter.timeStyle = kCFDateFormatterShortStyle;
    dateFormatter.dateFormat = @" MM/dd/yy\nhh:mm a";
    graph.plotAreaFrame.paddingBottom = 50.0f;
  }
  
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    //x.labelRotation             = M_PI_4;
  
    CPTXYAxis *y = axisSet.yAxis;

    y.majorIntervalLength         = CPTDecimalFromDouble((fabs(_maxY)) / 5.0);
    y.minorTicksPerInterval       = 4;
  
  if ([plotData count] == 1) {
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(-0.5);
    graph.plotAreaFrame.paddingLeft = 30.0f;
  } else {
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
  }
    NSNumberFormatter *yAxisFormatter = [[NSNumberFormatter alloc] init];

    if ( fabs(_maxY) < 5.0) {
      [yAxisFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
      [yAxisFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
      int digitNum = -1 * log10f(_maxY / 5) + 1;
      [yAxisFormatter setMinimumFractionDigits:digitNum];
      [yAxisFormatter setMaximumFractionDigits:digitNum];
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
  
  if ([plotData count] == 1) {
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol]; // Ellipse is used for circles
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor redColor]];
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    
    // Set the line style of the edges of your symbol. (Around your symbol)
    CPTMutableLineStyle *plotSymbolLineStyle = [[CPTMutableLineStyle alloc] init];
    plotSymbolLineStyle.lineColor = [CPTColor blackColor];
    plotSymbolLineStyle.lineWidth = 1.0f;
    plotSymbol.lineStyle = plotSymbolLineStyle;
    
    dataSourceLinePlot.plotSymbol = plotSymbol;
    
  }
    
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

+(CPTAxisLabel *) buildAxisLabelAtLocation:(CGFloat)location withText:(NSString *)text
{
  CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:@"TEST"];
  CPTTextLayer *textLayer2 = [[CPTTextLayer alloc] initWithText:@"NULL"];
  [textLayer addSublayer:textLayer2];
  CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithContentLayer:textLayer];
  axisLabel.offset = 8;
  axisLabel.tickLocation = CPTDecimalFromCGFloat(location);
  return axisLabel;
}

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
