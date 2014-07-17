//
//  DLDataRowObject.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/17/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataRowObject.h"
#import "DLDatabaseManager.h"

@interface DLDataRowObject () < DLSerializableProtocol >
{
  NSMutableArray *_dataPoints;
}
@end

@implementation DLDataRowObject

- (instancetype) initWithName: (NSString *)DataName type: (NSString *)DataType iconName: (NSString *)IconName;
{
  self = [super init];
  if (self) {
    _DataName = DataName;
    _DataType = DataType;
    _IconName = IconName;
  }
  
  return self;
}

- (void) save
{
  [[DLDatabaseManager getSharedInstance] saveRow:self];
}

- (NSString* ) serializeData
{
  //Enumerate DataName + DataType + IconName into a proper form
  NSMutableString * values = [NSMutableString string];
  [values appendString:@"('"];
  [values appendString:_DataName];
  [values appendString:@"','"];
  [values appendString:_DataType];
  [values appendString:@"','"];
  [values appendString:_IconName];
  [values appendString:@"')"];
  
  return values;
}

@end