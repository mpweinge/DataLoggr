//
//  DLNewDataViewController.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/14/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLDataRowObject;
@class DLHomeTableViewCell;

@protocol DLNewDataViewControllerDelegate

- (void) didCreateNewObject: (DLDataRowObject *) newObject;
- (void) didUpdateCell: (DLHomeTableViewCell *) updatedData withData: (DLDataRowObject *)newObject;

@end

@interface DLNewDataViewController : UIViewController

@property (nonatomic) id<DLNewDataViewControllerDelegate> delegate;

-(instancetype) initWithDelegate : (id<DLNewDataViewControllerDelegate>) delegate isEdit: (BOOL) isEdit cell:(DLHomeTableViewCell *)cell;

@end
