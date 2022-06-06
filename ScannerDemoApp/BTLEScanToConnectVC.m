/******************************************************************************
*
*       Copyright Motorola Solutions, Inc. 2014
*
*       The copyright notice above does not evidence any
*       actual or intended publication of such source code.
*       The code contains Motorola Confidential Proprietary Information.
*
*
*  Description:  BTLEScanToConnectVC.m
*
*  Notes:
*
******************************************************************************/

#import "BTLEScanToConnectVC.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>
#import "config.h"
//#import "AppSettingsVC.h"
#import "ScannerAppEngine.h"
#import "ActiveScannerVC.h"
#import "ConnectionManager.h"
//#import "AboutAppVC.h"
#import "VirtualTetherTableViewController.h"
#import "AppSettingsKeys.h"

@interface BTLEScanToConnectVC ()

@end

@implementation BTLEScanToConnectVC

- (id) initWithCoder:(NSCoder*) aDecoder {
	self = [super initWithCoder: aDecoder];
	[[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate: self];
	return self;
}


- (void) backPressed:(id) btn {
	[self.navigationController popViewControllerAnimated: YES];
}


- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


- (void) viewDidLoad {
	[super viewDidLoad];
	[[self navigationItem] setTitle: SCAN_TO_CONNECT_APP_NAME_TITLE];
//	UIBarButtonItem *aboutusButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: ABOUTUS_IMAGE] style: UIBarButtonItemStylePlain target: self action: @selector(aboutAction:)];
//	[[self navigationItem] setRightBarButtonItem: aboutusButton];
}


/// Check set factory default enable or disable
- (void) getFactoryDefaultStatus {
	NSString *statusMessage = SCAN_TO_CONNECT_EMPTY_STRING_VALUE;
	NSNumber *savedSettingDefaultValue = [[NSUserDefaults standardUserDefaults] objectForKey: SETDEFAULTS_SETTINGS_KEY];
	if (savedSettingDefaultValue != nil) {
		if ([savedSettingDefaultValue boolValue] == NO) {
			self.setDefaultsStatus = SETDEFAULT_NO;
			statusMessage = SCAN_TO_CONNECT_KEEP_CURRENT_SETTINGS;
		} else {
			self.setDefaultsStatus = SETDEFAULT_YES;
			statusMessage = SCAN_TO_CONNECT_SET_FACTORY_DEFAULT;
		}
	} else {
		self.setDefaultsStatus = SETDEFAULT_NO;
		statusMessage = SCAN_TO_CONNECT_KEEP_CURRENT_SETTINGS;
	}
	defaultStatusLabel.attributedText = [[NSAttributedString alloc] initWithString: statusMessage attributes: @{
        NSFontAttributeName: [UIFont italicSystemFontOfSize: [UIFont systemFontSize]]
	}];
}

/// Call the about app view controller.
/// @param sender Send the button id as a sender.
//- (IBAction) aboutAction:(id) sender {
//	zt_AboutAppVC *about_vc = nil;
//	about_vc = (zt_AboutAppVC*)[[UIStoryboard storyboardWithName: SCANNER_STORY_BOARD bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: ID_APP_ABOUT_VC];
//	if (about_vc != nil) {
//		[self.navigationController pushViewController: about_vc animated: YES];
//	}
//}


/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animate If YES, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL) animate {
	[super viewWillAppear: animate];
	[self drawConnectionBarcode];
	[self getFactoryDefaultStatus];
}


- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear: animated];
}


/// Called to notify the view controller that its view has just laid out its subviews.
- (void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self drawConnectionBarcode];
}


- (void) drawConnectionBarcode {
	UIImage *generatedBarcodeImage = [[zt_ScannerAppEngine sharedAppEngine] sbtSTCPairingBarcode: BARCODE_TYPE_STC withComProtocol: STC_SSI_BLE withSetDefaultStatus: self.setDefaultsStatus withImageFrame: m_imgBarcode.frame];
	[m_imgBarcode setImage: generatedBarcodeImage];
}

#pragma mark - Flipside View

