//
//  DLTitleTableViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLGraphViewCell.h"
#import "CorePlot-CocoaTouch.h"
#import "DLDatePlot.h"
#import "CPTTheme.h"

@implementation DLGraphViewCell
{
    DLDatePlot *_datePlot;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(5, 0, 300, 300)];
        _datePlot = [[DLDatePlot alloc] init];
        _datePlot.hostView = hostView;
        [_datePlot generateData];
        [_datePlot renderInLayer:hostView withTheme:[CPTTheme themeNamed: kCPTDarkGradientTheme ] animated:YES];
        
        [self addSubview:hostView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

@end
