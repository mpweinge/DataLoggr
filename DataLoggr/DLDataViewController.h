//
//  DLDataViewController.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLDataViewCellDelegate;
@protocol DLTitleTableViewCellDelegate;
@protocol DLAddPointViewControllerDelegate;
@class DLDataRowObject;

@interface DLDataViewController : UIViewController <
  UITableViewDataSource,
  DLDataViewCellDelegate,
  DLTitleTableViewCellDelegate,
  DLAddPointViewControllerDelegate,
  UITableViewDelegate>

-(instancetype) initWithDataValue: (NSString*) setName
                         dataType: (NSString *)dataType
                       dataObject: (DLDataRowObject *)dataObject;

@end
