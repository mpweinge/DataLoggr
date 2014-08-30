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

#import "CorePlot-CocoaTouch.h"

@interface DLDataViewController ()
{
  UITableView* chartTable;
  NSMutableArray *dataValues;
  NSString* _setName;
  NSString *_typeName;
  BOOL newData;
  BOOL invalidateData;
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

-(instancetype) initWithDataValue: (NSString*) setName dataType: (NSString *)dataType
{
  self = [super init];
  
  chartTable = [[UITableView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
  chartTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  chartTable.delegate = self;
  chartTable.dataSource = self;
  
  _setName = setName;
  
  self.view = chartTable;
  
  //Let's take the cellIdentifier and get all the data points from it
  dataValues = [[DLDatabaseManager getSharedInstance] fetchDataPoints:setName];
  
  self.title = setName;
  
  invalidateData = YES;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddClicked)];
    
    _typeName = dataType;
  
  return self;
}

- (UITableViewCell *) tableView: (UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *myIdentifier = @"HomeCells";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
  
  if ( [indexPath row] == 0 ) {
    //if (cell == nil) {
      DLGraphViewCell *graphCell = [[DLGraphViewCell alloc]  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier dataPoints:dataValues type:_typeName];
      
      cell = graphCell;
    //}
  }
  else /*if (cell == nil)*/ {
    
    DLDataPointRowObject *currItem = nil;
    if ([indexPath row] <= [dataValues count])
    {
      currItem = dataValues[[indexPath row] - 1];
    }
    
    DLDataViewCell * newCell;
    
    if (currItem != nil) {
      newCell = [[DLDataViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                 reuseIdentifier:myIdentifier
                                                name:currItem.DataName
                                           value:currItem.DataValue
                                            time:currItem.DataTime
                                           notes:currItem.DataNotes
                                           dataObject:currItem];
    }
    else {
      newCell = [[DLDataViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:myIdentifier
                                                 name:@"No Name Yet"
                                             value:@"Insert values!"
                                              time:@"No time yet"
                                             notes:@"No notes yet"
                                           dataObject:nil];
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
        return 310;
    } else {
        return 50;
    }
}

- (void) AddClicked
{
    [self TitleCellTouched:0];
}

-(void) TitleCellTouched:(NSInteger) number
{
  //This is a call to create a new value
  DLAddPointViewController *newPointController = [[ DLAddPointViewController alloc] initWithSetName:_setName delegate:self isAdd: YES currCell: nil typeName:_typeName];
  
  [self.navigationController pushViewController:newPointController animated:YES];
}

- (void) CellViewTouched:(DLDataViewCell *)cell
{
    //
  DLAddPointViewController *editPointController = [[DLAddPointViewController alloc] initWithSetName:_setName delegate:self isAdd: NO currCell: cell typeName:_typeName];
    
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
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return ([dataValues count] + 1);
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
    
    invalidateData = NO;
  }
  else if (newData)
  {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
