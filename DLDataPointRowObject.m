//
//  DLDataPointRowObject.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/19/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataPointRowObject.h"

#import "DLDatabaseManager.h"

@interface DLDataPointRowObject () < DLSerializableProtocol >
{
  NSMutableArray *_dataPoints;
}
@end

@implementation DLDataPointRowObject

- (instancetype) initWithName: (NSString *)DataName value: (NSString *)DataValue time: (NSString *)DataTime;
{
  self = [super init];
  if (self) {
    _DataName = DataName;
    _DataValue = DataValue;
    _DataTime = DataTime;
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
  [values appendString:@"')"];
  
  return values;
}

@end
