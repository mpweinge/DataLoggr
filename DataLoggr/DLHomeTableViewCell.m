//
//  DLHomeTableViewCell.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLHomeTableViewCell.h"
#import "NSString+FontAwesome.h"
//#import "UIHomeGestureRecognizer.h"

@interface DLHomeTableViewCell ()
@end

@implementation DLHomeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            caption:(NSString *)caption
               icon:(FAIcon)icon
               type:(NSString *)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      UILabel* chartIcon=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 42)];
      chartIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:28];
      chartIcon.text = [NSString fontAwesomeIconStringForEnum:icon];
      [self addSubview:chartIcon];
      
      UILabel * chartName = [[UILabel alloc] initWithFrame:CGRectMake(60, 1, 300, 22)];
      chartName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
      chartName.text = caption;
      [self addSubview:chartName];
      
      UILabel * lastModifiedTime = [[UILabel alloc] initWithFrame:CGRectMake(70, 21, 300, 22)];
      lastModifiedTime.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:10.0];
      lastModifiedTime.text = @"Last modified: FakeDateHere";
      [self addSubview:lastModifiedTime];
      
      UILabel* advanceIcon=[[UILabel alloc] initWithFrame:CGRectMake(300, 13, 100, 22)];
      advanceIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
      advanceIcon.textColor = [UIColor blueColor];
      advanceIcon.text = [NSString fontAwesomeIconStringForEnum:FAAngleRight];
      [self addSubview:advanceIcon];
      
      _title = caption;
      _type = type;
    }

  UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
  
  touchRecognizer.numberOfTapsRequired = 1;
  
  [self addGestureRecognizer:touchRecognizer];
  
  return self;
}

-(void) holdOnCell : (UIGestureRecognizer *)gestureRecognizer
{
  self.backgroundColor = [UIColor lightGrayColor];
}

-(void) tappedCell : (UIGestureRecognizer *)gestureRecognizer
{
  [self.delegate CellViewTouched:self];
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
