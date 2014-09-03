//
//  DLEditableLabel.m
//  DataLoggr
//
//  Created by Michael Weingert on 2014-09-03.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLNoCaretTextView.h"

@implementation DLNoCaretTextView

- (CGRect)caretRectForPosition:(UITextPosition *)position {
  return CGRectZero;
}

@end
