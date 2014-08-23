//
//  DLDatabaseManager.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDatabaseManager.h"
#import "DLDataRowObject.h"
#import "DLDataPointRowObject.h"

static DLDatabaseManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

static NSString* kDataPointDatabaseName = @"DataPoints";
static NSString* kDataTypeName = @"DataTypes";

@interface DLDatabaseManager () {
  NSMutableDictionary* tableValues;
  NSArray* _dataPointFieldNames;
  NSArray* _dataTypeFieldNames;
}

@end

@implementation DLDatabaseManager

+(DLDatabaseManager*)getSharedInstance
{
  if (!sharedInstance) {
    sharedInstance = [[super allocWithZone:NULL]init];
  }
  return sharedInstance;
}

- (id) init
{
  self = [super init];
  tableValues = [[NSMutableDictionary alloc] init];
  [self SetupDatabase];
  return self;
}

- (void) SetupDatabase
{
  NSArray *dataPointFields = @[ @"DataName text", @"DataValue text", @"AddTime text", @"Notes text" ];
  _dataPointFieldNames = @[ @"DataName", @"DataValue", @"AddTime", @"Notes"];
  [self createTable:kDataPointDatabaseName withFields:dataPointFields];
  
  NSArray *dataTypeFields = @[ @"DataName text primary key", @"DataType text", @"icon text" ];
  _dataTypeFieldNames = @[ @"DataName", @"DataType", @"icon" ];
  [self createTable:kDataTypeName withFields:dataTypeFields];
}

-(BOOL)createTable:(NSString *)tableName withFields: (NSArray *)fields
{
  NSString *docsDir;
  NSArray *dirPaths;
  // Get the documents directory
  dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  docsDir = dirPaths[0];
  
  // Build the path to the database file
  databasePath = [[NSString alloc] initWithString:
          [docsDir stringByAppendingPathComponent: @"student.db"]];
  
  BOOL isSuccess = YES;
  NSFileManager *filemgr = [NSFileManager defaultManager];
  
 // if ([filemgr fileExistsAtPath: databasePath ] == NO)
  {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
      char *errMsg;
      //const char *sql_stmt =
      //"create table if not exists studentsDetail (regno integer, primary key, name text, department text, year text)";
      
      NSMutableString *sql_stmt = [NSMutableString string];
      [sql_stmt appendString:@"CREATE TABLE IF NOT EXISTS "];
      
      [sql_stmt appendString:tableName];
      
      NSMutableString *values = [NSMutableString string];
      NSMutableString *valueNames = [NSMutableString string];
      
      [values appendString:@"("];
      [valueNames appendString:@"("];
      
      int numFields = [fields count];
      
      for (int i = 0; i < numFields; i++)
      {
        [values appendString:fields[i]];
        
        NSRange currRange = [fields[i] rangeOfString:@" "];
        currRange.length = currRange.location;
        currRange.location = 0;
        
        [valueNames appendString:[fields[i] substringWithRange:currRange]];
        
        if (i != numFields - 1) {
          [values appendString:@","];
          [valueNames appendString:@","];
        }
      }
      
      [values appendString:@")"];
      [valueNames appendString:@")"];
      
      [sql_stmt appendString:values];
      
      [tableValues setValue:valueNames forKey:tableName];
      
      if (sqlite3_exec(database, [sql_stmt UTF8String], NULL, NULL, &errMsg)
          != SQLITE_OK)
      {
        isSuccess = NO;
        NSLog(@"Failed to create table");
      }
      sqlite3_close(database);
      return  isSuccess;
    }
    else {
      isSuccess = NO;
      NSLog(@"Failed to open/create database");
    }
  }
  return isSuccess;
}

- (BOOL) savePoint: (id<DLSerializableProtocol>) dataPoint
{
  //Check to make sure the serialized object has the same number of properties
  const char *dbpath = [databasePath UTF8String];
  
  if (sqlite3_open(dbpath, &database) == SQLITE_OK)
  {
    //Serialize the object
    NSString *objData = [dataPoint serializeData];
    NSMutableString *insertSQL = [NSMutableString string];
    [insertSQL appendString:@"INSERT INTO "];
    [insertSQL appendString: kDataPointDatabaseName];
    [insertSQL appendString: tableValues[kDataPointDatabaseName]];
    [insertSQL appendString: @" VALUES"];
    [insertSQL appendString: objData];
    
    const char *insert_stmt = [insertSQL UTF8String];
    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
    if (sqlite3_step(statement) == SQLITE_DONE)
    {
      return YES;
    }
    else {
      return NO;
    }
    sqlite3_reset(statement);
  }
  //INSERT INTO DATABASENAME(x, x, x) VALUES(x, x, x)
  return NO;
}

