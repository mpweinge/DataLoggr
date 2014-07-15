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

#import "DLDatabaseManager.h"

#import <UIKit/UITableView.h>

@interface DLHomeViewController ()
{
  UITableView* chartTable;
}
@end

@interface DataRow :NSObject < DLSerializableProtocol >
{
  
}
@end

@implementation DataRow

- (NSString* ) serializeData
{
  return @"('NOW')";
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
  
  DLDatabaseManager *sharedInstance = [DLDatabaseManager getSharedInstance];
  
  NSArray *fields = @[ @"MainText text primary key" ];
  
  [sharedInstance createTable:@"TEST" withFields:fields];
  [sharedInstance saveData:@"TEST" withObject:[[DataRow alloc] init]];
  NSMutableArray *ret = [sharedInstance fetchData:@"TEST"];
  
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
    cell = [[DLHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myIdentifier];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
