//
//  DLDataPointRowObject.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/19/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDataPointRowObject : NSObject

@property (nonatomic, strong) NSString * DataName;
@property (nonatomic, strong) NSString * DataValue;
@property (nonatomic, strong) NSString * DataTime;

- (instancetype) initWithName: (NSString *)DataName value: (NSString *)DataType time: (NSString *)dataTime;

- (void) save;

@end
