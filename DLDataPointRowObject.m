//
//  DLDataPointRowObject.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/19/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataPointRowObject.h"

@interface DLDataPointRowObject () 
{
  NSMutableArray *_dataPoints;
}
@end

@implementation DLDataPointRowObject

- (instancetype) initWithName: (NSString *)DataName
                        value: (NSString *)DataValue
                         time: (NSString *)DataTime
                        notes: (NSString *)DataNotes;
{
  self = [super init];
  if (self) {
    _DataName = DataName;
    _DataValue = DataValue;
    _DataTime = DataTime;
    _DataNotes = DataNotes;
  }
  
  return self;
}

- (void) save
{
  [[DLDatabaseManager getSharedInstance] savePoint:self];
}

- (NSString* ) serializeData
{
  //Enumerate DataName + DataType + IconName into a proper form
  NSMutableString * values = [NSMutableString string];
  [values appendString:@"('"];
  [values appendString:_DataName];
  [values appendString:@"','"];
  [values appendString:_DataValue];
  [values appendString:@"','"];
  [values appendString:_DataTime];
  [values appendString:@"','"];
  [values appendString:_DataNotes];
  [values appendString:@"')"];
  
  return values;
}

- (NSString *) updateValuesString: (NSArray *)ValuesArray
{
  NSMutableString * values = [NSMutableString string];
  
  [values appendString:ValuesArray[0]];
  [values appendString:@"= \""];
  [values appendString:_DataName];
  [values appendString:@"\", "];
  
  [values appendString:ValuesArray[1]];
  [values appendString:@"= \""];
  [values appendString:_DataValue];
  [values appendString:@"\", "];
  
  [values appendString:ValuesArray[2]];
  [values appendString:@"= \""];
  [values appendString:_DataTime];
  [values appendString:@"\", "];
  
  [values appendString:ValuesArray[3]];
  [values appendString:@"= \""];
  [values appendString:_DataNotes];
  [values appendString:@"\""];
  
  return values;
}

- (NSString* ) valueAtIndex: (NSUInteger) index
{
  switch (index) {
    case 0:
      return _DataName;
    case 1:
      return _DataValue;
    case 2:
      return _DataTime;
    case 3:
      return _DataNotes;
    default:
      assert(0);
      return nil;
  }
}

@end
