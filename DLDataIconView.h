//
//  DLDataTypeViewController.h
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-20.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@class DLDataIconView;

@protocol DLDataIconViewDelegate

-(void) iconClicked:(DLDataIconView *) icon;

@end

@interface DLDataIconView : UIView

@property (nonatomic, readwrite, retain) id<DLDataIconViewDelegate> delegate;
@property (nonatomic) BOOL selected;
@property (nonatomic, readonly, getter = getTitle) NSString *title;

-(id) initWithFrame:(CGRect) frame
               icon:(FAIcon) icon
              title:(NSString*)title;

@end
