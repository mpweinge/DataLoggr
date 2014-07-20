//
//  DLHomeTableViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLHomeTableViewCell.h"
#import "NSString+FontAwesome.h"

@interface DLHomeTableViewCell ()
{
  NSString *_caption;
}
@end

@implementation DLHomeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            caption:(NSString *)caption
               icon:(FAIcon)icon;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      UILabel* chartIcon=[[UILabel alloc] initWithFrame:CGRectMake(20, 13, 100, 22)];
      chartIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      chartIcon.text = [NSString fontAwesomeIconStringForEnum:icon];
      [self addSubview:chartIcon];
      
      UILabel * chartName = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, 100, 22)];
      chartName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      chartName.text = caption;
      [self addSubview:chartName];
      
      UILabel* advanceIcon=[[UILabel alloc] initWithFrame:CGRectMake(300, 13, 100, 22)];
      advanceIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      advanceIcon.text = [NSString fontAwesomeIconStringForEnum:FAAngleRight];
      [self addSubview:advanceIcon];
      
      _caption = caption;
    }

  UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
  
  touchRecognizer.numberOfTapsRequired = 1;
  
  [self addGestureRecognizer:touchRecognizer];
  return self;
}

-(void) tappedCell : (UIGestureRecognizer *)gestureRecognizer
{
  [self.delegate CellViewTouched:self];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (NSString *) getTitle
{
  return _caption;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
