//
//  DLDataTypeViewController.m
//  DataLoggr
//
//  Created by Michael Weingert on 2014-08-20.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataIconView.h"
#import "NSString+FontAwesome.h"

@implementation DLDataIconView
{
    NSString *_title;
    FAIcon _icon;
    BOOL _depressed;
}

-(id) initWithFrame:(CGRect) frame
               icon:(FAIcon) icon
              title:(NSString*)title
{
    self = [super initWithFrame: frame];
    if (self)
    {
        _title = title;
        _icon = icon;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconClicked:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
        _depressed = false;
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }
    return self;
}

- (void) iconClicked:(UITapGestureRecognizer *)tapRecognizer
{
    if (!_depressed) {
        self.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.5];
    } else {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }

    _depressed = !_depressed;
    
    [_delegate iconClicked:self];
}

- (NSString *) getTitle
{
    if (_title) {
        return _title;
    }
    else {
        return [NSString stringForFAIcon:_icon];
    }
}

- (void) setSelected: (BOOL) isSelected
{
    if (isSelected) {
        self.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.5];
    } else {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }
    _selected = isSelected;
    _depressed =_selected;
}

- (void)layoutSubviews
{
    
    if (_title != nil) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 50, 50)];
        timeLabel.text = _title;
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        [self addSubview:timeLabel];
    }
    
    UILabel *timeIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -10, 50, 50)];
    timeIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    timeIconLabel.text = [NSString fontAwesomeIconStringForEnum:_icon];
    [self addSubview:timeIconLabel];
}

@end
