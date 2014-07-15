//
//  DLHomeTableViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLHomeTableViewCellDelegate

@required
- (void) CellViewTouched :(NSInteger) cellIdentifier;

@end

@interface DLHomeTableViewCell : UITableViewCell

@property id <DLHomeTableViewCellDelegate> delegate;

@end
