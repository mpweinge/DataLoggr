//
//  DLExtendedScrollView.m
//  DataLoggr
//
//  Created by Michael Weingert on 2014-09-01.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLExtendedScrollView.h"

@implementation DLExtendedScrollView
{
  UIScrollView *_scrollView;
}

- (id) initWithFrame:(CGRect)frame andScrollView: (UIScrollView *)scrollView
{
  self = [super initWithFrame:frame];
  if (self)
  {
    _scrollView = scrollView;
  }
  return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  if ([self pointInside:point withEvent:event]) {
    return _scrollView;
  }
  return nil;
}

@end
