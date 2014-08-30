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
#import "LocationTracker.h"
#import <MapKit/MapKit.h>

static const int kValueOffsetY = 25;
static int kNotesOffsetY = 150;
static const int kButtonOffsetY = 350;
static const int kStartingNumPoints = 2000;

@interface DLAddPointViewController () < UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate >
{
  //UITextField* _dataName;
  UIView* _dataName;
  UILabel* _backgroundText;
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
  
  BOOL _textFieldEmpty;
  
  MKMapView *_addMap;
  CLLocationManager *_locationManager;
  
  LocationTracker * locationTracker;
  NSTimer* locationUpdateTimer;
  
  MKPolyline *myPolyline;
  
  CLLocationCoordinate2D *mapPoints;
  int mapPointCount;
  
  CLLocationDegrees minLat;
  CLLocationDegrees minLong;
  CLLocationDegrees maxLat;
  CLLocationDegrees maxLong;
  
  int currZoom;
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
    _textFieldEmpty = YES;
    
    mapPoints = malloc(sizeof(CLLocationCoordinate2D) * kStartingNumPoints );
    mapPointCount = 0;
    minLat = 0;
    minLong = 0;
    maxLat = 0;
    maxLong = 0;
    
    currZoom = 500;
    
    if (_isAdd) {
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(CancelClicked)];
      
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(CreateClicked)];
    } else {
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(CreateClicked)];
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
  
  if ([_typeName isEqualToString:@"Time"] ) {
  _dataName = [[UILabel alloc] initWithFrame:CGRectMake(40, kValueOffsetY, 300, 50)];
  ((UILabel *)_dataName).textColor = [UIColor blackColor];
  ((UILabel *)_dataName).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:60.0];
  } else if ([_typeName isEqualToString:@"GPS"] ) {
    _addMap = [[MKMapView alloc] initWithFrame:CGRectMake(40, kValueOffsetY, 250, 200)];
    _addMap.showsUserLocation = YES;
    _addMap.delegate = self;
    kNotesOffsetY = 300;
    [self.view addSubview:_addMap];
  } else {
    _dataName = [[UITextField alloc] initWithFrame:CGRectMake(40, kValueOffsetY, 300, 50)];
    
    ((UITextField *)_dataName).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
    
    ((UITextField *)_dataName).borderStyle = UITextBorderStyleNone;
    ((UITextField *)_dataName).returnKeyType = UIReturnKeyDone;
    ((UITextField *)_dataName).autocorrectionType = UITextAutocorrectionTypeNo;
    ((UITextField *)_dataName).delegate = self;
    ((UITextField *)_dataName).keyboardType = UIKeyboardTypeDecimalPad;
    
    if ((_isAdd) || ([_currCell.title length]== 0)) {
      _backgroundText = [[UILabel alloc] initWithFrame:CGRectMake(40, kValueOffsetY, 300, 50)];
      _backgroundText.text = @"Data Value";
      _backgroundText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
      _backgroundText.textColor = [UIColor lightGrayColor];
      [self.view addSubview:_backgroundText];
    }
  }
  
  if (!_isAdd) {
    ((UILabel *)_dataName).text = _currCell.title;
  } else if ([_typeName isEqualToString:@"Time"]) {
    ((UILabel *)_dataName).text = @"00:00.00";
  }
  
  UIView *dataDivider = [[UIView alloc] initWithFrame:CGRectMake(5, kNotesOffsetY - 35, 310, 1)];
  dataDivider.backgroundColor = [UIColor lightGrayColor];
  [self.view addSubview:dataDivider];
  
  UILabel *iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kNotesOffsetY, 300, 50)];
  iconDataLabel.text = @"Notes: ";
  iconDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  _notes = [[UITextField alloc] initWithFrame:CGRectMake(100, kNotesOffsetY, 200, 50)];
  _notes.borderStyle = UITextBorderStyleRoundedRect;
  _notes.returnKeyType = UIReturnKeyDone;
  _notes.autocorrectionType = UITextAutocorrectionTypeNo;
  _notes.delegate = self;
  _notes.keyboardType = UIKeyboardTypeDefault;
  _notes.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  CGRect frameRect = _notes.frame;
  frameRect.size.height = 90;
  _notes.frame = frameRect;
  
  _notesView = [[UITextView alloc] initWithFrame:frameRect];
  _notesView.backgroundColor = [UIColor clearColor];
  _notesView.delegate = self;
  _notesView.returnKeyType = UIReturnKeyDone;
  _notesView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  [self.view addSubview:_notes];
  [self.view addSubview:_notesView];
  
  if (!_isAdd) {
    _notesView.text = _currCell.notes;
  }
  
  [self.view addSubview:iconDataLabel];
  [self.view addSubview:_dataName];
  
  //Create view for time
  if ([_typeName isEqualToString:@"Time"]) {
    //For time add a giant label for a timer
    [self setupTimer];
  } else if ([_typeName isEqualToString:@"GPS"]) {
    [self setupGPS];
  }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
  CLLocationCoordinate2D userLocationCoord = userLocation.coordinate;
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocationCoord, 500, 500);
  MKCoordinateRegion adjustedRegion = [_addMap regionThatFits:viewRegion];
  [_addMap setRegion:adjustedRegion animated:YES];
  [_addMap setZoomEnabled:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  if ([overlay isKindOfClass:MKPolyline.class]) {
    MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    lineView.strokeColor = [UIColor greenColor];
    
    return lineView;
  }
  
  return nil;
}

