//
//  FirstTimeSetupVC.m
//  ScannerSDKApp
//
//  Created by PQJ647 on 7/29/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import "FirstTimeSetupVC.h"
#import "config.h"
#import "AppSettingsKeys.h"

@interface FirstTimeSetupVC ()

@end

@implementation FirstTimeSetupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //messageWebView messageTextView.text = FIRST_TIME_PAGE_NOTICE_UP;
    NSString *htmlStringHeading = [NSString stringWithFormat:@"<font face = 'GothamRounded size = '15''> %@<br><ol><li>%@<br>%@</li><li style=\"line-height:50px\">%@<br><l/i><li style=\"line-height:40px\">%@<br></li><br></ul>",FIRST_TIME_PAGE_NOTICE_UP_FIRST_MSG_ONE, FIRST_TIME_PAGE_NOTICE_UP_FIRST_MSG_THREE, FIRST_TIME_PAGE_NOTICE_UP_FIRST_MSG_FOUR, FIRST_TIME_PAGE_NOTICE_UP_FIRST_MSG_FIVE, FIRST_TIME_PAGE_NOTICE_UP_FIRST_MSG_SIX];
    [messageWebView loadHTMLString:htmlStringHeading baseURL:nil];
    messageWebView.delegate = self;
    [lblBTAddress setFont:[UIFont systemFontOfSize:15]];
    lblBTAddress.text = MOT_INFO_SETTINGS_BT_ADDRESS;
    blAddressTextBox.delegate = self;
    
    messageWebView.opaque = NO;
    messageWebView.backgroundColor = [UIColor clearColor];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: none;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];
    
}

- (void)viewDidLayoutSubviews
{
    //[messageWebView setFont:[UIFont systemFontOfSize:14]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:BLADDRESS_SETTINGS_KEY];
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)clickContinue:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:blAddressTextBox.text forKey:BLADDRESS_SETTINGS_KEY];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
