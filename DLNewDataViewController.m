//
//  DLNewDataViewController.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/14/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLNewDataViewController.h"
#import "DLDataRowObject.h"
#import "NSString+FontAwesome.h"
#import "DLDataIconView.h"
#import "DLBasicButton.h"
#import "UIButton+Bootstrap.h"
#import "DLCircleView.h"

static const int kNameOffsetY = 0;
static const int kTypeOffsetY = 80;
static const int kIconOffset = 170;

@interface DLNewDataViewController () < UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, DLDataIconViewDelegate, UITextFieldDelegate, UIScrollViewDelegate >
{
  UITextField* _dataName;
  UIPickerView* _typeDataView;
  UIScrollView* _iconSwitcherView;
    
  DLDataIconView *_timeIcon;
  DLDataIconView *_gpsIcon;
  DLDataIconView *_customIcon;
  
  DLDataIconView *_selectedIcon;
  DLDataIconView *_selectedDataType;
  
  NSArray * dataTypeOptions;
  NSArray * iconOptions;
  
  UIView * whiteNameCard;
  UIView * whiteTypeCard;
  UIView * whiteIconCard;
  
  NSMutableArray* _indicatorCircles;
}

@end

@implementation DLNewDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      self.title = @"New Data";
      dataTypeOptions = @[@"ManualData", @"GPS", @"Time"];
      iconOptions = @[@"fa-github", @"fa-facebook", @"fa-cloud"];
    }
    return self;
}

-(instancetype) initWithDelegate : (id<DLNewDataViewControllerDelegate>) delegate
{
  self = [super init];
  if (self)
  {
    self.title = @"New Data";
    dataTypeOptions = @[@"ManualData", @"GPS", @"Time"];
    iconOptions = @[@"fa-github", @"fa-facebook", @"fa-cloud"];
    _delegate = delegate;
      //self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(CreateClicked)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(CancelClicked)];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  //Need some text fields and an icon picker
  
  whiteNameCard = [[UIView alloc] initWithFrame:CGRectMake(5, kNameOffsetY + 60, 310, 1)];
  whiteNameCard.backgroundColor = [UIColor lightGrayColor];
  
  [self.view addSubview:whiteNameCard];
  
  //UILabel *dataNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kNameOffsetY, 310, 50)];
  //dataNameLabel.text = @"Name: ";
  //dataNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  //[self.view addSubview:dataNameLabel];
  
  _dataName = [[UITextField alloc] initWithFrame:CGRectMake(10, kNameOffsetY, 200, 80)];
  _dataName.borderStyle = UITextBorderStyleNone;
  _dataName.returnKeyType = UIReturnKeyDone;
  _dataName.autocorrectionType = UITextAutocorrectionTypeNo;
  _dataName.delegate = self;
  _dataName.keyboardType = UIKeyboardTypeDefault;
  _dataName.text = @"Name of Data Series";
  _dataName.textColor = [UIColor lightGrayColor];
  
  UILabel *typeDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kTypeOffsetY, 300, 50)];
  typeDataLabel.text = @"Type: ";
  typeDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  whiteTypeCard = [[UIView alloc] initWithFrame:CGRectMake(5, kTypeOffsetY + 90, 310, 1)];
  whiteTypeCard.backgroundColor = [UIColor lightGrayColor];
  
  [self.view addSubview:whiteTypeCard];
    
    _timeIcon = [[DLDataIconView alloc]initWithFrame:CGRectMake(80, kTypeOffsetY, 50, 50) icon:FAClockO title:@"Time"];
    [self.view addSubview:_timeIcon];
  //_timeIcon.backgroundColor = [UIColor clearColor];
    _timeIcon.delegate = self;
    
    //Set first icon to be selected
    _timeIcon.selected = YES;
    _selectedDataType = _timeIcon;
    
    _gpsIcon = [[DLDataIconView alloc]initWithFrame:CGRectMake(150, kTypeOffsetY, 50, 50) icon:FAGlobe title:@"GPS"];
    [self.view addSubview:_gpsIcon];
    _gpsIcon.delegate = self;
    
    _customIcon = [[DLDataIconView alloc]initWithFrame:CGRectMake(220, kTypeOffsetY, 50, 50) icon:FAPencil title:@"Custom"];
    [self.view addSubview:_customIcon];
    _customIcon.delegate = self;
  
  UILabel *iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kIconOffset + 50, 300, 50)];
  iconDataLabel.text = @"Icon: ";
  iconDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
    _iconSwitcherView = [[UIScrollView alloc] initWithFrame:CGRectMake(60, kIconOffset, 200, 150)];
    _iconSwitcherView.contentSize = CGSizeMake(800, 50);
    _iconSwitcherView.showsHorizontalScrollIndicator = YES;
    _iconSwitcherView.backgroundColor = [UIColor clearColor];
  _iconSwitcherView.pagingEnabled = YES;
  _iconSwitcherView.delegate = self;
    
    NSDictionary* enumDict = [NSString enumDictionaryForData];
    
    NSEnumerator *enumerator = [enumDict objectEnumerator];
    id value;
    
    int i = 0;
    
    while ((value = [enumerator nextObject])) {
        /* code that acts on the dictionary’s values */
        int rowNum = i / 3;
        int colNum = (i % 3);
        
        NSInteger val = [value integerValue];
        
        DLDataIconView *dlDataView = [[DLDataIconView alloc] initWithFrame:CGRectMake(10 + rowNum * 50, colNum * 50, 50, 50) icon:val title:nil];
        
        dlDataView.delegate = self;
        
        [_iconSwitcherView addSubview:dlDataView];
        
        if (i == 0) {
            //Set first icon to be selected
            dlDataView.selected = YES;
            _selectedIcon = dlDataView;
        }
        i++;
    }
  [self.view addSubview:_iconSwitcherView];
  
  whiteIconCard = [[UIView alloc] initWithFrame:CGRectMake(5, kIconOffset + 185, 310, 1)];
  whiteIconCard.backgroundColor = [UIColor lightGrayColor];
  
  [self.view addSubview:whiteIconCard];
  
  _indicatorCircles = [NSMutableArray array];
  
  for (int i = 0; i < 4; i++)
  {
    DLCircleView* currCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(135 + 20 * i,kIconOffset + 155,10,10) strokeWidth: 1.0 selectFill:YES selectColor:[UIColor lightGrayColor]];
    [_indicatorCircles addObject: currCircle];
    currCircle.backgroundColor = [UIColor clearColor];
    currCircle.selected = (i == 0);
    [self.view addSubview:currCircle];
  }
  
  [self.view addSubview:typeDataLabel];
  [self.view addSubview:iconDataLabel];
  [self.view addSubview:_dataName];
}

