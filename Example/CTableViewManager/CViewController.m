//
//  CViewController.m
//  CTableViewManager
//
//  Created by nbyh100@sina.com on 12/22/2017.
//  Copyright (c) 2017 nbyh100@sina.com. All rights reserved.
//

#import "CViewController.h"
#import <CTableViewManager/CTableViewManager.h>

@interface CViewController ()

@property (nonatomic, strong) CTableViewManager *manager;

@end

@implementation CViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.manager = [CTableViewManager new];
    self.tableView.dataSource = self.manager;
    self.tableView.delegate = self.manager;
}

@end
