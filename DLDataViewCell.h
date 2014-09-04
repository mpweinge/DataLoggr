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
@class DLDataRowObject;

@protocol DLDataViewCellDelegate

@required
- (void) CellViewTouched :(DLDataViewCell *) cell;
- (void) DeleteRowClicked:(DLDataViewCell *) cell;

@end

@interface DLDataViewCell : UITableViewCell

@property(nonatomic, readwrite) id <DLDataViewCellDelegate> delegate;

@property(nonatomic, readwrite) NSString * title;
@property(nonatomic, readwrite) NSString * type;
@property(nonatomic, readwrite) NSString * notes;
@property(nonatomic, readwrite) NSString * time;

-(DLDataPointRowObject *) dataPoint;

- (DLDataRowObject *) dataObject;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               name:(NSString *)name
              value:(NSString *)value
               time:(NSString *)time
               type:(NSString *)type
              notes:(NSString *)notes
    dataPointObject:(DLDataPointRowObject *)dataObject
            pageNum:(NSInteger) page
              units:(NSInteger) units
         dataObject:(DLDataRowObject *)dataObject;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               name:(NSString *)name
              value:(NSString *)value
               time:(NSString *)time
               type:(NSString *)type
              notes:(NSString *)notes
    dataPointObject:(DLDataPointRowObject *)dataObject
            pageNum:(NSInteger) page
        stringUnits:(NSString *) units
         dataObject:(DLDataRowObject *)dataObject;

-(void) graphViewDidScroll:(NSUInteger)pageNum;

-(void) didChangeUnits:(NSInteger) units;

-(void) didChangeUnitString:(NSString *) unitString;

@end
