//
//  DLCircleView.h
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-24.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLCircleView : UIView

@property (nonatomic, readwrite) BOOL selected;

- (id) initWithFrame:(CGRect) frame
           strokeWidth:(CGFloat) floatWidth
            selectFill:(BOOL) selectFill
           selectColor:(UIColor *) selectedColor;

- (id) initWithFrame:(CGRect) frame
         strokeWidth:(CGFloat) strokeWidth
          selectFill:(BOOL) selectFill
         selectColor:(UIColor *) selectedColor
       boundaryColor:(UIColor *)boundaryColor;

- (void) setBoundaryColor: (UIColor *)boundaryColor;

@end
