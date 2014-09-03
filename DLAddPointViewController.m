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
#import "DLDataIconView.h"
#import "DLCircleView.h"

static const int kValueOffsetY = 25;
static int kNotesOffsetY = 150;
static const int kButtonOffsetY = 350;
static const int kStartingNumPoints = 2000;

@interface DLAddPointViewController () < UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, DLDataIconViewDelegate >
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
  DLCircleView * _startCircle;
  DLCircleView *_resetCircle;
  UIColor * greenWatchColor;
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
  
  LocationTracker * locationTracker;
  NSTimer* locationUpdateTimer;
  
  MKPolyline *myPolyline;
  
  CLLocationCoordinate2D *mapPoints;
  int mapPointCount;
  
  CLLocationDegrees minLat;
  CLLocationDegrees minLong;
  CLLocationDegrees maxLat;
  CLLocationDegrees maxLong;
  
  double _existingCentroidLatitude;
  double _existingCentroidLongitude;
  
  CLLocation *_previousLocation;
  CLLocationDistance _elapsedDistance;
  NSTimeInterval _elapsedTime;
  UILabel *_timeText;
  UILabel *_distanceText;
  
  BOOL _userPanning;
  
  MKCoordinateRegion _lastSetRegion;
  
  int currZoom;
  
  DLDataIconView *_ZoomPanIcon;
  BOOL _changeMapZoomOnce;
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
    _userPanning = false;
    
    mapPoints = malloc(sizeof(CLLocationCoordinate2D) * kStartingNumPoints );
    mapPointCount = 0;
    minLat = 1000;
    minLong = 1000;
    maxLat = -1000;
    maxLong = -1000;
    _existingCentroidLatitude = 0;
    _existingCentroidLongitude = 0;
    
    greenWatchColor = [UIColor colorWithRed:0 green:204/255.0 blue:0 alpha:1.0];
    
    currZoom = 400;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
  
  kNotesOffsetY = 150;
  
  if ([_typeName isEqualToString:@"Time"] ) {
  _dataName = [[UILabel alloc] initWithFrame:CGRectMake(40, kValueOffsetY, 300, 50)];
  ((UILabel *)_dataName).textColor = [UIColor blackColor];
  ((UILabel *)_dataName).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:60.0];
  } else if ([_typeName isEqualToString:@"GPS"] ) {
    _addMap = [[MKMapView alloc] initWithFrame:CGRectMake(40, kValueOffsetY - 13, 250, 200)];
    _addMap.showsUserLocation = YES;
    _addMap.userTrackingMode = MKUserTrackingModeFollow;
    _addMap.delegate = self;
    
    // Create divider and Time, Data column
    UIView *dataDivider = [[UIView alloc] initWithFrame:CGRectMake(5, kNotesOffsetY + 70, 310, 1)];
    dataDivider.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:dataDivider];
    
    UILabel *iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kNotesOffsetY +65, 300, 50)];
    iconDataLabel.text = @"Time: ";
    iconDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    [self.view addSubview:iconDataLabel];
    
    _timeText = [[UILabel alloc] initWithFrame:CGRectMake(60, kNotesOffsetY + 66, 200, 50)];
    _timeText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    _timeText.text = @"00:00.00";
    [self.view addSubview:_timeText];
    
    UILabel *iconDataLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(180, kNotesOffsetY + 65, 300, 50)];
    iconDataLabel2.text = @"Distance: ";
    iconDataLabel2.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    [self.view addSubview:iconDataLabel2];
    
    _distanceText = [[UILabel alloc] initWithFrame:CGRectMake(250, kNotesOffsetY + 66, 200, 50)];
    _distanceText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    _distanceText.text = @"0.0 m";
    [self.view addSubview:_distanceText];
    
    kNotesOffsetY = 285;
    [self.view addSubview:_addMap];
    
    // Create a button with icon
    _ZoomPanIcon = [[DLDataIconView alloc]initWithFrame:CGRectMake(240, kValueOffsetY + 150, 50, 50) icon:FALocationArrow title:nil];
    [self.view addSubview:_ZoomPanIcon];
    _ZoomPanIcon.delegate = self;
    _ZoomPanIcon.selected = YES;
    _addMap.userTrackingMode = MKUserTrackingModeFollow;
    
    if(!_isAdd) {
      // Add a polyline for all of the points that are in the set
      [self addPolylineForStoredPoints:_currCell.dataPoint.DataValue];
    }
    
  } else {
    _dataName = [[UITextField alloc] initWithFrame:CGRectMake(10, kValueOffsetY, 350, 50)];
    
    ((UITextField *)_dataName).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
    
    ((UITextField *)_dataName).borderStyle = UITextBorderStyleNone;
    ((UITextField *)_dataName).returnKeyType = UIReturnKeyDone;
    ((UITextField *)_dataName).autocorrectionType = UITextAutocorrectionTypeNo;
    ((UITextField *)_dataName).delegate = self;
    ((UITextField *)_dataName).keyboardType = UIKeyboardTypeDecimalPad;
    
    if ((_isAdd) || ([_currCell.title length]== 0)) {
      _backgroundText = [[UILabel alloc] initWithFrame:CGRectMake(10, kValueOffsetY, 350, 50)];
      _backgroundText.text = @"Data Value";
      _backgroundText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
      _backgroundText.textColor = [UIColor lightGrayColor];
      [self.view addSubview:_backgroundText];
    }
  }
  
  if (!_isAdd) {
    ((UILabel *)_dataName).text = _currCell.title;
    
    // Change the title into
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *minutes = [_currCell.title substringWithRange:NSMakeRange(0, 2)];
    NSString *seconds = [_currCell.title substringWithRange:NSMakeRange(3, 2)];
    NSString *milliSeconds = [_currCell.title substringWithRange:NSMakeRange(6, 2)];
    
    NSNumber *iMinutes = [f numberFromString:minutes];
    NSNumber *iSeconds = [f numberFromString:seconds];
    NSNumber *iMilliSeconds = [f numberFromString:milliSeconds];
    
    currPausedTime = [iMinutes intValue] * 60 + [iSeconds intValue] + [iMilliSeconds floatValue] / 100;
    
  } else if ([_typeName isEqualToString:@"Time"]) {
    ((UILabel *)_dataName).text = @"00:00.00";
  }
  
  UIView *dataDivider;
  if ([_typeName isEqualToString:@"GPS"]) {
    dataDivider = [[UIView alloc] initWithFrame:CGRectMake(5, kNotesOffsetY - 25, 310, 1)];
  } else {
    dataDivider = [[UIView alloc] initWithFrame:CGRectMake(5, kNotesOffsetY - 35, 310, 1)];
  }
  dataDivider.backgroundColor = [UIColor lightGrayColor];
  [self.view addSubview:dataDivider];
  
  UILabel *iconDataLabel;
  if ([_typeName isEqualToString:@"GPS"]) {
    iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kNotesOffsetY - 15, 300, 50)];
  } else {
    iconDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kNotesOffsetY, 300, 50)];
  }
  iconDataLabel.text = @"Notes: ";
  iconDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  if ([_typeName isEqualToString:@"GPS"]) {
    _notes = [[UITextField alloc] initWithFrame:CGRectMake(100, kNotesOffsetY - 15, 200, 40)];
  } else {
    _notes = [[UITextField alloc] initWithFrame:CGRectMake(100, kNotesOffsetY, 200, 50)];
  }
  _notes.borderStyle = UITextBorderStyleRoundedRect;
  _notes.returnKeyType = UIReturnKeyDone;
  _notes.autocorrectionType = UITextAutocorrectionTypeNo;
  _notes.delegate = self;
  _notes.keyboardType = UIKeyboardTypeDefault;
  _notes.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
  
  CGRect frameRect = _notes.frame;
  
  if ([_typeName isEqualToString:@"GPS"]) {
    frameRect.size.height = 60;
  } else {
    frameRect.size.height = 90;
  }
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

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
  // Check to see if user panned it. If so stop updating
  
  UIView* view = mapView.subviews.firstObject;
  
  for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
	{
		//	The user caused of this...
		if(recognizer.state == UIGestureRecognizerStateBegan
		   || recognizer.state == UIGestureRecognizerStateEnded)
		{
			_userPanning = YES;
      _ZoomPanIcon.selected = NO;
      _addMap.userTrackingMode = MKUserTrackingModeNone;
			break;
		}
	}
}

