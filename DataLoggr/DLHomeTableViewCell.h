//
//  DLHomeTableViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@class DLDataViewCell;

@protocol DLHomeTableViewCellDelegate

@required
- (void) CellViewTouched :(DLDataViewCell *) cell;

@end

@interface DLHomeTableViewCell : UITableViewCell

@property id <DLHomeTableViewCellDelegate> delegate;

@property(nonatomic, readwrite) NSString * title;
@property(nonatomic, readwrite) NSString * type;
@property(nonatomic, readwrite) NSString * notes;
@property(nonatomic, readwrite) NSString * time;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            caption:(NSString *)caption
               icon:(FAIcon)icon
               type:(NSString *)type;

@end
