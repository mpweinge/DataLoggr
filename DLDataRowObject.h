//
//  DLDataRowObject.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/17/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDataRowObject : NSObject

@property (nonatomic, strong) NSString * DataName;
@property (nonatomic, strong) NSString * DataType;
@property (nonatomic, strong) NSString * IconName;

- (instancetype) initWithName: (NSString *)DataName type: (NSString *)DataType iconName: (NSString *)IconName;

- (void) save;

@end
