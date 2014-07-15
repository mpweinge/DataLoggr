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

@interface DLDataViewController ()
{
  UITableView* chartTable;
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

- (instancetype) initWithDataValue: (NSInteger) cellIdentifier
{
  self = [super init];
  
  chartTable = [[UITableView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
  chartTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  //chartTable.delegate = self;
  chartTable.dataSource = self;
  
  self.view = chartTable;
  
  //DLDatabaseManager *sharedInstance = [DLDatabaseManager getSharedInstance];
  
  //NSArray *fields = @[ @"MainText text primary key" ];
  
  //[sharedInstance createTable:@"TEST" withFields:fields];
  //[sharedInstance saveData:@"TEST" withObject:[[DataRow alloc] init]];
  //NSMutableArray *ret = [sharedInstance fetchData:@"TEST"];
  
  self.title = @"Sample Data";
  
  //NSLog(ret);
  
  return self;
}

- (UITableViewCell *) tableView: (UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *myIdentifier = @"HomeCells";
  
  DLDataViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
  
  if (cell == nil) {
    cell = [[DLDataViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myIdentifier];
    
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
