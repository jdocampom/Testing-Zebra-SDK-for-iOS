//
//  AssetDetailsVC.m
//  ScannerSDKApp
//
//  Created by pqj647 on 10/19/15.
//  Copyright © 2015 pqj647. All rights reserved.
//
#import "AssetDetailsVC.h"
#import "SbtScannerInfo+AssetsTblRepresentation.h"

@interface AssetDetailsVC ()

@end

@implementation AssetDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Asset Information"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(getTableData) withObject:nil withString:nil];
}

- (void)getTableData {
    didStartDataRetrieving = YES;
    self.resultDictioanry = [self.scanner_info getAssetsTblRepresentation:^(NSMutableDictionary *dictionary) {
    
        [self operationComplete];
        self.resultDictioanry = dictionary;
        [self.tableView reloadData];
        self->didStartDataRetrieving = NO;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
      }
    );
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.resultDictioanry[@"values"] isKindOfClass:[NSMutableArray class]]) {
        return ((NSMutableArray*)self.resultDictioanry[@"values"]).count;
    } else {
        return 6;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if(indexPath.row == 5){
    cell.detailTextLabel.text = self.resultDictioanry[@"values"][indexPath.row];
        cell.textLabel.text = @"Date of Manufacture";
    }else{
        cell.detailTextLabel.text = self.resultDictioanry[@"values"][indexPath.row];
    cell.textLabel.text = self.resultDictioanry[@"titles"][indexPath.row];
    }
    
    return cell;
}

@end
