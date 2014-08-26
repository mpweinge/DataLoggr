//
//  DLCircleView.m
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-24.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLCircleView.h"

// A see through circle with just a border

@implementation DLCircleView
{
  CGFloat _strokeWidth;
  BOOL _selectFill;
  UIColor *_selectedColor;
}

- (id) initWithFrame:(CGRect) frame
           strokeWidth:(CGFloat) strokeWidth
            selectFill:(BOOL) selectFill
           selectColor:(UIColor *) selectedColor
{
  self = [super initWithFrame:frame];
  if (self) {
    _strokeWidth = strokeWidth;
    _selectFill = selectFill;
    _selectedColor = selectedColor;
  }
  return self;
}

- (id) initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _strokeWidth = 3.0f;
    _selectFill = YES;
    _selectedColor = [UIColor colorWithRed:0.25 green:0.25 blue:1 alpha:1.0];
  }
  return self;
}

- (void) drawRect:(CGRect)rect
{
  // Get the current graphics context
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
  CGContextFillRect(context, rect);
  
  if (_selected) {
    CGContextSetFillColorWithColor( context, _selectedColor.CGColor );
  } else {
    CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor );
  }
  
  CGRect EllipseRect = rect;
  EllipseRect.size.width -=_strokeWidth * 2;
    EllipseRect.size.height -=_strokeWidth * 2;
  
  EllipseRect.origin.x += _strokeWidth;
    EllipseRect.origin.y += _strokeWidth;
  
  CGContextFillEllipseInRect( context, EllipseRect );
  
  if (_selected) {
    CGContextSetStrokeColorWithColor(context, _selectedColor.CGColor);
    
    // Set the border width
    CGContextSetLineWidth(context, _strokeWidth);
    
    CGContextStrokeEllipseInRect( context, EllipseRect );
  } else {
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor);
    
    // Set the border width
    CGContextSetLineWidth(context, _strokeWidth);
    
    CGContextStrokeEllipseInRect( context, EllipseRect );
  }
}

@end
