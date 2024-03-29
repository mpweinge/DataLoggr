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

- (instancetype) initWithName: (NSString *)DataName
                         type: (NSString *)DataType
                     iconName: (NSString *)IconName
                    unitsName:(NSString *)UnitsName
                     isLinear:(BOOL) isLinear;
{
  self = [super init];
  if (self) {
    _DataName = DataName;
    _DataType = DataType;
    _IconName = IconName;
    _UnitsName = UnitsName;
    _isLinear = isLinear;
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
  [values appendString:@"','"];
  [values appendString:_UnitsName];
  [values appendString:@"','"];
  [values appendFormat:@"%i", _isLinear];
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
  [values appendString:_DataType];
  [values appendString:@"\", "];
  
  [values appendString:ValuesArray[2]];
  [values appendString:@"= \""];
  [values appendString:_IconName];
  [values appendString:@"\", "];
  
  [values appendString:ValuesArray[3]];
  [values appendString:@"= \""];
  [values appendString:_UnitsName];
  [values appendString:@"\", "];
  
  [values appendString:ValuesArray[4]];
  [values appendString:@"= \""];
  [values appendFormat:@"%i", _isLinear];
  [values appendString:@"\" "];
  
  return values;
}

- (NSString* ) deleteString: (NSArray *)ValuesString
{
  NSMutableString * values = [NSMutableString string];
  
  [values appendString:ValuesString[0]];
  [values appendString:@"= \""];
  [values appendString:_DataName];
  /*[values appendString:@"\" AND "];
  
  [values appendString:ValuesString[1]];
  [values appendString:@"= \""];
  [values appendString:_DataType];
  [values appendString:@"\" AND "];
  
  [values appendString:ValuesString[2]];
  [values appendString:@"= \""];
  [values appendString:_IconName];*/
  [values appendString:@"\" "];
  
  return values;
}

- (NSString* ) valueAtIndex: (NSUInteger) index
{
  switch (index) {
    case 0:
      return _DataName;
    case 1:
      return _DataType;
    case 2:
      return _IconName;
    case 3:
      return _UnitsName;
    case 4:
      return [NSString stringWithFormat:@"%i", _isLinear ];
    default:
      assert(0);
      return nil;
  }
}

@end