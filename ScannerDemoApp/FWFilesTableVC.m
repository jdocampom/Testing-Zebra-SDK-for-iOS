//
//  FBFilesTableViewController.m
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import "FWFilesTableVC.h"

NSMutableString *currentPath = nil;

@interface FWFilesTableVC ()
@end

@implementation FWFilesTableVC

+ (void) initialize {
    if (self == [UITableViewController class]) { }
    currentPath = [NSMutableString stringWithFormat: @""];
}


- (id) initWithPath:(NSString*) path {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.path = path;
		self.title = [path lastPathComponent];
        NSMutableArray *matches = [[NSMutableArray alloc] init];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *item;
        NSArray *contents = [manager contentsOfDirectoryAtPath: path error: nil];
        for (item in contents) {
            if ([[item pathExtension] isEqualToString: @"DAT"] || [[item pathExtension] isEqualToString: @"SCNPLG"]) {
                [matches addObject: item];
            }
            if (item) {
                BOOL isDirectory;
                [[NSFileManager defaultManager ] fileExistsAtPath: [path stringByAppendingPathComponent: item] isDirectory: &isDirectory];
                if (isDirectory) {
                    [matches addObject: item];
                }
            }
        }
		self.files = [matches sortedArrayWithOptions: 0 usingComparator: ^NSComparisonResult(NSString* file1, NSString* file2) {
			NSString *newPath1 = [self.path stringByAppendingPathComponent: file1];
			NSString *newPath2 = [self.path stringByAppendingPathComponent: file2];
			BOOL isDirectory1, isDirectory2;
			[[NSFileManager defaultManager ] fileExistsAtPath: newPath1 isDirectory: &isDirectory1];
			[[NSFileManager defaultManager ] fileExistsAtPath: newPath2 isDirectory: &isDirectory2];
            if (isDirectory1 && !isDirectory2) {
				return NSOrderedDescending;
            }
			return  NSOrderedAscending;
		}];
    }
    return self;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame: CGRectZero];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: nil action: nil];
    self.navigationItem.backBarButtonItem = back;
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// MARK: - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 1;
}


- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    return self.files.count;
}


- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    static NSString *CellIdentifier = @"FileCell";
    FWFileCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (!cell) {
        [tableView registerNib: [UINib nibWithNibName: @"FWFileCellTableViewCell" bundle: nil] forCellReuseIdentifier: CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    }
    cell.delegate = self;
	NSString *newPath = [self.path stringByAppendingPathComponent: self.files[indexPath.row]];
	BOOL isDirectory;
	[[NSFileManager defaultManager ] fileExistsAtPath: newPath isDirectory: &isDirectory];
    cell.fileName.text = self.files[indexPath.row];
    if (isDirectory) {
		cell.fileImage.image = [UIImage imageNamed: @"Folder"];
    } else if ([[newPath pathExtension] isEqualToString: @"DAT"]) {
		cell.fileImage.image = [UIImage imageNamed: @"Picture"];
        cell.okButton.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([[newPath pathExtension] isEqualToString: @"SCNPLG"]) {
        cell.fileImage.image = [UIImage imageNamed: @"scnplg"];
        cell.okButton.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
		cell.fileImage.image = nil;
    }
#if 0
    if (fileExists && !isDirectory) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    else {
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
#endif
    return cell;
}


- (void) didSelectFile:(NSString*) filePath {
    if (self.delegate && [self.delegate respondsToSelector: @selector(getSelectedFWFile:)]) {
        [self.delegate getSelectedFWFile: filePath];
    }
    UINavigationController *mainNavVc = self.navigationController;
    for (UIViewController *vc in mainNavVc.viewControllers) {
        if ([vc isKindOfClass: [UpdateFirmwareVC class]]) {
            NSString *finalePath = [self.path stringByAppendingPathComponent: filePath];
            [((UpdateFirmwareVC*) vc) setSelectedFWFilePath: finalePath];
            [mainNavVc popToViewController: vc animated: YES];
        }
    }
}


- (void) tableView:(UITableView*) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*) indexPath {
	NSString *newPath = [self.path stringByAppendingPathComponent: self.files[indexPath.row]];
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent: newPath.lastPathComponent];
	NSError *error = nil;
	[[NSFileManager defaultManager] copyItemAtPath: newPath toPath: tmpPath error: &error];
    if (error) {
		NSLog(@"ERROR: %@", error);
    }
	UIActivityViewController *shareActivity = [[UIActivityViewController alloc] initWithActivityItems: @[[NSURL fileURLWithPath: tmpPath]] applicationActivities: nil];
	shareActivity.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
		[[NSFileManager defaultManager] removeItemAtPath: tmpPath error: nil];
	};
	UIViewController *vc = [[UIViewController alloc] init];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController: vc];
	nc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	[self.navigationController presentViewController: nc animated: YES completion:^{}];
}


- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
	NSString *newPath = [self.path stringByAppendingPathComponent: self.files[indexPath.row]];
	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager ] fileExistsAtPath: newPath isDirectory: &isDirectory];
	if (fileExists) {
		if (isDirectory) {
			FWFilesTableVC *vc = [[FWFilesTableVC alloc] initWithPath: newPath];
			[self.navigationController showViewController: vc sender: self];
		}
	}
}

@end
