//
//  AssetDetailsVC.h
//  ScannerSDKApp
//
//  Created by pqj647 on 10/19/15.
//  Copyright © 2015 pqj647 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SbtScannerInfo.h"
#import "ScannerDetailsVC.h"

@interface AssetDetailsVC : ScannerDetailsVC

@property (retain, nonatomic, readwrite) SbtScannerInfo *scanner_info;
@property (nonatomic, retain) NSMutableDictionary *resultDictioanry;

@end