- (BOOL) updateOldPoint: (id<DLSerializableProtocol>) oldDataPoint newPoint: (id<DLSerializableProtocol>) newPoint
{
  //Check to make sure the serialized object has the same number of properties
  const char *dbpath = [databasePath UTF8String];
  
  if (sqlite3_open(dbpath, &database) == SQLITE_OK)
  {
    //Serialize the object
    //NSString *objData = [dataPoint serializeData];

    NSMutableString *insertSQL = [NSMutableString string];
    [insertSQL appendString:@"UPDATE "];
    [insertSQL appendString: kDataPointDatabaseName];
    [insertSQL appendString: @" SET "];
    [insertSQL appendString:[newPoint updateValuesString: _dataPointFieldNames ]];
    
    [insertSQL appendString: @"WHERE "];
    [insertSQL appendString: _dataPointFieldNames[0]];
    [insertSQL appendString: @"= \""];
    [insertSQL appendString: [oldDataPoint valueAtIndex:0]];
    
    [insertSQL appendString: @"\" AND "];
    
    [insertSQL appendString: _dataPointFieldNames[1]];
    [insertSQL appendString: @" = \""];
    [insertSQL appendString: [oldDataPoint valueAtIndex:1]];
    
    [insertSQL appendString: @"\" AND "];
    
    [insertSQL appendString: _dataPointFieldNames[2]];
    [insertSQL appendString: @" = \""];
    [insertSQL appendString: [oldDataPoint valueAtIndex:2]];
    [insertSQL appendString: @"\""];
    
    const char *insert_stmt = [insertSQL UTF8String];
    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
    if (sqlite3_step(statement) == SQLITE_DONE)
    {
      return YES;
    }
    else {
      return NO;
    }
    sqlite3_reset(statement);
  }
  //INSERT INTO DATABASENAME(x, x, x) VALUES(x, x, x)
  return NO;
}

-(BOOL)saveRow: (id<DLSerializableProtocol>) row
{
  //Go to the dictionary to translate the database name into a series of properties

  //Check to make sure the serialized object has the same number of properties
  const char *dbpath = [databasePath UTF8String];
  
  if (sqlite3_open(dbpath, &database) == SQLITE_OK)
  {
    //Serialize the object
    NSString *objData = [row serializeData];
    NSMutableString *insertSQL = [NSMutableString string];
    [insertSQL appendString:@"INSERT INTO "];
    [insertSQL appendString: kDataTypeName];
    [insertSQL appendString: tableValues[kDataTypeName]];
    [insertSQL appendString: @" VALUES"];
    [insertSQL appendString: objData];
    
    const char *insert_stmt = [insertSQL UTF8String];
    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
    if (sqlite3_step(statement) == SQLITE_DONE)
    {
      return YES;
    }
    else {
      return NO;
    }
    sqlite3_reset(statement);
  }
  //INSERT INTO DATABASENAME(x, x, x) VALUES(x, x, x)
  return NO;
}

- (NSMutableArray *) fetchDataNames
{
  return [self fetchData:kDataTypeName];
}

- (NSMutableArray *)fetchDataPoints : (NSString *) setName
{
  const char *dbpath = [databasePath UTF8String];
  if (sqlite3_open(dbpath, &database) == SQLITE_OK)
  {
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DataName = '%@'", kDataPointDatabaseName, setName];
    //NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@ ", kDataPointDatabaseName];
    const char *query_stmt = [querySQL UTF8String];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(database,
                           query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
      while (sqlite3_step(statement) == SQLITE_ROW)
      {
        NSString *dataName = [[NSString alloc] initWithUTF8String:
                              (const char *) sqlite3_column_text(statement, 0)];
        NSString *dataValue = [[NSString alloc] initWithUTF8String:
                              (const char *) sqlite3_column_text(statement, 1)];
        NSString *dataTime = [[NSString alloc] initWithUTF8String:
                              (const char *) sqlite3_column_text(statement, 2)];
        NSString *dataNotes = [[NSString alloc] initWithUTF8String:
                              (const char *) sqlite3_column_text(statement, 3)];
        
        [resultArray addObject:[[DLDataPointRowObject alloc] initWithName:dataName
                                                                    value:dataValue
                                                                     time: dataTime
                                                                    notes:dataNotes]];
      }
      return resultArray;
      sqlite3_reset(statement);
    }
  }
  return nil;
}

-(NSMutableArray *) fetchData : (NSString *)databaseName
{
  const char *dbpath = [databasePath UTF8String];
  if (sqlite3_open(dbpath, &database) == SQLITE_OK)
  {
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@", databaseName];
    const char *query_stmt = [querySQL UTF8String];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(database,
                           query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
      while (sqlite3_step(statement) == SQLITE_ROW)
      {
        NSString *dataName = [[NSString alloc] initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
        NSString *dataType = [[NSString alloc] initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 1)];
        NSString *dataIcon = [[NSString alloc] initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 2)];
        
        [resultArray addObject:[[DLDataRowObject alloc] initWithName:dataName type:dataType iconName:dataIcon]];
      }
      return resultArray;
      sqlite3_reset(statement);
    }
  }
  return nil;
}

@end
