//
//  DLDataViewController.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLDataViewController.h"
#import "DLDatabaseManager.h"
#import "DLDataViewCell.h"
#import "DLDataPointRowObject.h"
#import "DLTitleTableViewCell.h"
#import "DLAddPointViewController.h"
#import "DLGraphViewCell.h"
#import "DLDataRowObject.h"

#import "CorePlot-CocoaTouch.h"

@interface DLDataViewController ()
{
  UITableView* chartTable;
  NSMutableArray *dataValues;
  NSString* _setName;
  NSString *_typeName;
  BOOL newData;
  BOOL invalidateData;
  DLGraphViewCell *_graphCell;
  BOOL _showNoPointNux;
  int _currPageNum;
  BOOL _moreClicked;
  
  NSInteger _units;
  
  DLDataRowObject *_dataObject;
}

@end

@implementation DLDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(instancetype) initWithDataValue: (NSString*) setName
                         dataType: (NSString *)dataType
                       dataObject: (DLDataRowObject *)dataObject
{
  self = [super init];
  
  chartTable = [[UITableView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
  chartTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  chartTable.delegate = self;
  chartTable.dataSource = self;
  
  _setName = setName;
  _currPageNum = 0;
  
  _units = 0;
  
  if ([dataObject.UnitsName isEqualToString:@"mi/hr"]) {
    _units = 1;
  } else if ([dataObject.UnitsName isEqualToString:@"km/hr"]) {
    _units = 2;
  } else if ([dataObject.UnitsName isEqualToString:@"hr"]) { 
    _units = 2;
  } else if ([dataObject.UnitsName isEqualToString:@"min"]) {
    _units = 1;
  }
  
  _dataObject = dataObject;
  
  self.view = chartTable;
  
  //Let's take the cellIdentifier and get all the data points from it
  dataValues = [[DLDatabaseManager getSharedInstance] fetchDataPoints:setName];
  
  self.title = setName;
  
  invalidateData = YES;
    
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddClicked)];
  
  _typeName = dataType;
  
  _showNoPointNux = YES;
  
  return self;
}

- (UITableViewCell *) tableView: (UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *myIdentifier = @"HomeCells";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
  
  if ( [indexPath row] == 0 ) {
    //if (cell == nil) {
      _graphCell = [[DLGraphViewCell alloc]  initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:myIdentifier
                                                dataPoints:dataValues
                                                      type:_typeName
                                                dataObject:_dataObject];
    _graphCell.delegate = self;
    _graphCell.clipsToBounds = YES;
    _graphCell.clipsToBounds = YES;
    _graphCell.contentView.clipsToBounds= YES;
    [_graphCell setSelectionStyle:UITableViewCellSelectionStyleNone];
      cell = _graphCell;
    //}
  } else if ((_showNoPointNux) && ([indexPath row] == 1)) {
    DLTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil)
    {
      cell = [[DLTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier isHome:NO];
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.delegate = self;
    }
    
    return cell;
  }
  else /*if (cell == nil)*/ {
    
    DLDataPointRowObject *currItem = nil;
    if ([indexPath row] <= [dataValues count])
    {
      currItem = dataValues[[indexPath row] - 1];
    }
    
    DLDataViewCell * newCell;
    
    if (currItem != nil) {
      if ( [_typeName isEqualToString:@"Custom"]) {
        newCell = [[DLDataViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:myIdentifier
                                                   name:currItem.DataName
                                                  value:currItem.DataValue
                                                   time:currItem.DataTime
                                                   type:_typeName
                                                  notes:currItem.DataNotes
                                        dataPointObject:currItem
                                                pageNum:_currPageNum
                                            stringUnits:_dataObject.UnitsName
                                             dataObject:nil];
      } else {
        newCell = [[DLDataViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:myIdentifier
                                                name:currItem.DataName
                                                value:currItem.DataValue
                                                 time:currItem.DataTime
                                                 type:_typeName
                                                notes:currItem.DataNotes
                                      dataPointObject:currItem
                                              pageNum:_currPageNum
                                                units:_units
                                           dataObject:nil];
      }
    }
    else {
      assert(0);
      /*newCell = [[DLDataViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:myIdentifier
                                                 name:@"No Name Yet"
                                                value:@"Insert values!"
                                                 time:@"No time yet"
                                                 type:nil
                                                notes:@"No notes yet"
                                           dataObject:nil
                                              pageNum:0
                                                units:0];*/
    } 
    
    newCell.selectionStyle = UITableViewCellSelectionStyleNone;
    newCell.delegate = self;
    
    cell = newCell;
  }
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row ] == 0)
    {
        //First cell is graph
        return 310 + _moreClicked * 100;
    } else {
        return 50;
    }
}

