/******************************************************************************
 *
 *       Copyright Motorola Solutions, Inc. 2014
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Motorola Confidential Proprietary Information.
 *
 *
 *  Description:  BTLEScanToConnectVC.h
 *
 *  Notes:
 *
 ******************************************************************************/
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "UpdateFirmwareVC.h"
#import "MainViewTabBarController.h"

@interface BTLEScanToConnectVC : UIViewController <IScannerAppEngineDevConnectionsDelegate,BarcodeEventTriggerDelegate>
{
    IBOutlet UIImageView *m_imgBarcode;
    IBOutlet UILabel *defaultStatusLabel;
    CGFloat m_initialImageWidth;
    
    UITapGestureRecognizer *m_TapGestureRecognizer;
    NSLayoutConstraint* m_cstImageWidth;
    NSLayoutConstraint* m_cstImageCenterY;
    NSLayoutConstraint* m_cstInfoNoticeTop;
    NSLayoutConstraint* m_cstUpInfoNoticeHeight;
    NSLayoutConstraint* m_cstDownInfoNoticeHeight;
    UIPinchGestureRecognizer* m_PinchGectureRecognizer;
    
    int m_CurrentScannerId;
    BOOL m_CurrentScannerActive;
}

@property BARCODE_TYPE barcodeType;
@property STC_COM_PROTOCOL comProtocol;
@property SETDEFAULT_STATUS setDefaultsStatus;

@end