- (void) iconClicked:(DLDataIconView *)icon
{
  _ZoomPanIcon.selected = YES;
  _addMap.userTrackingMode = MKUserTrackingModeFollow;
  _userPanning = NO;
  [_addMap setRegion:_lastSetRegion animated:YES];
}

- (void) addPolylineForStoredPoints: (NSString *) value
{
  // The first line in the string is time and distance
  // Time: ... , Distance: ... , \n
  // Proceeding values are (latitude)float ... , (longitude)float ... , \n
  
  int timeColonIdx = 0;
  int timeCommaIdx = 0;
  int distanceColonIdx = 0;
  int distanceCommaIdx = 0;
  int i = 0;
  
  //Read in the time
  for (i = 0; i < value.length; i++)
  {
      // Find the colon first
    if ([value characterAtIndex:i] == ':') {
      timeColonIdx = i;
    } else if ( [value characterAtIndex:i] == ',') {
      timeCommaIdx = i;
      break;
    }
  }
  
  i++;
  
  //Read in the distance
  for ( i; i < value.length; i++)
  {
    // Find the colon first
    if ([value characterAtIndex:i] == ':') {
      distanceColonIdx = i;
    } else if ( [value characterAtIndex:i] == ',') {
      distanceCommaIdx = i;
      break;
    }
  }
  
  i++;
  
  int latitudeStartIdx = 0;
  int latitudeEndIdx = 0;
  
  int longitudeStartIdx = 0;
  int longitudeEndIdx = 0;
  
  //Read in all of the stored points
  for (i; i < value.length; i++)
  {
    if ( [value characterAtIndex:i] == '\n') {
      latitudeStartIdx = i+1;
    } else if ( [value characterAtIndex:i] == ',') {
      if (latitudeEndIdx == 0) {
        latitudeEndIdx = i;
        longitudeStartIdx = (i+1);
      } else {
        longitudeEndIdx = i;
        
        //Read in the values here
        NSString *latitude = [value substringWithRange:NSMakeRange(latitudeStartIdx, (latitudeEndIdx - latitudeStartIdx))];
        NSString *longitude = [value substringWithRange:NSMakeRange(longitudeStartIdx, (longitudeEndIdx - longitudeStartIdx))];
        
        mapPoints[mapPointCount] = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        mapPointCount++;
        
        latitudeEndIdx = 0;
      }
    }
  }
  
  myPolyline = [MKPolyline polylineWithCoordinates:mapPoints count:mapPointCount];
  [_addMap addOverlay:myPolyline];
  
  [_addMap setVisibleMapRect:[myPolyline boundingMapRect] edgePadding:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) animated:NO];
  
  NSString *time = [value substringWithRange:NSMakeRange(timeColonIdx + 2, (timeCommaIdx - timeColonIdx - 2))];
  NSString *distance = [value substringWithRange:NSMakeRange(distanceColonIdx + 2, (distanceCommaIdx - distanceColonIdx - 2))];
  
  double timeNum = [time doubleValue];
  double distanceNum = [distance doubleValue];
  
  _distanceText.text = [NSString stringWithFormat:@"%.01f m", distanceNum];
  
  int numMinutes = timeNum / 60;
  int numMinutesTen = numMinutes / 10;
  
  int numSeconds = (timeNum - numMinutes * 60);
  int numSecondsTen = numSeconds / 10;
  
  int numMilli = (timeNum - numSeconds) * 100;
  int numMilliTen = numMilli / 10;
  numMilli -= numMilliTen * 10;
  
  numMinutes -= numMinutesTen * 10;
  numSeconds -= numSecondsTen * 10;
  
  _timeText.text = [NSString stringWithFormat:@"%i%i:%i%i.%i%i", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
  
  _elapsedTime = timeNum;
  _elapsedDistance = distanceNum;
  
  _userPanning = YES;
  _ZoomPanIcon.selected = NO;
  _addMap.userTrackingMode = MKUserTrackingModeNone;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
  if (!_start) {
    CLLocationCoordinate2D userLocationCoord = userLocation.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocationCoord, currZoom, currZoom);
    MKCoordinateRegion adjustedRegion = [_addMap regionThatFits:viewRegion];
    _lastSetRegion = adjustedRegion;
    _existingCentroidLatitude = userLocationCoord.latitude;
    _existingCentroidLongitude = userLocationCoord.longitude;
    
    if (!_userPanning) {
      if (!_changeMapZoomOnce) {
        _changeMapZoomOnce = YES;
        [_addMap setRegion:adjustedRegion animated:NO];
      } else {
         [_addMap setCenterCoordinate:userLocationCoord animated:YES];
      }
    }
  }
  NSLog(@"Point coming from cllocationdelegate");
  [self DidGetLocation:userLocation.coordinate];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  if ([overlay isKindOfClass:MKPolyline.class]) {
    MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    lineView.strokeColor = [UIColor redColor];
    lineView.lineWidth = 2.0;
    
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
#if TARGET_IPHONE_SIMULATOR
                                 selector:@selector(testMapUpdate)
#else
                                 selector:@selector(updateLocation)
#endif
                                 userInfo:nil
                                  repeats:YES];
  
  _start = [NSDate date];
  
  //[_locationManager startUpdatingLocation];
  //_locationManager.delegate = self;
}