-(void) iconClicked:(DLDataIconView *) selectedIcon
{
    //De select the other icons
    if (_timeIcon == selectedIcon) {
        _gpsIcon.selected = NO;
        _customIcon.selected = NO;
      selectedIcon.selected = YES;
    }
    else if (_gpsIcon == selectedIcon) {
        _timeIcon.selected = NO;
        _customIcon.selected = NO;
        selectedIcon.selected = YES;
    }
    else if (_customIcon == selectedIcon) {
        _timeIcon.selected = NO;
        _gpsIcon.selected = NO;
        selectedIcon.selected = YES;
    } else {
        if (_selectedIcon) {
            _selectedIcon.selected = NO;
        }
        selectedIcon.selected = YES;
        _selectedIcon = selectedIcon;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  static NSInteger previousPage = 0;
  CGFloat pageWidth = scrollView.frame.size.width;
  NSInteger page = scrollView.contentOffset.x / pageWidth;
  if (previousPage != page) {
    ((DLCircleView *)_indicatorCircles[page]).selected = YES;
    ((DLCircleView *)_indicatorCircles[previousPage]).selected = NO;
    
    [((DLCircleView *)_indicatorCircles[page]) setNeedsDisplay];
    [((DLCircleView *)_indicatorCircles[previousPage]) setNeedsDisplay];
    
    previousPage = page;
  }
}

- (void) CancelClicked
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) CreateClicked//: (UIButton *)createButton
{
  NSLog(@"Create Clicked");
  NSString* dataName = _dataName.text;
  NSString* dataType =  _selectedDataType.title;
  NSString* iconStr = _selectedIcon.title;
  
  //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
  DLDataRowObject *newObject = [[DLDataRowObject alloc] initWithName:dataName type:dataType iconName:iconStr];
  
  [newObject save];
  [_delegate didCreateNewObject:newObject];
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
