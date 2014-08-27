//
//  DLHomeGestureRecognizer.m
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-25.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLHomeGestureRecognizer.h"

@implementation DLHomeGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  _userDidPress = YES;
  //[super touchesBegan:touches withEvent:event];
}

@end
