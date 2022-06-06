//
//  FirstTimeSetupVC.h
//  ScannerSDKApp
//
//  Created by PQJ647 on 7/29/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCSBasicVC.h"

@interface FirstTimeSetupVC : DCSBasicVC<UITextFieldDelegate, UIWebViewDelegate>
{
    IBOutlet UILabel *lblBTAddress;
    IBOutlet UITextField *blAddressTextBox;
    IBOutlet UIButton *barcodeBTN;
    IBOutlet UIWebView *messageWebView;
}

- (IBAction)clickContinue:(id)sender;

@end

