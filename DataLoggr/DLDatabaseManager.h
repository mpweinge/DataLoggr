//
//  DLDatabaseManager.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

//Database to store rows of data

@protocol DLSerializableProtocol

@required
//INSERT INTO DATABASE(x, x, x) VALUES (x, x, x)
- (NSString* ) serializeData;
- (NSString* ) updateValuesString: (NSArray *)ValuesString;
- (NSString* ) deleteString: (NSArray *)ValuesString;
- (NSString* ) valueAtIndex: (NSUInteger) index;

@end

@interface DLDatabaseManager : NSObject
{
  NSString *databasePath;
}

+(DLDatabaseManager *)getSharedInstance;

-(BOOL)createTable:(NSString *)tableName withFields: (NSArray *)fields;

-(BOOL)savePoint: (id<DLSerializableProtocol>) dataPoint;

-(BOOL)saveRow: (id<DLSerializableProtocol>) row;

-(NSMutableArray *) fetchDataPoints: (NSString *) setName;

-(NSMutableArray *) fetchDataNames;

-(NSMutableArray *) fetchData : (NSString *)databaseName;

- (BOOL) updateOldPoint: (id<DLSerializableProtocol>) oldDataPoint newPoint: (id<DLSerializableProtocol>) newPoint;

- (BOOL) updateOldRow: (id<DLSerializableProtocol>) oldRow withNewRow:(id<DLSerializableProtocol>) newRow;

- (BOOL) updateOldRow:(id<DLSerializableProtocol>)oldRow withNewLinear:(int) isLinear;

- (BOOL) updateOldRow:(id<DLSerializableProtocol>)oldRow withNewUnits:(NSString *)units;

- (BOOL) deleteDataType: (id<DLSerializableProtocol>) row;

- (BOOL) deleteDataPoint: (id<DLSerializableProtocol>) point;

- (NSString *) fetchLastUpdatedTime: (NSString *) setName;

-(BOOL) hasNameConflict: (NSString *)name;

@end
