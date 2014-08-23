//
//  DLDataPointRowObject.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/19/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLDatabaseManager.h"

@interface DLDataPointRowObject : NSObject < DLSerializableProtocol >

@property (nonatomic, strong) NSString * DataName;
@property (nonatomic, strong) NSString * DataValue;
@property (nonatomic, strong) NSString * DataTime;
@property (nonatomic, strong) NSString * DataNotes;

- (instancetype) initWithName: (NSString *)DataName
                        value: (NSString *)DataType
                         time: (NSString *)dataTime
                        notes: (NSString *)dataNotes;

- (void) save;

@end
