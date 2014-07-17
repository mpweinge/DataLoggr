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

#import "DLDatabaseManager.h"

#import <UIKit/UITableView.h>

@interface DLHomeViewController ()
{
  UITableView* chartTable;
  BOOL invalidatedData;
  NSMutableArray* rowData;
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
  
  //NSLog(ret);
  
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
                                                 icon: [NSString fontAwesomeEnumForIconIdentifier:currItem.IconName ]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
  }
  
  //Configure the cell
  //cell.textLabel.text = @"GYM";
  
  return cell;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (void) CellViewTouched :(NSInteger) cellIdentifier
{
  DLDataViewController *newDataController = [[DLDataViewController alloc]initWithDataValue: cellIdentifier];
  
  [self.navigationController pushViewController:newDataController animated:YES];
}

-(void) TitleCellTouched:(NSInteger) number
{
  DLNewDataViewController *newDataController = [[ DLNewDataViewController alloc] init];
  
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
  invalidatedData = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
  DLDatabaseManager *sharedInstance = [DLDatabaseManager getSharedInstance];
  
  rowData = [sharedInstance fetchDataNames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