- (void) stopTrackingLocation
{
  [locationUpdateTimer invalidate];
  locationUpdateTimer = nil;
  [locationTracker stopLocationTracking];
  _start = nil;
  //[_locationManager stopUpdatingLocation];
  //_locationManager.delegate = nil;
}

-(void) testMapUpdate
{
  CLLocationCoordinate2D location;
  location.latitude = mapPointCount / (double)5000.0;
  location.longitude = mapPointCount / (double)5000.0;
  
  NSLog(@"Coming from test map update");
  [self DidGetLocation:location];
}

-(void)updateLocation {
  NSLog(@"updateLocation");
  
  [locationTracker updateLocationToServer];
}

-(CLLocationCoordinate2D) CalculateCentroidwithNewLocation:(CLLocationCoordinate2D) newLocation
{
  double newCentroidLatitude;
  double newCentroidLongitude;
  
  if (_existingCentroidLatitude) {
    newCentroidLatitude = ((_existingCentroidLatitude * mapPointCount) + newLocation.latitude) / (mapPointCount + 1);
    newCentroidLongitude = ((_existingCentroidLongitude * mapPointCount) + newLocation.longitude) / (mapPointCount + 1);
  } else {
    newCentroidLatitude = 0;
    newCentroidLongitude = 0;
    for (int i = 0; i < mapPointCount; i++)
    {
      newCentroidLatitude += mapPoints[i].latitude;
      newCentroidLongitude += mapPoints[i].longitude;
    }
    
    newCentroidLatitude += newLocation.latitude;
    newCentroidLongitude += newLocation.longitude;
    
    newCentroidLatitude /= (mapPointCount +1);
    newCentroidLongitude /= (mapPointCount +1);
  }
  
  CLLocationCoordinate2D newCentroid;
  newCentroid.latitude = newCentroidLatitude;
  newCentroid.longitude = newCentroidLongitude;
  
  _existingCentroidLatitude = newCentroidLatitude;
  _existingCentroidLongitude = newCentroidLongitude;
  
  return newCentroid;

}

