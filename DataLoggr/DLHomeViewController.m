//
//  DLHomeViewController.m
//  DataLoggr
//
//  Created by Michael Weingert on 7/10/14.
//  Copyright (c) 2014 Weingert. All rights reserved.
//

#import "DLHomeViewController.h"
#import "DLDataViewController.h"
#import "DLHomeTableViewCell.h"
#import "DLTitleTableViewCell.h"
#import "DLNewDataViewController.h"
#import "NSString+FontAwesome.h"
#import "DLDataRowObject.h"
#import "DLDataViewCell.h"

#import "DLDatabaseManager.h"

#import <UIKit/UITableView.h>

@interface DLHomeViewController ()
{
  UITableView* chartTable;
  BOOL invalidatedData;
  NSMutableArray* rowData;
  BOOL newData;
  BOOL _isEditClicked;
}
@end

@implementation DLHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init {
  self = [super init];
  
  chartTable = [[UITableView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
  chartTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  //chartTable.delegate = self;
  chartTable.dataSource = self;
  
  self.view = chartTable;
  
  self.title = @"Your Data";
  
  invalidatedData = YES;
  newData = NO;
  _isEditClicked = NO;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(TitleCellTouched:)];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(EditClicked)];
  
  return self;
}

- (UITableViewCell *) tableView: (UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *myIdentifier = @"HomeCells";
  
  if ([indexPath row] == 0)
  {
    
    DLTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil)
    {
      cell = [[DLTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier];
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.delegate = self;
    }
    
    return cell;
  }
  
  DLHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
  
  if (cell == nil) {
    DLDataRowObject *currItem;
    
    if ([indexPath row] <= [rowData count])
      currItem = rowData[[indexPath row] - 1];
    else
      currItem = [[DLDataRowObject alloc] initWithName:@"SampleData" type:@"NotImportant" iconName:@"FAGithub"];
      
    cell = [[DLHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:myIdentifier
                                              caption: currItem.DataName
                                                 icon: [NSString fontAwesomeEnumForIconIdentifier:currItem.IconName ]
                                                 type: currItem.DataType
                                            rowObject: currItem];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
  }
  
  return cell;
}

- (void) DoneClicked
{
  //Shift all of the rows to the left
  
  UITableView *tableView = (UITableView *)self.view; // Or however you get your table view
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  //  For getting the cells themselves
  NSMutableSet *visibleCells = [[NSMutableSet alloc] init];
  
  for (NSIndexPath *path in paths) {
    if ([path row] == 0) {
      continue;
    }
    
    [visibleCells addObject:[tableView cellForRowAtIndexPath:path]];
  }
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(EditClicked)];
  
  for (DLHomeTableViewCell * cell in visibleCells) {
    [cell unAnimateForEdit];
  }
  
  _isEditClicked = NO;
}

- (void) EditClicked
{
  //Shift all of the rows to the right
  
  UITableView *tableView = (UITableView *)self.view; // Or however you get your table view
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  //  For getting the cells themselves
  NSMutableSet *visibleCells = [[NSMutableSet alloc] init];
  
  for (NSIndexPath *path in paths) {
    if ([path row] == 0) {
      continue;
    }
    
    [visibleCells addObject:[tableView cellForRowAtIndexPath:path]];
  }
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneClicked)];
  
  for (DLHomeTableViewCell * cell in visibleCells) {
    [cell animateForEdit];
  }
  
  _isEditClicked = YES;
}

- (void) didUpdateCell: (DLHomeTableViewCell *) updatedCell withData: (DLDataRowObject *)newObject
{
  UITableView *tableView = (UITableView *)self.view; // Or however you get your table view
  NSArray *paths = [tableView indexPathsForVisibleRows];
  
  //  For getting the cells themselves
  NSMutableSet *visibleCells = [[NSMutableSet alloc] init];
  
  for (NSIndexPath *path in paths) {
    if ([path row] == 0) {
      continue;
    }
    
    DLHomeTableViewCell * currCell = [tableView cellForRowAtIndexPath:path];
    if (currCell == updatedCell)
    {
      currCell.title = newObject.DataName;
      currCell.icon = [NSString fontAwesomeEnumForIconIdentifier:newObject.IconName];
      currCell.type = newObject.DataType;
      
      DLDataRowObject * currRowObj = (DLDataRowObject *)rowData[[path row] - 1];
      
      currRowObj.DataName = newObject.DataName;
      currRowObj.IconName = newObject.IconName;
      currRowObj.DataType = newObject.DataType;
      
      [currCell setNeedsDisplay];
      
      newData = YES;
    }
  }
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return ([rowData count] + 1);
}

- (void) CellViewTouched :(DLDataViewCell *) cell
{
  if (_isEditClicked) {
    DLNewDataViewController *editViewController = [[ DLNewDataViewController alloc] initWithDelegate:self isEdit:YES cell:cell];
    
    [self.navigationController pushViewController:editViewController animated:YES];
  } else {
    DLDataViewController *newDataController = [[DLDataViewController alloc]initWithDataValue: cell.title dataType: cell.type];
    
    [self.navigationController pushViewController:newDataController animated:YES];
  }
}

-(void) TitleCellTouched:(NSInteger) number
{
  DLNewDataViewController *newDataController = [[ DLNewDataViewController alloc] initWithDelegate:self isEdit:NO cell:nil];
  
  [self.navigationController pushViewController:newDataController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) didCreateNewObject:(DLDataRowObject *)newObject
{
  //Just invalidate data now. Do a fresh reinstall
  newData = YES;
  //Add data to row
  [rowData addObject:newObject];
}

- (void) viewWillAppear:(BOOL)animated
{
  if (invalidatedData) {
    DLDatabaseManager *sharedInstance = [DLDatabaseManager getSharedInstance];
    
    rowData = [sharedInstance fetchDataNames];
    invalidatedData = NO;
  }
  else if (newData)
  {
    UITableView * tableView = (UITableView *)self.view;
    [tableView reloadData];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
