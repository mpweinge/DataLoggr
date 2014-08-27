//
//  DLAddDataViewController.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/19/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLAddPointViewController.h"
#import "DLDataPointRowObject.h"
#import "DLDataViewCell.h"
#import "DLDatabaseManager.h"

static const int kValueOffsetY = 25;
static const int kNotesOffsetY = 200;
static const int kButtonOffsetY = 350;

@interface DLAddPointViewController () < UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate >
{
  //UITextField* _dataName;
  UIView* _dataName;
  UIPickerView* _typeDataView;
  UITextField* _notes;
  UITextView* _notesView;
  NSString* _setName;
  NSString *_typeName;
  NSArray * dataTypeOptions;
  UIButton *_startButton;
  UIButton *_resetButton;
  NSDate *_start;
  BOOL _isAdd;
  BOOL _didEdit;
  BOOL _timerStarted;
  NSTimer *_timer;
  DLDataViewCell *_currCell;
  NSTimeInterval currPausedTime;
}

@end

@implementation DLAddPointViewController

-(instancetype) initWithSetName:(NSString *) setName
                       delegate:(id<DLAddPointViewControllerDelegate>) delegate
                          isAdd:(BOOL) isAdd
                       currCell:(DLDataViewCell *) currCell
                       typeName:(NSString *)typeName
{
  self = [super init];
  if (self) {
    self.title = setName;
    _setName = setName;
    dataTypeOptions = @[@"ManualData", @"GPS", @"Time"];
    _delegate = delegate;
    _isAdd = isAdd;
    _typeName = typeName;
    _timerStarted = FALSE;
    _currCell = currCell;
    _didEdit = NO;
    currPausedTime = 0;
    
    if (_isAdd) {
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(CancelClicked)];
      
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(CreateClicked)];
    } else {
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(DoneClicked)];
    }
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
  // Need some text fields and an icon picker
  _didEdit = NO;
  
  //UILabel *dataNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kValueOffsetY, 300, 50)];
  //dataNameLabel.text = @"Data Name: ";
  //dataNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  /*_dataName = [[UITextField alloc] initWithFrame:CGRectMake(100, kValueOffsetY, 200, 50)];
  _dataName.borderStyle = UITextBorderStyleRoundedRect;
  _dataName.returnKeyType = UIReturnKeyDone;
  _dataName.autocorrectionType = UITextAutocorrectionTypeNo;
  _dataName.delegate = self;
  _dataName.keyboardType = UIKeyboardTypeDefault;*/
  _dataName = [[UILabel alloc] initWithFrame:CGRectMake(40, kValueOffsetY, 300, 50)];
  ((UILabel *)_dataName).textColor = [UIColor blackColor];
  ((UILabel *)_dataName).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:60.0];
  
  if (!_isAdd) {
    ((UILabel *)_dataName).text = _currCell.title;
  } else if ([_typeName isEqualToString:@"Time"]) {
    ((UILabel *)_dataName).text = @"00:00.00";
  }
  
 /* if ([_typeName isEqualToString:@"Time"]) {
    ((UILabel *)_dataName).enabled = NO;
  }*/

  
  /*UILabel *typeDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 250, 300, 50)];
  typeDataLabel.text = @"Data Type: ";
  typeDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  _typeDataView = [[UIPickerView alloc] initWithFrame:CGRectMake(60, 90, 300, 50)];
  _typeDataView.dataSource = self;
  _typeDataView.delegate = self;
  _typeDataView.showsSelectionIndicator = YES;*/
  
  /*if (!_isAdd) {
    _typeDataView.text = [_currCell getTitle];
  }*/
  
  //[self.view addSubview:_typeDataView];
  
  UILabel *iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kNotesOffsetY, 300, 50)];
  iconDataLabel.text = @"Notes: ";
  iconDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  _notes = [[UITextField alloc] initWithFrame:CGRectMake(100, kNotesOffsetY, 200, 50)];
  _notes.borderStyle = UITextBorderStyleRoundedRect;
  _notes.returnKeyType = UIReturnKeyDone;
  _notes.autocorrectionType = UITextAutocorrectionTypeNo;
  _notes.delegate = self;
  _notes.keyboardType = UIKeyboardTypeDefault;
  
  CGRect frameRect = _notes.frame;
  frameRect.size.height = 90;
  _notes.frame = frameRect;
  
  _notesView = [[UITextView alloc] initWithFrame:frameRect];
  _notesView.backgroundColor = [UIColor clearColor];
  _notesView.delegate = self;
  _notesView.returnKeyType = UIReturnKeyDone;
  [self.view addSubview:_notes];
  [self.view addSubview:_notesView];
  
  if (!_isAdd) {
    _notesView.text = _currCell.notes;
  }
  
  /*UIButton *createButton =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
  
  if (_isAdd) {
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
  } else {
    [createButton setTitle:@"OK" forState:UIControlStateNormal];
  }
  [createButton sizeToFit];
  CGRect createFrame = createButton.frame;
  createFrame.size.width += 30;
  createButton.frame = createFrame;
  createButton.center = CGPointMake(160, 400);
  [createButton addTarget:self action:@selector(CreateClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:createButton];*/
  //[self.view addSubview:dataNameLabel];
 // [self.view addSubview:typeDataLabel];
  [self.view addSubview:iconDataLabel];
  [self.view addSubview:_dataName];
  
  //Create view for time
  if ([_typeName isEqualToString:@"Time"]) {
    //For time add a giant label for a timer
    [self setupTimer];
  }else if ([_typeName isEqualToString:@"GPS"]) {
    
  }
}