-(void) DidGetLocation:(CLLocationCoordinate2D) location
{
#if TARGET_IPHONE_SIMULATOR
#else
  if ((location.latitude == 0) && (location.longitude == 0))
  {
    //In the middle of the ocean, so just return
    return;
  }
#endif
  
  if (!_start || !_timerStarted) {
    //Don't track location until we hit start
    return;
  }
  
  //Calculate distance elapsed
  CLLocation* newLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
  
  if (mapPointCount > 0) {
    CLLocationDistance elapsedDist = [newLocation distanceFromLocation:_previousLocation];
    _elapsedDistance += elapsedDist;
    
    _distanceText.text = [NSString stringWithFormat:@"%.01f m", _elapsedDistance];
  } else {
    _elapsedDistance = 0;
  }
  
  _previousLocation = newLocation;
  
  //Calculate centroid of location
  //CLLocationCoordinate2D centroid = [self CalculateCentroidwithNewLocation:location];
  
  // If in background, store either way
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, currZoom, currZoom);
  MKCoordinateRegion adjustedRegion = [_addMap regionThatFits:viewRegion];
  
  _lastSetRegion = adjustedRegion;
  
  if (!_userPanning ) {
    [_addMap setCenterCoordinate:location animated:YES];
  }
  
  if (mapPointCount == 0) {
    mapPoints[mapPointCount] = location;
    mapPointCount++;
  } else if ((location.latitude != mapPoints[mapPointCount].latitude) ||
             (location.longitude != mapPoints[mapPointCount].longitude) ) {
    mapPoints[mapPointCount] = location;
    mapPointCount++;
  }
  
  if (mapPointCount > 1) {
    myPolyline = [MKPolyline polylineWithCoordinates:mapPoints count:mapPointCount];
    
    for (id<MKOverlay> overlayToRemove in _addMap.overlays)
    {
      if ([overlayToRemove isKindOfClass:[MKPolyline class]])
      {
        [_addMap removeOverlay:overlayToRemove];
      }
    }
    
    [_addMap addOverlay:myPolyline];
  }
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
  y += theFrame.size.height;
  y -= 15;
  [self scrollToY:-y];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
  [self.view setFrame:CGRectMake(0,0,320,460)];
}

