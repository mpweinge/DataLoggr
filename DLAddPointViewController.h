//
//  DLAddPointViewController.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/19/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLDataPointRowObject;
@class DLDataViewCell;

@protocol DLAddPointViewControllerDelegate

- (void) didCreateNewObject: (DLDataPointRowObject *) newObject;

@end

@interface DLAddPointViewController : UIViewController

@property (nonatomic) id<DLAddPointViewControllerDelegate> delegate;

-(instancetype) initWithSetName:(NSString *) setName
                       delegate:(id<DLAddPointViewControllerDelegate>) delegate
                          isAdd:(BOOL) isAdd
                       currCell:(DLDataViewCell *) currCell
                       typeName:(NSString *)typeName;

@end
