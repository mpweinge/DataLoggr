//
//  DLHomeGestureRecognizer.h
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-25.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLHomeGestureRecognizer : UIGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@property(nonatomic, readonly) BOOL userDidPress;

@end
