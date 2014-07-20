//
//  DLDataViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLDataViewCell;

@protocol DLDataViewCellDelegate

@required
- (void) CellViewTouched :(DLDataViewCell *) cell;

@end

@interface DLDataViewCell : UITableViewCell

@property id <DLDataViewCellDelegate> delegate;

- (NSString *)getTitle;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              value:(NSString *)value
               time:(NSString *)time;

@end
