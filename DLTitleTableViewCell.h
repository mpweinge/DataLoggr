//
//  DLTitleTableViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLTitleTableViewCellDelegate

@required
-(void) CellViewTouched:(NSInteger) number;

@end

@interface DLTitleTableViewCell : UITableViewCell

@property id <DLTitleTableViewCellDelegate> delegate;

@end