- (void) setupTimer
{
  //Add buttons for start, stop
  _startButton =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_startButton setTitle:@"Start" forState:UIControlStateNormal];
  [_startButton sizeToFit];
  _startButton.center = CGPointMake(100, kButtonOffsetY);
  [_startButton addTarget:self action:@selector(StartTimerClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  _resetButton =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
  [_resetButton sizeToFit];
  _resetButton.center = CGPointMake(250, kButtonOffsetY);
  [_resetButton addTarget:self action:@selector(ResetTimerClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  _start = nil;
  
  [self.view addSubview:_startButton];
  [self.view addSubview:_resetButton];
}

- (void) ResetTimerClicked: (UIButton *)resetButton
{
  //Invalidate the current timer
  if (_timer)
  {
    [_timer invalidate];
    _timer = nil;
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    _timerStarted = false;
    //Reset the clock
    _start = nil;
    ((UILabel *)_dataName).text = @"00:00.00";
  }
  currPausedTime = 0;
  ((UILabel *)_dataName).text = @"00:00.00";
  _didEdit = YES;
}

- (void) StartTimerClicked: (UIButton *)startButton
{
  if (!_timerStarted) {
    _didEdit = YES;
    if (!_start) {
        _start = [NSDate date];
    }
      _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                             target:self
                                           selector:@selector(updateTime)
                                           userInfo:nil
                                            repeats:YES];
    
    [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
  } else {
    currPausedTime = [_start timeIntervalSinceNow] * -1 + currPausedTime;
    _start = nil;
    [_timer invalidate];
    _timer = nil;
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
  }
  _timerStarted = !_timerStarted;
}

-(void) updateTime
{
  NSTimeInterval timeInterval = [_start timeIntervalSinceNow];
  timeInterval *= -1;
  timeInterval += currPausedTime;;
  
  int numMinutes = timeInterval / 60;
  int numMinutesTen = numMinutes / 10;
  
  int numSeconds = (timeInterval - numMinutes * 60);
  int numSecondsTen = numSeconds / 10;
  
  int numMilli = (timeInterval - numSeconds) * 100;
  int numMilliTen = numMilli / 10;
  numMilli -= numMilliTen * 10;
  
  numMinutes -= numMinutesTen * 10;
  numSeconds -= numSecondsTen * 10;
  
  ((UILabel *)_dataName).text = [NSString stringWithFormat:@"%i%i:%i%i.%i%i", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
}

- (void) CancelClicked
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) CreateClicked
{
  if (_isAdd)
  {
    NSLog(@"Create Clicked");
    NSString* dataName = _setName;
    //NSInteger row = [_typeDataView selectedRowInComponent:0];
    NSString* dataValue =  ((UILabel *)_dataName).text;
    NSString* notes = _notesView.text;
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    
    //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
    DLDataPointRowObject *newObject = [[DLDataPointRowObject alloc]
                                        initWithName:dataName
                                               value:dataValue
                                                time:resultString
                                               notes:notes];
    
    [newObject save];
    [_delegate didCreateNewObject:newObject];
  } else if (_didEdit) {
    // Save changes to database
    NSString* dataName = _setName;
    //NSInteger row = [_typeDataView selectedRowInComponent:0];
    NSString* dataValue =  ((UILabel *)_dataName).text;
    NSString* notes = _notesView.text;
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    
    //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
    DLDataPointRowObject *newObject = [[DLDataPointRowObject alloc]
                                       initWithName:dataName
                                       value:dataValue
                                       time:resultString
                                       notes:notes];
    
    [[DLDatabaseManager getSharedInstance] updateOldPoint: [_currCell dataPoint] newPoint: newObject];
    
    [_delegate didEditObject:_currCell withData:newObject];
    
    // Save changes to table
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
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

- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
  _didEdit = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
  return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
  return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  
  if([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  
  return YES;
}

- (void)textViewDidBeginEditing:(UITextField *)textField           // became first responder
{
  _didEdit = YES;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView;
{
  return YES;
}

@end
