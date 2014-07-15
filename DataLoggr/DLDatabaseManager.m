//
//  DLDatabaseManager.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDatabaseManager.h"

static DLDatabaseManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface DLDatabaseManager () {
  NSMutableDictionary* tableValues;
}

@end

@implementation DLDatabaseManager

+(DLDatabaseManager*)getSharedInstance
{
  if (!sharedInstance) {
    sharedInstance = [[super allocWithZone:NULL]init];
    [sharedInstance init];
  }
  return sharedInstance;
}

- (id) init
{
  self = [super init];
  tableValues = [[NSMutableDictionary alloc] init];
  return self;
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

-(BOOL) saveData : (NSString*) DatabaseName withObject:(id<DLSerializableProtocol>) object
{
  //Go to the dictionary to translate the database name into a series of properties

  //Check to make sure the serialized object has the same number of properties
  const char *dbpath = [databasePath UTF8String];
  
  if (sqlite3_open(dbpath, &database) == SQLITE_OK)
  {
    //Serialize the object
    NSString *objData = [object serializeData];
    NSMutableString *insertSQL = [NSMutableString string];
    [insertSQL appendString:@"INSERT INTO "];
    [insertSQL appendString: DatabaseName];
    [insertSQL appendString: tableValues[DatabaseName]];
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
      if (sqlite3_step(statement) == SQLITE_ROW)
      {
        NSString *name = [[NSString alloc] initWithUTF8String:
                          (const char *) sqlite3_column_text(statement, 0)];
        [resultArray addObject:name];
        return resultArray;
      }
      else{
        NSLog(@"Not found");
        return nil;
      }
      sqlite3_reset(statement);
    }
  }
  return nil;
}

@end
