//
//  DLTitleTableViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/13/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLTitleTableViewCell.h"
#import "NSString+FontAwesome.h"

@implementation DLTitleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  assert(0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isHome: (BOOL) isHome
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      
      UILabel * chartName = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, 220, 22)];
      chartName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      
      if (isHome) {
        chartName.text = @"No charts, click the + to add!";
      } else {
        chartName.text = @"No points, click the + to add!";
      }
      [self addSubview:chartName];
      
      UILabel* advanceIcon=[[UILabel alloc] initWithFrame:CGRectMake(291, 13, 100, 22)];
      advanceIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      advanceIcon.text = [NSString fontAwesomeIconStringForEnum:FALongArrowUp];
      [self addSubview:advanceIcon];
    }
  
  UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
  
  touchRecognizer.numberOfTapsRequired = 1;
  
  [self addGestureRecognizer:touchRecognizer];
  return self;
}

-(void) tappedCell : (UIGestureRecognizer *)gestureRecognizer
{
  [self.delegate TitleCellTouched:0];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
