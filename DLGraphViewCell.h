//
//  DLGraphViewCell.h
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-21.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLGraphViewCellDelegate

-(void) scrollViewDidChangePage : (NSUInteger) pageNum;
@end

@interface DLGraphViewCell : UITableViewCell

@property (nonatomic, readwrite) id <DLGraphViewCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
         dataPoints:(NSMutableArray *)dataPoints
               type:(NSString *) type;

@end