- (void) AddClicked
{
  DLAddPointViewController *newPointController = [[ DLAddPointViewController alloc] initWithSetName:_setName delegate:self isAdd: YES currCell: nil typeName:_typeName units:_dataObject.UnitsName];
  
  [self.navigationController pushViewController:newPointController animated:YES];
}

-(void) TitleCellTouched:(NSInteger) number
{
  //This is a call to create a new value
  /*DLAddPointViewController *newPointController = [[ DLAddPointViewController alloc] initWithSetName:_setName delegate:self isAdd: YES currCell: nil typeName:_typeName];
  
  [self.navigationController pushViewController:newPointController animated:YES];*/
}

- (void) CellViewTouched:(DLDataViewCell *)cell
{
    //
  DLAddPointViewController *editPointController = [[DLAddPointViewController alloc] initWithSetName:_setName delegate:self isAdd: NO currCell: cell typeName:_typeName units:_dataObject.UnitsName];
    
    [self.navigationController pushViewController:editPointController animated:YES];
}

- (void) DeleteRowClicked:(DLDataViewCell *) cell
{
  UITableView *tableView = (UITableView *)self.view; // Or however you get your table view
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  for (NSIndexPath *path in paths) {
    if ([path row] == 0) {
      continue;
    }
    
    if ([tableView cellForRowAtIndexPath:path] == cell) {
      [dataValues removeObjectAtIndex:([path row] -1)];
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
    }
  }
  
  [[DLDatabaseManager getSharedInstance] deleteDataPoint:cell.dataPoint];
  
  // Refresh the graph
  [tableView reloadData];
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if ((!_showNoPointNux ) || ([dataValues count] > 0))
  {
    return ([dataValues count] + 1);
  } else {
    return 2;
  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
  if (invalidateData) {
    DLDatabaseManager *sharedInstance = [DLDatabaseManager getSharedInstance];
    
    dataValues = [sharedInstance fetchDataPoints:_setName];
    
    if ([dataValues count] > 0)
    {
      _showNoPointNux = NO;
    }
    
    invalidateData = NO;
  }
  else if (newData)
  {
    //Before this, hide the exposed view
    _moreClicked = NO;
    
    UITableView * tableView = (UITableView *)self.view;
    [tableView reloadData];
    // [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows]
    //                 withRowAnimation:UITableViewRowAnimationNone];
  }
}

- (void) didCreateNewObject: (DLDataPointRowObject *) newObject
{
  //Just invalidate data now. Do a fresh reinstall
  newData = YES;
  _showNoPointNux = NO;
  //Add data to row
  [dataValues addObject:newObject];
}

- (void) didEditObject:(DLDataViewCell *)_currCell withData:(DLDataPointRowObject *)newObject
{
  newData = YES;
  
  UITableView *tableView = (UITableView *)self.view; // Or however you get your table view
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  for (NSIndexPath *path in paths) {
    if ([tableView cellForRowAtIndexPath:path] == _currCell)
    {
      _currCell.title = newObject.DataValue;
      _currCell.notes = newObject.DataNotes;
      _currCell.time = newObject.DataTime;
      
      dataValues[[path row] - 1] = newObject;
    }
  }
}

-(void) didChangeUnitString: (NSString *)unitString
{
  UITableView *tableView = (UITableView *)self.view;
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  for (NSIndexPath *path in paths) {
    if ([path row] == 0)
      continue;
    
    DLDataViewCell* currCell =  [tableView cellForRowAtIndexPath:path];
    
    if ([currCell isKindOfClass:[DLTitleTableViewCell class]])
      return;
    
    [currCell didChangeUnitString:unitString];
  }
}

-(void) didChangeUnits : (NSInteger) units
{
  UITableView *tableView = (UITableView *)self.view;
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  for (NSIndexPath *path in paths) {
    if ([path row] == 0)
      continue;
    
    DLDataViewCell* currCell =  [tableView cellForRowAtIndexPath:path];
    
    if ([currCell isKindOfClass:[DLTitleTableViewCell class]])
      return;
    
    [currCell didChangeUnits:units];
  }
  _units = units;
}

-(void) scrollViewDidChangePage : (NSUInteger) pageNum
{
  //Change the text of all of the cells
  UITableView *tableView = (UITableView *)self.view;
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  for (NSIndexPath *path in paths) {
    if ([path row] == 0)
      continue;
    
    DLDataViewCell* currCell =  [tableView cellForRowAtIndexPath:path];
    
    if ([currCell isKindOfClass:[DLTitleTableViewCell class]])
      return;
    
    [currCell graphViewDidScroll:pageNum];
    _currPageNum = pageNum;
  }
}

-(void) moreClicked : (BOOL) isDown;
{
  _moreClicked = isDown;
  [chartTable beginUpdates];
  [chartTable endUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

@end
