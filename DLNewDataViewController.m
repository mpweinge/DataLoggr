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

@interface DLNewDataViewController () < UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, DLDataIconViewDelegate, UITextFieldDelegate >
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
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  //Need some text fields and an icon picker
  
  UILabel *dataNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 50)];
  dataNameLabel.text = @"Data Name: ";
  dataNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  _dataName = [[UITextField alloc] initWithFrame:CGRectMake(100, 140, 200, 50)];
  _dataName.borderStyle = UITextBorderStyleRoundedRect;
  _dataName.returnKeyType = UIReturnKeyDone;
  _dataName.autocorrectionType = UITextAutocorrectionTypeNo;
  _dataName.delegate = self;
  _dataName.keyboardType = UIKeyboardTypeDefault;
  
  UILabel *typeDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 300, 50)];
  typeDataLabel.text = @"Data Type: ";
  typeDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    
    _timeIcon = [[DLDataIconView alloc]initWithFrame:CGRectMake(100, 200, 70, 50) icon:FATimes title:@"Time"];
    [self.view addSubview:_timeIcon];
    _timeIcon.delegate = self;
    
    //Set first icon to be selected
    _timeIcon.selected = YES;
    _selectedDataType = _timeIcon;
    
    _gpsIcon = [[DLDataIconView alloc]initWithFrame:CGRectMake(170, 200, 70, 50) icon:FATimes title:@"GPS"];
    [self.view addSubview:_gpsIcon];
    _gpsIcon.delegate = self;
    
    _customIcon = [[DLDataIconView alloc]initWithFrame:CGRectMake(240, 200, 70, 50) icon:FATimes title:@"Custom"];
    [self.view addSubview:_customIcon];
    _customIcon.delegate = self;
  
  UILabel *iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, 300, 50)];
  iconDataLabel.text = @"Icon: ";
  iconDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
    _iconSwitcherView = [[UIScrollView alloc] initWithFrame:CGRectMake(60, 280, 200, 150)];
    _iconSwitcherView.contentSize = CGSizeMake(750, 50);
    _iconSwitcherView.showsHorizontalScrollIndicator = YES;
    _iconSwitcherView.backgroundColor = [UIColor lightGrayColor];
    
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
  
  UIButton *createButton =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [createButton setTitle:@"Create" forState:UIControlStateNormal];
  [createButton sizeToFit];
  createButton.center = CGPointMake(160, 450);
  [createButton addTarget:self action:@selector(CreateClicked:) forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:createButton];
  [self.view addSubview:dataNameLabel];
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
    }
    else if (_gpsIcon == selectedIcon) {
        _timeIcon.selected = NO;
        _customIcon.selected = NO;
    }
    else if (_customIcon == selectedIcon) {
        _timeIcon.selected = NO;
        _gpsIcon.selected = NO;
    } else {
        if (_selectedIcon) {
            _selectedIcon.selected = NO;
        }
        selectedIcon.selected = YES;
        _selectedIcon = selectedIcon;
    }
}

- (void) CreateClicked: (UIButton *)createButton
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
  // Handle the selection
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  NSUInteger numRows = 3;
  
  return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  if (pickerView == _typeDataView)
  {
    if (row == 1)
      return @"ManualData";
    else if (row == 2)
      return @"GPS";
    else
      return @"Time";
  }
  else
  {
    if (row == 1)
      return @"FAGithub";
    else if (row == 2)
      return @"FAFacebook";
    else
      return @"FACloud";
  }
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
  int sectionWidth = 300;
  
  return sectionWidth;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
