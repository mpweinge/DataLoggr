//
//  DLAddDataViewController.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/19/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLAddPointViewController.h"
#import "DLDataPointRowObject.h"

@interface DLAddPointViewController () < UIPickerViewDataSource, UIPickerViewDelegate >
{
  UITextField* _dataName;
  UIPickerView* _typeDataView;
  UITextField* _notes;
  NSString* _setName;
  NSArray * dataTypeOptions;
  BOOL _isAdd;
}

@end

@implementation DLAddPointViewController

-(instancetype) initWithSetName: (NSString *) setName
                       delegate:( id<DLAddPointViewControllerDelegate>) delegate
                          isAdd:(BOOL) isAdd
{
  self = [super init];
  if (self) {
    self.title = setName;
    _setName = setName;
    dataTypeOptions = @[@"ManualData", @"GPS", @"Time"];
    _delegate = delegate;
      _isAdd = isAdd;
  }
  
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.title = @"New Data";
    dataTypeOptions = @[@"ManualData", @"GPS", @"Time"];
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
  
  _typeDataView = [[UIPickerView alloc] initWithFrame:CGRectMake(60, 140, 300, 50)];
  _typeDataView.dataSource = self;
  _typeDataView.delegate = self;
  _typeDataView.showsSelectionIndicator = YES;
  [self.view addSubview:_typeDataView];
  
  UILabel *iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, 300, 50)];
  iconDataLabel.text = @"Notes: ";
  iconDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  _notes = [[UITextField alloc] initWithFrame:CGRectMake(100, 140, 200, 50)];
  _notes.borderStyle = UITextBorderStyleRoundedRect;
  _notes.returnKeyType = UIReturnKeyDone;
  _notes.autocorrectionType = UITextAutocorrectionTypeNo;
  _notes.delegate = self;
  _notes.keyboardType = UIKeyboardTypeDefault;
  
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

- (void) CreateClicked: (UIButton *)createButton
{
  NSLog(@"Create Clicked");
  NSString* dataName = _setName;
  //NSInteger row = [_typeDataView selectedRowInComponent:0];
  NSString* dataValue =  _dataName.text;
  //NSString* notes = _notes.text;
  
  NSDate *currentTime = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  NSString *resultString = [dateFormatter stringFromDate: currentTime];
  
  //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
  DLDataPointRowObject *newObject = [[DLDataPointRowObject alloc]
                                     initWithName:dataName
                                     value:dataValue
                                     time:resultString];
  
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

@end
