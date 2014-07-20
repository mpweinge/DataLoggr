//
//  DLHomeViewController.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLHomeTableViewCellDelegate;
@protocol DLTitleTableViewCellDelegate;
@protocol DLNewDataViewControllerDelegate;

@interface DLHomeViewController : UIViewController <
  UITableViewDataSource,
  DLHomeTableViewCellDelegate,
  DLTitleTableViewCellDelegate,
  DLNewDataViewControllerDelegate>

@end
