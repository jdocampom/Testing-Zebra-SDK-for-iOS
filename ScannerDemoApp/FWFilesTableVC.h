//
//  FBFilesTableViewController.h
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "FWFileCellTableViewCell.h"
#import "UpdateFirmwareVC.h"

@protocol FWFilesTableDelegate <NSObject>
- (void)getSelectedFWFile:(NSString*) path;
@end

@interface FWFilesTableVC : UITableViewController <FileSelectedDelegate>
@property (strong) NSString* path;
@property (strong) NSArray* files;
@property (nonatomic, strong) id<FWFilesTableDelegate> delegate;
- (id) initWithPath:(NSString*) path;
@end
