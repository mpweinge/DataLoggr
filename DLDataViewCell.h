//
//  DLDataViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLDataViewCell;
@class DLDataPointRowObject;

@protocol DLDataViewCellDelegate

@required
- (void) CellViewTouched :(DLDataViewCell *) cell;

@end

@interface DLDataViewCell : UITableViewCell

@property(nonatomic, readwrite) id <DLDataViewCellDelegate> delegate;

@property(nonatomic, readwrite) NSString * title;
@property(nonatomic, readwrite) NSString * type;
@property(nonatomic, readwrite) NSString * notes;
@property(nonatomic, readwrite) NSString * time;

-(DLDataPointRowObject *) dataPoint;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               name:(NSString *)name
              value:(NSString *)value
               time:(NSString *)time
              notes:(NSString *)notes
         dataObject:(DLDataPointRowObject *)dataObject;

@end
