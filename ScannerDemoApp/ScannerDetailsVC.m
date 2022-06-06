//
//  ScannerDetailsVC.m
//  ScannerSDKApp
//
//  Created by pqj647 on 11/25/15.
//  Copyright © 2015 Alexei Igumnov. All rights reserved.
//

#import "ScannerDetailsVC.h"
#import "config.h"
#import "ScannerDemoAppDelegate.h"

@interface ScannerDetailsVC ()
@end

@implementation ScannerDetailsVC

- (void) viewDidLoad {
	[super viewDidLoad];
	activityView = [[zt_AlertView alloc] init];
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear: animated];
	/// Hide the standard back button
	[self.navigationItem setHidesBackButton: YES];
	/// Add the custom back button
	backBarButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStylePlain target: self action: @selector(confirmCancel)];
	self.navigationItem.leftBarButtonItem = backBarButton;
}


- (void) viewWillDisappear:(BOOL) animated {
	[self operationComplete];
}


- (void) operationComplete {
    /// Restore the standard back button
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.navigationItem.hidesBackButton) {
			self.navigationItem.leftBarButtonItem = nil;
			[self.navigationItem setHidesBackButton: NO];
		}
	});
}


- (void) confirmCancel {
	zt_ScannerDemoAppDelegate *appDelegate = (zt_ScannerDemoAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (alert) {
		if (appDelegate.window.rootViewController.presentedViewController != nil) {
			[alert dismissViewControllerAnimated: FALSE completion: nil];
		}
	}
	if (didStartDataRetrieving) {
		alert = [UIAlertController alertControllerWithTitle: ZT_SCANNER_APP_NAME message: ZT_SCANNER_SURE_WANT_GO_BACK preferredStyle: UIAlertControllerStyleAlert];
		UIAlertAction* cancelButton = [UIAlertAction actionWithTitle: ACTIVE_SCANNER_DISCONNECT_ALERT_CANCEL style: UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
            /// Handle cancel action
        }];
		UIAlertAction* continueButton = [UIAlertAction actionWithTitle: ACTIVE_SCANNER_DISCONNECT_ALERT_CONTINUE style: UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {
            /// Handle continue action
            self->didStartDataRetrieving = NO;
            [self.navigationController popViewControllerAnimated: YES];
        }];
		[alert addAction: cancelButton];
		[alert addAction: continueButton];
		[self presentViewController: alert animated: YES completion: nil];
	} else {
		didStartDataRetrieving = NO;
		[self.navigationController popViewControllerAnimated: YES];
	}
}


// MARK: - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
	return 0;
}

- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
	return 0;
}

@end
