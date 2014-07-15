//
//  DLDataViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLDataViewCellDelegate

@required
- (void) CellViewTouched :(NSInteger) cellIdentifier;

@end

@interface DLDataViewCell : UITableViewCell

@property id <DLDataViewCellDelegate> delegate;

@end