- (void)startTrackingLocation
{
  locationTracker = [[LocationTracker alloc]init];
  locationTracker.delegate = self;
  [locationTracker startLocationTracking];
  
  //Send the best location to server every 5 seconds
  //You may adjust the time interval depends on the need of your app.
  NSTimeInterval time = 5.0;
	locationUpdateTimer =
  [NSTimer scheduledTimerWithTimeInterval:time
                                   target:self
                                 //selector:@selector(updateLocation)
                                 selector:@selector(testMapUpdate)
                                 userInfo:nil
                                  repeats:YES];
}

- (void) stopTrackingLocation {
  [locationUpdateTimer invalidate];
  locationUpdateTimer = nil;
  [locationTracker stopLocationTracking];
}

-(void) testMapUpdate
{
  CLLocationCoordinate2D location;
  location.latitude = mapPointCount / (double)5000.0;
  location.longitude = mapPointCount / (double)5000.0;
  [self DidGetLocation:location];
}

-(void)updateLocation {
  NSLog(@"updateLocation");
  
  [locationTracker updateLocationToServer];
}

-(void) DidGetLocation:(CLLocationCoordinate2D) location
{
  
  // If in background, store other way
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, currZoom, currZoom);
  MKCoordinateRegion adjustedRegion = [_addMap regionThatFits:viewRegion];
  [_addMap setRegion:adjustedRegion animated:YES];
  [_addMap setZoomEnabled:YES];
  
  if (mapPointCount == 0) {
    mapPoints[mapPointCount] = location;
    mapPointCount++;
  } else if ((location.latitude != mapPoints[mapPointCount].latitude) ||
             (location.longitude != mapPoints[mapPointCount].longitude) ) {
    mapPointCount++;
    mapPoints[mapPointCount] = location;
  }
  
  //if (!myPolyline) {
  myPolyline = [MKPolyline polylineWithCoordinates:mapPoints count:mapPointCount];
  //}
  
  if (location.latitude < minLat) {
    minLat = location.latitude;
  }
  if (location.latitude > maxLat) {
    maxLat = location.latitude;
  }
  
  if (location.longitude > maxLong) {
    maxLong = location.longitude;
  }
  
  if (location.longitude < minLong) {
    minLong = location.longitude;
  }
  
  //Test four corners to make sure all is in frame
  CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(minLong, maxLat);
  CLLocationCoordinate2D topRight = CLLocationCoordinate2DMake(maxLong, maxLat);
  CLLocationCoordinate2D bottomLeft = CLLocationCoordinate2DMake(minLong, minLat);
  CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(maxLong, minLat);
  
  if(MKMapRectContainsPoint(_addMap.visibleMapRect, MKMapPointForCoordinate(topLeft)) &&
     MKMapRectContainsPoint(_addMap.visibleMapRect, MKMapPointForCoordinate(topRight)) &&
     MKMapRectContainsPoint(_addMap.visibleMapRect, MKMapPointForCoordinate(bottomLeft)) &&
     MKMapRectContainsPoint(_addMap.visibleMapRect, MKMapPointForCoordinate(bottomRight))
     )
  {
    //Do stuff
  } else {
    //Resize map
    //200 km/h (won't be moving faster than this)
    currZoom += 250;
  }
  
  [_addMap addOverlay:myPolyline];
}

-(void)scrollToY:(float)y
{
  [UIView beginAnimations:@"registerScroll" context:NULL];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDuration:0.4];
  self.view.transform = CGAffineTransformMakeTranslation(0, y);
  [UIView commitAnimations];
}

-(void)scrollToView:(UIView *)view
{
  CGRect theFrame = view.frame;
  float y = theFrame.origin.y - 15;
  y -= (y/1.7);
  [self scrollToY:-y];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
  [self.view setFrame:CGRectMake(0,0,320,460)];
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

- (void) setupGPS
{
  _startButton =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [_startButton setTitle:@"Start" forState:UIControlStateNormal];
  [_startButton sizeToFit];
  _startButton.center = CGPointMake(100, kButtonOffsetY);
  [_startButton addTarget:self action:@selector(StartGPSClicked:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_startButton];
}

- (void) StartGPSClicked: (UIButton *)gpsButton
{
  if (_timerStarted) {
    [self startTrackingLocation];
    [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
  } else {
    [self stopTrackingLocation];
  }
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
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
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
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    
    //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
    DLDataPointRowObject *newObject = [[DLDataPointRowObject alloc]
                                       initWithName:dataName
                                       value:dataValue
                                       time:resultString
                                       notes:notes];
    
    [[DLDatabaseManager getSharedInstance] updateOldPoint: [_currCell dataPoint] newPoint: newObject];
    
    [_delegate didEditObject:_currCell withData:newObject];
  }
  
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

- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
  _didEdit = YES;
  UITextPosition *beginning = [textField beginningOfDocument];
  [textField setSelectedTextRange:[textField textRangeFromPosition:beginning
                                                        toPosition:beginning]];
  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
  return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
  return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  if([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  
  return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView           // became first responder
{
  _didEdit = YES;
  
  [self scrollToView:textView];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
  [self scrollToY:0];
  [textView resignFirstResponder];
}

- (BOOL)textViewShouldReturn:(UITextView *)textView;
{
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSLog(@"Replacement string: %@", string);
  if ((range.location == 0) && ([string isEqualToString:@""]) && (textField.text.length == 1))
  {
    _backgroundText.hidden = NO;
    
    UITextPosition *beginning = [textField beginningOfDocument];
    [textField setSelectedTextRange:[textField textRangeFromPosition:beginning
                                                          toPosition:beginning]];
    _textFieldEmpty = true;
    textField.text = @"";
  } else if (_textFieldEmpty) {
    _backgroundText.hidden = YES;
    _textFieldEmpty = false;
  }
  
  return YES;
}

@end
