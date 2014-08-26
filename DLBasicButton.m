//
//  DLBasicButton.m
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-25.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLBasicButton.h"

@implementation DLBasicButton

- (void) drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
  
  UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: 10];
  // Use the bezier as a clipping path
  [roundedRectanglePath addClip];
  
  CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
  CGContextSetLineWidth(context, 3.0f);
  CGContextStrokeEllipseInRect(context, rect);
  
  CGContextFillRect(context, rect);
}

@end