- (NSMutableAttributedString*) plainStringToAttributedUnits:(NSString*) string {
	NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString: string];
	UIFont *font = [UIFont systemFontOfSize: 10.0f];
	UIFont *smallFont = [UIFont systemFontOfSize: 9.0f];
	[attString beginEditing];
	[attString addAttribute: NSFontAttributeName value: (font) range: NSMakeRange(0, 1)];
	[attString addAttribute: NSFontAttributeName value: (smallFont) range: NSMakeRange(1, 2)];
	[attString addAttribute: (NSString*)kCTSuperscriptAttributeName value: @"1" range: NSMakeRange(1, 2)];
	[attString addAttribute: (NSString*)kCTForegroundColorAttributeName value: [UIColor blackColor] range: NSMakeRange(0, 1)];
	[attString endEditing];
	return attString;
}


/// Show active scanner for barcode event
/// @param scannerID Scanner's id for bar code
/// @param barcodeView  Check if barcode view
/// @param animated Check if animation is enabled
- (void) showActiveScannerVC:(NSNumber*) scannerID aBarcodeView:(BOOL) barcodeView aAnimated:(BOOL) animated {
	int scanner_id = [scannerID intValue];
	m_CurrentScannerId = scanner_id;
	m_CurrentScannerActive = YES;
	///Check if it's firmware update event
	if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate] && [[zt_ScannerAppEngine sharedAppEngine] previousScannerId] == scanner_id) {
		zt_ActiveScannerVC *active_vc = [[UIStoryboard storyboardWithName: SCANNER_STORY_BOARD bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: ID_ACTIVE_SCANNER_VC];
		if (active_vc != nil) {
			[active_vc setScannerID: scanner_id];
			[self.navigationController pushViewController: active_vc animated: NO];
			[active_vc showFirmwareUpdate:scanner_id];
		}
	} else {
		zt_ActiveScannerVC *activeScannerVC = nil;
		activeScannerVC = (zt_ActiveScannerVC*)[[UIStoryboard storyboardWithName: SCANNER_STORY_BOARD bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: ID_ACTIVE_SCANNER_VC];
		if (activeScannerVC != nil) {
			[activeScannerVC setScannerID: scanner_id];
			[self.navigationController pushViewController: activeScannerVC animated: animated];
			if (YES == barcodeView) {
				[activeScannerVC showBarcodeList];
			}
		}
	}
}


/// Show virtual tether ui on alarm event
- (void) showVirtualTetherUI {
	VirtualTetherTableViewController *virtual_tether_vc = (VirtualTetherTableViewController*)[[UIStoryboard storyboardWithName: SCANNER_STORY_BOARD bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: ID_SCANNER_VIRTUAL_THETHER_VC];
	if (virtual_tether_vc != nil) {
		[self.navigationController pushViewController: virtual_tether_vc animated: NO];
	}
}

// MARK: - IScannerAppEngineDevConnectionsDelegate Protocol implementation

- (BOOL) scannerHasAppeared:(int) scannerID {
	/* does not matter */
	return NO; /* we have not processed the notification */
}


- (BOOL) scannerHasDisappeared:(int) scannerID {
	/* does not matter */
	return NO; /* we have not processed the notification */
}


- (BOOL) scannerHasConnected:(int) scannerID {
	SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID: scannerID];
	if ([scanner_info getConnectionType] == SBT_CONNTYPE_MFI) {
		return NO;
	}
	///Scanner auto reconnect to check virutal tether alarm
	if ([[ConnectionManager sharedConnectionManager] getConnectedScannerId] == scannerID) {
		[[ConnectionManager sharedConnectionManager] scannerReconnectedOnVirtualTetherAlarm];
	}
	[self showActiveScannerVC: [NSNumber numberWithInt: scannerID] aBarcodeView: NO aAnimated: YES];
	return YES; /* we have processed the notification */
}


- (BOOL) scannerHasDisconnected:(int) scannerID {
	/* does not matter */
	return NO; /* we have not processed the notification */
}

@end
