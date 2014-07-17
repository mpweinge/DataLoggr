//
//  DLHomeTableViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@protocol DLHomeTableViewCellDelegate

@required
- (void) CellViewTouched :(NSInteger) cellIdentifier;

@end

@interface DLHomeTableViewCell : UITableViewCell

@property id <DLHomeTableViewCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            caption:(NSString *)caption
               icon:(FAIcon)icon;

@end
