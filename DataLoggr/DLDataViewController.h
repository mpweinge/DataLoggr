//
//  DLDataViewController.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLDataViewCellDelegate;

@interface DLDataViewController : UIViewController < UITableViewDataSource, DLDataViewCellDelegate >

-(instancetype) initWithDataValue: (NSInteger) cellIdentifier;

@end