- (void) setupTimer
{
  //Add buttons for start, stop
  _startButton =  [UIButton buttonWithType:UIButtonTypeCustom];
  [_startButton setTitle:@"Start" forState:UIControlStateNormal];
  [_startButton sizeToFit];
  _startButton.center = CGPointMake(90, kButtonOffsetY);
  _startButton.titleLabel.textColor = greenWatchColor;
  [ _startButton setTitleColor:greenWatchColor forState:UIControlStateNormal];
  [_startButton addTarget:self action:@selector(StartTimerClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  int _startCircleX = _startButton.frame.origin.x - (_startButton.frame.size.width * 2 - _startButton.frame.size.width) / (2);
  int _startCircleY = _startButton.frame.origin.y - 2 - (_startButton.frame.size.width * 2 - _startButton.frame.size.width) / (2);
  
  _startCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(_startCircleX, _startCircleY, _startButton.frame.size.width * 2, _startButton.frame.size.width * 2) strokeWidth:1.0 selectFill:NO selectColor:greenWatchColor boundaryColor:greenWatchColor];
  _startCircle.selected = NO;
  _startCircle.backgroundColor = [UIColor clearColor];
  
  UITapGestureRecognizer *circleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(StartTimerClicked:)];
  circleRecognizer.numberOfTouchesRequired = 1;
  [_startCircle addGestureRecognizer:circleRecognizer];
  [self.view addSubview:_startCircle];
  
  _resetButton =  [UIButton buttonWithType:UIButtonTypeCustom];
  [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
  [_resetButton sizeToFit];
  [ _resetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  _resetButton.center = CGPointMake(230, kButtonOffsetY);
  _resetButton.enabled = NO;
  [_resetButton addTarget:self action:@selector(ResetTimerClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  int _resetCircleX = _resetButton.frame.origin.x - (_startButton.frame.size.width * 2 - _resetButton.frame.size.width) / (2);
  int _resetCircleY = _startCircleY;
  
  _resetCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(_resetCircleX, _resetCircleY, _startButton.frame.size.width * 2, _startButton.frame.size.width * 2) strokeWidth:1.0 selectFill:NO selectColor:[UIColor lightGrayColor] boundaryColor:[UIColor lightGrayColor]];
  _resetCircle.selected = NO;
  _resetCircle.backgroundColor = [UIColor clearColor];
  [self.view addSubview:_resetCircle];
  
  UITapGestureRecognizer *resetCircleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ResetTimerClicked:)];
  resetCircleRecognizer.numberOfTouchesRequired = 1;
  [_resetCircle addGestureRecognizer:resetCircleRecognizer];
  
  _start = nil;
  
  [self.view addSubview:_startButton];
  [self.view addSubview:_resetButton];
}

- (void) setupGPS
{
  //Add buttons for start, stop
  _startButton =  [UIButton buttonWithType:UIButtonTypeCustom];
  [_startButton setTitle:@"Start" forState:UIControlStateNormal];
  [_startButton sizeToFit];
  _startButton.center = CGPointMake(90, kNotesOffsetY + 90);
  _startButton.titleLabel.textColor = greenWatchColor;
  [ _startButton setTitleColor:greenWatchColor forState:UIControlStateNormal];
  [_startButton addTarget:self action:@selector(StartGPSClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  int _startCircleX = _startButton.frame.origin.x - (_startButton.frame.size.width * 2 - _startButton.frame.size.width) / (2);
  int _startCircleY = _startButton.frame.origin.y - 2 - (_startButton.frame.size.width * 2 - _startButton.frame.size.width) / (2);
  
  _startCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(_startCircleX, _startCircleY, _startButton.frame.size.width * 2, _startButton.frame.size.width * 2) strokeWidth:1.0 selectFill:NO selectColor:greenWatchColor boundaryColor:greenWatchColor];
  _startCircle.selected = NO;
  _startCircle.backgroundColor = [UIColor clearColor];
  
  UITapGestureRecognizer *circleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(StartTimerClicked:)];
  circleRecognizer.numberOfTouchesRequired = 1;
  [_startCircle addGestureRecognizer:circleRecognizer];
  [self.view addSubview:_startCircle];
  
  _resetButton =  [UIButton buttonWithType:UIButtonTypeCustom];
  [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
  [_resetButton sizeToFit];
  [ _resetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  _resetButton.center = CGPointMake(230, kNotesOffsetY + 90);
  _resetButton.enabled = NO;
  [_resetButton addTarget:self action:@selector(ResetGPSClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  int _resetCircleX = _resetButton.frame.origin.x - (_startButton.frame.size.width * 2 - _resetButton.frame.size.width) / (2);
  int _resetCircleY = _startCircleY;
  
  _resetCircle = [[DLCircleView alloc] initWithFrame:CGRectMake(_resetCircleX, _resetCircleY, _startButton.frame.size.width * 2, _startButton.frame.size.width * 2) strokeWidth:1.0 selectFill:NO selectColor:[UIColor lightGrayColor] boundaryColor:[UIColor lightGrayColor]];
  _resetCircle.selected = NO;
  _resetCircle.backgroundColor = [UIColor clearColor];
  [self.view addSubview:_resetCircle];
  
  UITapGestureRecognizer *resetCircleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ResetGPSClicked:)];
  resetCircleRecognizer.numberOfTouchesRequired = 1;
  [_resetCircle addGestureRecognizer:resetCircleRecognizer];
  
  _start = nil;
  
  [self.view addSubview:_startButton];
  [self.view addSubview:_resetButton];
}

- (void) StartGPSClicked: (UIButton *)gpsButton
{
  if (!_timerStarted) {
    _timerStarted = YES;
    [self startTrackingLocation];
    
    if (!_start) {
      _start = [NSDate date];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                              target:self
                                            selector:@selector(updateTime)
                                            userInfo:nil
                                             repeats:YES];
    
    [ _startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_startCircle setBoundaryColor:[UIColor redColor]];
    _startButton.titleLabel.text = @"Stop";
    [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    [_resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_resetCircle setBoundaryColor:[UIColor blackColor]];
    
    _resetButton.enabled = YES;
  } else {
    _elapsedTime = [_start timeIntervalSinceNow];
    currPausedTime = [_start timeIntervalSinceNow] * -1 + currPausedTime;
    
    _timerStarted = NO;
    
    _start = nil;
    [_timer invalidate];
    _timer = nil;
    
    [self stopTrackingLocation];
    
    [ _startButton setTitleColor:[UIColor colorWithRed:0 green:204/255.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
    [_startCircle setBoundaryColor:[UIColor colorWithRed:0 green:204/255.0 blue:0 alpha:1.0]];
    _startButton.titleLabel.text = @"Start";
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
  }
}

- (void) ResetGPSClicked: (UIButton *)resetButton
{
  if (_timer)
  {
    [_timer invalidate];
    _timer = nil;
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitleColor:greenWatchColor forState:UIControlStateNormal];
    [_startCircle setBoundaryColor:greenWatchColor];
    
    _timerStarted = false;
  }
  
  //Reset the clock
  _start = nil;
  _elapsedTime = 0;
  _timeText.text = @"00:00.00";
  
  //Reset the distance text
  _elapsedDistance = 0;
  _distanceText.text = @"0 m";
  
  //Reset the polyline points
  mapPointCount = 0;
  
  for (id<MKOverlay> overlayToRemove in _addMap.overlays)
  {
    if ([overlayToRemove isKindOfClass:[MKPolyline class]])
    {
      [_addMap removeOverlay:overlayToRemove];
    }
  }
  
  [_resetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  [_resetCircle setBoundaryColor:[UIColor lightGrayColor]];
  _resetButton.enabled = NO;
  
  currPausedTime = 0;
  ((UILabel *)_dataName).text = @"00:00.00";
  _didEdit = YES;
}

- (void) ResetTimerClicked: (UIButton *)resetButton
{
  //Invalidate the current timer
  if (_timer)
  {
    [_timer invalidate];
    _timer = nil;
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitleColor:greenWatchColor forState:UIControlStateNormal];
    [_startCircle setBoundaryColor:greenWatchColor];
    
    _timerStarted = false;
    //Reset the clock
    _start = nil;
    ((UILabel *)_dataName).text = @"00:00.00";
  }
  
  [_resetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  [_resetCircle setBoundaryColor:[UIColor lightGrayColor]];
  
  _resetButton.enabled = NO;
  
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
    
    //[_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    [ _startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_startCircle setBoundaryColor:[UIColor redColor]];
    _startButton.titleLabel.text = @"Stop";
    [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    [_resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_resetCircle setBoundaryColor:[UIColor blackColor]];
    
    _resetButton.enabled = YES;
    
  } else {
    currPausedTime = [_start timeIntervalSinceNow] * -1 + currPausedTime;
    _start = nil;
    [_timer invalidate];
    _timer = nil;
    [ _startButton setTitleColor:[UIColor colorWithRed:0 green:204/255.0 blue:0 alpha:1.0] forState:UIControlStateNormal];
    [_startCircle setBoundaryColor:[UIColor colorWithRed:0 green:204/255.0 blue:0 alpha:1.0]];
    _startButton.titleLabel.text = @"Start";
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
  }
  _timerStarted = !_timerStarted;
}

-(void) updateTime
{
  NSTimeInterval timeInterval = [_start timeIntervalSinceNow];
  timeInterval *= -1;
  timeInterval += currPausedTime;
  
  int numMinutes = timeInterval / 60;
  int numMinutesTen = numMinutes / 10;
  
  int numSeconds = (timeInterval - numMinutes * 60 );
  int numSecondsTen = numSeconds / 10;
  
  int numMilli = (timeInterval - numSeconds - numMinutes * 60 ) * 100;
  int numMilliTen = numMilli / 10;
  numMilli -= numMilliTen * 10;
  
  numMinutes -= numMinutesTen * 10;
  numSeconds -= numSecondsTen * 10;
  
  if ([_typeName isEqualToString:@"GPS"]) {
    _timeText.text = [NSString stringWithFormat:@"%i%i:%i%i.%i%i", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
  } else {
  ((UILabel *)_dataName).text = [NSString stringWithFormat:@"%i%i:%i%i.%i%i", numMinutesTen, numMinutes, numSecondsTen, numSeconds, numMilliTen, numMilli];
  }
}

- (void) CancelClicked
{
  [self stopTrackingLocation];
  
  if (_addMap) {
    _addMap.showsUserLocation = NO;
  }
  
  if (_timer){
    [_timer invalidate];
    _timer = nil;
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) CreateClicked
{
  if (_isAdd)
  {
    if ([_typeName isEqualToString:@"GPS"]) {
      NSString* dataName = _setName;
      
      NSMutableString* dataValue = [NSMutableString string];
      
      if (_start) {
        // User did not click stop before hitting save
        _elapsedTime = [_start timeIntervalSinceNow];
        
        [_timer invalidate];
        _timer = nil;
        
        [self stopTrackingLocation];
      }
      
      //Store total distance, time elapsed
      [dataValue appendString:[NSString stringWithFormat:@"Time: %f, Distance: %f, \n", -1 * _elapsedTime, _elapsedDistance]];
      
      for (int i = 0; i < mapPointCount; i++)
      {
        [dataValue appendString:[NSString stringWithFormat:@"%.7f, %.7f, \n", mapPoints[i].latitude, mapPoints[i].longitude]];
      }
      
      NSString* notes = _notesView.text;
      
      NSDate *currentTime = [NSDate date];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.dateFormat = @"MM/dd/yy, hh:mm a:ss";
      NSString *resultString = [dateFormatter stringFromDate: currentTime];
      
      //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
      DLDataPointRowObject *newObject = [[DLDataPointRowObject alloc]
                                         initWithName:dataName
                                         value:dataValue
                                         time:resultString
                                         notes:notes];
      
      [newObject save];
      [_delegate didCreateNewObject:newObject];
      
    } else {
      NSLog(@"Create Clicked");
      NSString* dataName = _setName;
      //NSInteger row = [_typeDataView selectedRowInComponent:0];
      NSString* dataValue =  ((UILabel *)_dataName).text;
      NSString* notes = _notesView.text;
      
      NSDate *currentTime = [NSDate date];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.dateFormat = @"MM/dd/yy, hh:mm a:ss";
      NSString *resultString = [dateFormatter stringFromDate: currentTime];
      
      //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
      DLDataPointRowObject *newObject = [[DLDataPointRowObject alloc]
                                          initWithName:dataName
                                                 value:dataValue
                                                  time:resultString
                                                 notes:notes];
      
      [newObject save];
      [_delegate didCreateNewObject:newObject];
    }
  } else if (_didEdit) {
    // Save changes to database
    NSString* dataName = _setName;
    //NSInteger row = [_typeDataView selectedRowInComponent:0];
    NSString* dataValue;
    NSString* notes = _notesView.text;
    
    if ([_typeName isEqualToString:@"GPS"]) {
      dataValue = [NSMutableString string];
      
      if (_start) {
        // User did not click stop before hitting save
        _elapsedTime = [_start timeIntervalSinceNow];
        
        [_timer invalidate];
        _timer = nil;
        
        [self stopTrackingLocation];
      }
      
      //Store total distance, time elapsed
      [(NSMutableString *)dataValue appendString:[NSString stringWithFormat:@"Time: %f, Distance: %f, \n", -1 * _elapsedTime, _elapsedDistance]];
      
      for (int i = 0; i < mapPointCount; i++)
      {
        [(NSMutableString *)dataValue appendString:[NSString stringWithFormat:@"%.7f, %.7f, \n", mapPoints[i].latitude, mapPoints[i].longitude]];
      }

    } else {
      dataValue =  ((UILabel *)_dataName).text;
    }
    
    NSString *timeString = _currCell.time;
    
    //NSLog(@"Name: %@, Type: %@, Icon: %@", dataName, dataType, iconStr);
    DLDataPointRowObject *newObject = [[DLDataPointRowObject alloc]
                                       initWithName:dataName
                                       value:dataValue
                                       time:timeString
                                       notes:notes];
    
    [[DLDatabaseManager getSharedInstance] updateOldPoint: [_currCell dataPoint] newPoint: newObject];
    
    [_delegate didEditObject:_currCell withData:newObject];
  }
  
  _addMap.showsUserLocation = NO;
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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
  
  if ([_typeName isEqual:@"GPS"])
    [self scrollToY:-142];
  else
    [self scrollToY:-40];
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
