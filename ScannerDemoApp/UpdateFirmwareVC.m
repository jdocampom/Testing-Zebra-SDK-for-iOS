//
//  UpdateFirmwareVC.m
//  ScannerSDKApp
//
//  Created by pqj647 on 6/19/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import "UpdateFirmwareVC.h"
#import "SbtSdkDefs.h"
#import "FWFilesTableVC.h"
#import "AppSettingsKeys.h"
#import "FWUpdateModel.h"
#import "PFWModelContentReader.h"
#import "PluginFileContentReader.h"
#import "RMDAttributes.h"
#import "DGActivityIndicatorView.h"
#import "ScannerAppEngine.h"
#import "ActiveScannerVC.h"
#import "ConnectionManager.h"
//#import "MFiScannersTableVC.h"
#import "UIColor+DarkModeExtension.h"
#import "NSString+Contain.h"

static BOOL isFWUpdatingDAT = NO;
static BOOL isFWUpdatingPLUGIN = NO;
static float fwUpdateAmount = 0.0f;
DGActivityIndicatorView *activityIndicatorView;


@interface UpdateFirmwareVC ()
{
    NSLayoutConstraint *scrollViewBottomInset;
    NSLayoutConstraint *webViewHeightConstraint;
    BOOL fwUpdateDidAbort;
    UIView *temporyView;
}

@end

@implementation UpdateFirmwareVC

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [[zt_ScannerAppEngine sharedAppEngine] addFWUpdateEventsDelegate:self];
    }
    
    return self;
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    fwUpdateAmount = progressBar.progress;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getAvailableFWFile];
    updateFWView.layer.borderColor = [UIColor blackColor].CGColor;
    updateFWView.layer.borderWidth = 2.0f;
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
    fwUpdateDidAbort = NO;
    [self darkModeCheck:self.view.traitCollection];
    
    ///Change in image, update button, firmware details view size only in iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _deviceImageViewHeightConstraint.constant = FW_PAGE_DEVICE_IMG_HEIGHT_IPAD;
        _updateButtonHeightConstraint.constant = FW_PAGE_BUTTON_HEIGHT_IPAD;
        _firmwareDetailsViewHeightConstraint.constant = FW_PAGE_DETAIL_VIEW_HEIGHT_IPAD;
    }
}

- (void)dealloc
{
    [[zt_ScannerAppEngine sharedAppEngine] removeFWUpdateEventsDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideFWUpdateView];
    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [helpWebView loadHTMLString:[self getHelpString] baseURL:nil];
    helpWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    [pluginMisMatchWebView loadHTMLString:[self getPluginMisMatchString] baseURL:nil];
}

+(UIColor*)getAppColor:(ZT_BG_COLOURS)clr
{
    switch (clr) {
        case BG_COLOUR_BLUE:
            return UIColorFromRGB(0x007CB0);
            break;
        case BG_COLOUR_YELLOW:
            return UIColorFromRGB(0xFFD200);
            break;
        case BG_COLOUR_FONT_COLOUR:
            return UIColorFromRGB(0x333D47);
            break;
        case BG_COLOUR_DARK_GRAY:
            return UIColorFromRGB(0x333D47);
            break;
        case BG_COLOUR_MEDIUM_GRAY:
            return UIColorFromRGB(0x7E868C);
            break;
        case BG_COLOUR_LIGHT_GRAY:
            return UIColorFromRGB(0xDBD8D6);
            break;
        case BG_COLOUR_TBL_LOW_GRAY:
            return UIColorFromRGB(0xDBD9D6);
            break;
        case BG_COLOUR_WHITE:
            return UIColorFromRGB(0xFFFFFF);
            break;
        case BG_COLOUR_INACTIVE_BACKGROUND:
            return UIColorFromRGB(0xF2F2F2);
            break;
        case BG_COLOUR_INACTIVE_TEXT:
            return UIColorFromRGB(0x7E868C);
            break;
        case BG_COLOUR_DEFAULT_BTN_CLR:
            return [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    superScrollView.contentSize=CGSizeMake(320,758);
    superScrollView.contentInset=UIEdgeInsetsMake(1.0,0.0,140.0,0.0);
    
    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->updateBtn.hidden =  YES;
    });
    [self removeActivityIndicatorForReebooting];
    activityView = [[zt_AlertView alloc]init];
    UIImage *image = [[UIImage imageNamed:HELP_ICON_IMAGE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickRightBtn:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    // Do any additional setup after loading the view.
    [self adjustHelpViewVisibility:YES];
    modelNumber = nil;
    [self adjustPluginVisibility:YES];
    [self adjustViewVisibilityForPluginMisMatchView:NO];
    [self setBorders];
    //[self setBackgroundColoursAndBtnColour];
   
    dispatch_async(dispatch_get_global_queue(   DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    //Background Thread
        [self getScannerInfo];
        dispatch_async(dispatch_get_main_queue(), ^(void){
        //Run UI Updates
            self->updateBtn.layer.cornerRadius = 3.0;
            self->updateBtn.layer.borderWidth = 2.0;
            self->headerLbl.textAlignment = NSTextAlignmentCenter;
            [self->activityView show:self.view];
        });
     });
    id<PFWModelContentReader> contentReader = [[PluginFileContentReader alloc] init];
   
    [contentReader readPluginFileData:^(FWUpdateModel *model) {
        CFTimeInterval startTime = CACurrentMediaTime();
        CFTimeInterval elapsedTime = 0;
        while (self->modelNumber == nil && elapsedTime < 20) {
            [NSThread sleepForTimeInterval:0.1];
            elapsedTime = CACurrentMediaTime() - startTime;
        }
        NSArray *supportedModelArray = model.supportedModels;
        BOOL isPluginMatcing = NO;
        for (NSString *scannerName in supportedModelArray) {
            if ([scannerName isEqualToString:self->modelNumber]) {
                isPluginMatcing = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->updateBtn.hidden =  NO;
                });
                if (isPluginMatcing == YES) {
                    break;
                }
            }
        }
        
        if (isPluginMatcing == NO) {
            //check for dat files now
            NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *dwnLoad = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
            //first look for plugins
            NSArray *datFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:dwnLoad];
            if (datFileArray != nil && datFileArray.count>0) {
                [self setCommandType:ZT_INFO_UPDATE_FROM_DAT];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->updateBtn.hidden =  NO;
                });
            } else {
                [self adjustPluginVisibility:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->activityView hide];
                });
                return;
            }
        } else {
            [self setCommandType:ZT_INFO_UPDATE_FROM_PLUGIN];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            CFTimeInterval startTime = CACurrentMediaTime();
            CFTimeInterval elapsedTime = 0;
            while (model.releaseNotes == nil && self->fwVersion == nil && elapsedTime < 10) {
                [NSThread sleepForTimeInterval:0.1];
                elapsedTime = CACurrentMediaTime() - startTime;
            }
            
            self->fwNameLbl.text = [NSString stringWithFormat:@"%@ %@", @"From:", self->fwVersion];
            [self->fwNameLbl.superview bringSubviewToFront:self->fwNameLbl];
            self->updateBtn.hidden =  NO;
            [self->releaseNotesTextView setText:model.releaseNotes];
            [self->headerLbl setText:model.plugFamily];
            [self->releasedDateLbl setText:[self processReleasedDateLblString:model.plugInRev withDate:model.releasedDate withFWName:model.firmwareNameArray]];
            self->scannerImage.image = [UIImage imageWithData:model.imgData];
            [self->releaseNotesTextView.superview bringSubviewToFront:self->releaseNotesTextView];
            [self->activityView hide];
            [self setBackgroundColoursAndBtnColour];
        });
    }];
    
    helpScrollView.contentSize = CGSizeMake(helpScrollView.frame.size.width, 300);
    helpScrollView.pagingEnabled = YES;
    
    superScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 300);
    
    pluginMisMatchWebView.opaque = NO;
    pluginMisMatchWebView.backgroundColor = [UIColor whiteColor];
    [self setElementTitles];
    helpWebView.delegate = self;
}

- (void)setElementTitles
{
    fwUpdateViewTitle.text = ZT_UPDATE_FW_VIEW_TITLE_UPDATING;
}

- (void)setBorders
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->helpScrollSuperView.layer.borderColor = [UIColor blackColor].CGColor;
        self->helpScrollSuperView.layer.borderWidth = 2.0f;
        self->updateFWView.layer.borderColor = [UIColor blackColor].CGColor;
        self->updateFWView.layer.borderWidth = 2.0f;
        self->pluginMisMatchView.layer.borderColor = [UIColor getDarkModeLabelTextColor:self.view.traitCollection].CGColor;
        self->pluginMisMatchView.layer.borderWidth = 2.0f;
    });
}

- (void)setBackgroundColoursAndBtnColour
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->releaseNotesTextView.backgroundColor = [UpdateFirmwareVC getAppColor:BG_COLOUR_LIGHT_GRAY];
        [self->updateBtn setTitleColor:[UpdateFirmwareVC getAppColor:BG_COLOUR_WHITE] forState:UIControlStateNormal];
        self->helpScrollSuperView.backgroundColor = [UpdateFirmwareVC getAppColor:BG_COLOUR_WHITE];
        
        if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
            [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                self->updateBtn.hidden =  NO;
                self->updateBtn.backgroundColor = [UIColor greenColor];
                [self->updateBtn setTitle:ZT_UPDATE_FW_BTN_TITLE_UPDATED forState:UIControlStateNormal];
                self->updateBtn.userInteractionEnabled = NO;
            });
            self->fwNameLbl.text = @"";
        } else {
            [self->updateBtn setTitle:ZT_UPDATE_FW_BTN_TITLE forState:UIControlStateNormal];
            self->updateBtn.backgroundColor = [UpdateFirmwareVC getAppColor:BG_COLOUR_BLUE];
            self->updateBtn.userInteractionEnabled = YES;
        }
    });
}

- (void)clickRightBtn:(id)btn
{
    [self adjustHelpViewVisibility:NO];
    [helpWebView.superview bringSubviewToFront:helpWebView];
    [helpWebView loadHTMLString:[self getHelpString] baseURL:nil];
}

- (void)adjustHelpViewVisibility:(BOOL)isVisible
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->helpView.hidden = isVisible;
        self->helpWebView.hidden = isVisible;
        self->helpViewCloseBtn.hidden = isVisible;
        self->helpScrollView.hidden = isVisible;
        self->helpScrollSuperView.hidden = isVisible;
        
        if (isVisible == NO) {
            [self->helpWebView.superview bringSubviewToFront:self->helpWebView];
            [self->helpWebView.superview bringSubviewToFront:self->helpWebView];
            [self->helpViewCloseBtn.superview bringSubviewToFront:self->helpViewCloseBtn];
            [self->helpScrollView.superview bringSubviewToFront:self->helpScrollView];
            [self->helpScrollSuperView.superview bringSubviewToFront:self->helpScrollSuperView];
        }
    });
}

- (void)adjustPluginVisibility:(BOOL)isVisible
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->pluginMisMatchView.hidden = isVisible;
        self->pluginMisMatchLbl.hidden = isVisible;
        self->pluginMisMatchWebView.hidden = isVisible;
        self->pluginMisMatchBtn.hidden = isVisible;
        
        if (isVisible == NO) {
            [self->pluginMisMatchView.superview bringSubviewToFront:self->pluginMisMatchView];
            [self->pluginMisMatchLbl.superview bringSubviewToFront:self->pluginMisMatchLbl];
            [self->pluginMisMatchWebView.superview bringSubviewToFront:self->pluginMisMatchWebView];
            [self->pluginMisMatchBtn.superview bringSubviewToFront:self->pluginMisMatchBtn];
            if([[zt_ScannerAppEngine sharedAppEngine]   firmwareDidUpdate]) {
                [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
            }
            [self->pluginMisMatchWebView loadHTMLString:[self getPluginMisMatchString] baseURL:nil];
            
            //make other views disappear
            [self adjustViewVisibilityForPluginMisMatchView:YES];
        }
    });
}

- (void)adjustViewVisibilityForPluginMisMatchView:(BOOL)visibilityStatus
{
    updateBtn.hidden = visibilityStatus;
    releaseNotesTextView.hidden = visibilityStatus;
    releaseNotesSuperView.hidden = visibilityStatus;
    fwNameLbl.hidden = visibilityStatus;
    releasedDateLbl.hidden = visibilityStatus;
    releaseNotesLbl.hidden = visibilityStatus;
}

- (void)getScannerInfo {
    NSString *in_xml = nil;
    /**
     Model, MFD and serial no does not chage. So we need get the values for those variables only in the first time
     ***/
    
    SbtScannerInfo *scannerInfo = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID];
    if([[scannerInfo getScannerName]containsSubString:SST_SCANNER_MODEL_SSI_RFD8500] ) {
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, 20012];
        [self getRFID8500Info:20012 withXML:in_xml withAssignedVal:fwVersion];
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, RMD_ATTR_MODEL_NUMBER];
        [self getRFID8500Info:RMD_ATTR_MODEL_NUMBER withXML:in_xml withAssignedVal:modelNumber];
    } else {
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d,%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, 20012, RMD_ATTR_MODEL_NUMBER];
        
        NSMutableString *result = [[NSMutableString alloc] init];
        [result setString:@""];
        
        SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
        
        if (SBT_RESULT_SUCCESS != res) {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                 message:ZT_SCANNER_CANNOT_RETRIEVE_ASSET_INFORMATION
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle ok action
                                            }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                           }
                           );
            return;
            
        }
        
        BOOL success = FALSE;
        
        do {
            NSString* res_str = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString* tmp = @"<attrib_list><attribute>";
            NSRange range = [res_str rangeOfString:tmp];
            NSRange range2;
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            res_str = [res_str substringFromIndex:(range.location + range.length)];
            
            tmp = @"</attribute></attrib_list>";
            range = [res_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range.length = [res_str length] - range.location;
            
            res_str = [res_str stringByReplacingCharactersInRange:range withString:@""];
            
            NSArray *attrs = [res_str componentsSeparatedByString:@"</attribute><attribute>"];
            
            if ([attrs count] == 0)
            {
                break;
            }
            
            NSString *attr_str;
            
            int attr_id;
            int attr_val;
            
            for (NSString *pstr in attrs)
            {
                attr_str = pstr;
                
                tmp = @"<id>";
                range = [attr_str rangeOfString:tmp];
                if ((range.location != 0) || (range.length != [tmp length]))
                {
                    break;
                }
                attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
                
                tmp = @"</id>";
                
                range = [attr_str rangeOfString:tmp];
                
                if ((range.location == NSNotFound) || (range.length != [tmp length]))
                {
                    break;
                }
                
                range2.length = [attr_str length] - range.location;
                range2.location = range.location;
                
                NSString *attr_id_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
                
                attr_id = [attr_id_str intValue];
                
                
                range2.location = 0;
                range2.length = range.location + range.length;
                
                attr_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
                
                tmp = @"<value>";
                range = [attr_str rangeOfString:tmp];
                if ((range.location == NSNotFound) || (range.length != [tmp length]))
                {
                    break;
                }
                attr_str = [attr_str substringFromIndex:(range.location + range.length)];
                
                tmp = @"</value>";
                
                range = [attr_str rangeOfString:tmp];
                
                if ((range.location == NSNotFound) || (range.length != [tmp length]))
                {
                    break;
                }
                
                range.length = [attr_str length] - range.location;
                
                attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
                
                attr_val = [attr_str intValue];
                
                if (RMD_ATTR_FRMWR_VERSION == attr_id)
                {
                    fwVersion = attr_str;
                }
                else if (RMD_ATTR_MODEL_NUMBER == attr_id)
                {
                    modelNumber = [attr_str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                }
            }
            
            success = TRUE;
            
        } while (0);
        
        if (FALSE == success)
        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                 message:ZT_SCANNER_ERROR_MESSAGE
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle ok action
                                            }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                           }
                           );
            return;
        }
    }
}

- (void)getRFID8500Info:(int)attrID withXML:(NSString*)in_xml withAssignedVal:(NSString*)value
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result setString:@""];
    
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
    
    if (SBT_RESULT_SUCCESS != res) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_RETRIEVE_ASSET_INFORMATION
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
                       }
                       );
        return;
        
    }
    
    BOOL success = FALSE;
    
    do {
        NSString* res_str = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* tmp = @"<attrib_list><attribute>";
        NSRange range = [res_str rangeOfString:tmp];
        NSRange range2;
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        res_str = [res_str substringFromIndex:(range.location + range.length)];
        
        tmp = @"</attribute></attrib_list>";
        range = [res_str rangeOfString:tmp];
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        range.length = [res_str length] - range.location;
        
        res_str = [res_str stringByReplacingCharactersInRange:range withString:@""];
        
        NSArray *attrs = [res_str componentsSeparatedByString:@"</attribute><attribute>"];
        
        if ([attrs count] == 0)
        {
            break;
        }
        
        NSString *attr_str;
        
        int attr_id;
        int attr_val;
        
        for (NSString *pstr in attrs)
        {
            attr_str = pstr;
            
            tmp = @"<id>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location != 0) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
            
            tmp = @"</id>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range2.length = [attr_str length] - range.location;
            range2.location = range.location;
            
            NSString *attr_id_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            attr_id = [attr_id_str intValue];
            
            
            range2.location = 0;
            range2.length = range.location + range.length;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            tmp = @"<value>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str substringFromIndex:(range.location + range.length)];
            
            tmp = @"</value>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range.length = [attr_str length] - range.location;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
            
            attr_val = [attr_str intValue];
            
            if (20012 == attr_id)
            {
                fwVersion = attr_str;
            }
            else if (RMD_ATTR_MODEL_NUMBER == attr_id)
            {
                modelNumber = attr_str;
            }
        }
        
        success = TRUE;
        
    } while (0);
    
    if (FALSE == success)
    {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_ERROR_MESSAGE
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
                       }
                       );
        return;
    }
}


- (NSString*)getHelpString
{
    NSString *intialString = @"<div style=\"";
    NSString *fontSize = @"font-size:14px;";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontSize = @"font-size:16px;";
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = @"font-size:14px;";
    }
    NSString *restString =  @"font-family: \"SourceSansPro-Regular\";padding: 8px 10px;\"> <meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>  <label style=\"display: block; margin-bottom: 10px; font-size:17px\"> <b>%@</b></label><label style=\"display: block; margin-bottom: 1px;\"></label><ul><li>%@</li><ol><li>%@<br><a href=%@>%@</a>   </li><li>%@</li><li>%@</li></ol></li><li>%@</li></ul></div>";
    NSString *rsltString = [NSString stringWithFormat:@"%@%@%@", intialString, fontSize, restString];
    return [NSString stringWithFormat:rsltString,FW_PAGE_CONTENT_ONE, FW_PAGE_CONTENT_ONE_SECOND, FW_PAGE_CONTECT_THREE, FW_PAGE_CONTECT_THREE_URL_REAL, FW_PAGE_CONTECT_THREE_URL,FW_PAGE_CONTECT_FOUR, FW_PAGE_CONTECT_FIVE, FW_PAGE_CONTECT_SIX];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'"];
}

- (BOOL)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type
{
    if ([[request URL] isEqual:[request mainDocumentURL]])
    {
        [[UIApplication sharedApplication] openURL:[request URL] options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(UPDATE_FIRMWARE_OPEN_URL_SUCCESS);
            }
        }];
        return YES;
    }
    else
    {
        return YES;
    }
}

- (NSString*)getPluginMisMatchString
{
    NSString *intialString = @"<div style=\"";
    NSString *fontSize = @"font-size:14px;";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontSize = @"font-size:16px;";
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = @"font-size:14px;";
    }
    NSString *restString =  @"font-family: \"SourceSansPro-Regular\";padding: 8px 10px;\"> <meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'><ol><li>%@</li><li>%@</li></li></ol></div>";
    NSString *rsltString = [NSString stringWithFormat:@"%@%@%@", intialString, fontSize, restString];
    return [NSString stringWithFormat:rsltString,FW_PAGE_PLUGIN_MISMATCH_CONTENT_ONE, FW_PAGE_PLUGIN_MISMATCH_CONTENT_TWO];
}

-(NSString*)processReleasedDateLblString:(NSString*)revision withDate:(NSString*)date withFWName:(NSMutableArray*)fwNameArray
{
    if (date == nil && revision == nil && date == nil) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:date];
    
    if (dateFromString == nil) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        dateFromString = [dateFormatter dateFromString:date];
    }
    
    [dateFormatter setDateFormat:@"yyyy.dd.MM"];
    NSString *formattedDate = [dateFormatter stringFromDate:dateFromString];
    if (revision == nil) {
        revision = @"";
    }
    if (formattedDate == nil) {
        formattedDate = @"";
    }
    NSString *fwName = [self getCorrectFWName:fwNameArray];
    if (fwName == nil) {
        fwName = @"";
    }
    
    if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
        return [NSString stringWithFormat:@"Current: Release %@ - %@ (%@)", revision,formattedDate, fwVersion];
    } else {
        return [NSString stringWithFormat:@"To: Release %@ - %@ (%@)", revision,formattedDate, fwName];
    }
}

- (NSString*)getCorrectFWName:(NSMutableArray*)fwNameArray
{
    NSString *matchingFWName = nil;
    CFTimeInterval startTime = CACurrentMediaTime();
    CFTimeInterval elapsedTime = 0;
    while (fwVersion == nil && elapsedTime < 20) {
        [NSThread sleepForTimeInterval:0.1];
        elapsedTime = CACurrentMediaTime() - startTime;
    }
    
    for (NSString *fwNameString in fwNameArray) {
        if ([fwNameString isEqualToString:fwVersion]) {
            matchingFWName = fwNameString;
            break;
        }
    }
    
    if (matchingFWName == nil) {
        for (NSString *fwNameString in fwNameArray) {
            if (fwNameString.length > 3 && [[fwNameString substringToIndex:3] isEqualToString:[fwVersion substringToIndex:3]]) {
                matchingFWName = fwNameString;
                break;
            }
        }
    }
    
    return matchingFWName;
}

- (void)getFWFileModel:(NSString*)pluginName
{
  
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dwnLoadDir = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    NSString *pluginDir = [dwnLoadDir stringByAppendingPathComponent:pluginName];
    
    NSArray *releaseNotes = [self findFiles:ZT_RELEASE_NOTES_FILE_EXTENTION fromPath:pluginDir];
    //read release notes if availale
    NSError *error;
    if (releaseNotes.count > 0) {
       
        if(error) {
        }
        //model.releaseNotes = strFileContent;
        
        //contentReader setMetaDataFilePath:(NSString *)
    }
    
}

- (NSString*)getAvailableFWFile
{
    selectedFWFilePath = nil;
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dwnLoad = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    //first look for plugins
    NSArray *pluginArray = [self findFiles:ZT_PLUGIN_FILE_EXTENTION fromPath:dwnLoad];
    if (pluginArray.count == 0) {
        NSArray *fwFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:dwnLoad];
        if (fwFileArray.count == 0) {
        } else {
            commandTYpe = ZT_INFO_UPDATE_FROM_DAT;
            selectedFWFilePath = (NSString*)[dwnLoad stringByAppendingPathComponent:(NSString*)fwFileArray[0]];
        }
    } else {
        commandTYpe = ZT_INFO_UPDATE_FROM_PLUGIN;
        selectedFWFilePath = (NSString*)[dwnLoad stringByAppendingPathComponent:(NSString*)pluginArray[0]];
    }
    
    return selectedFWFilePath;
}

- (NSString*)getSelectedFWFilePath
{
    return selectedFWFilePath;
}

- (void)setSelectedFWFilePath:(NSString*)path
{
    selectedFileTxt.text = [path lastPathComponent];
    if ([[path pathExtension] isEqualToString:@"DAT"]) {
        commandTYpe = ZT_INFO_UPDATE_FROM_DAT;
    } else if ([[path pathExtension] isEqualToString:@"SCNPLG"]){
        commandTYpe = ZT_INFO_UPDATE_FROM_PLUGIN;
    }
    
    NSRange equalRange = [path rangeOfString:@"Documents" options:NSBackwardsSearch];
    if (equalRange.location != NSNotFound) {
        NSString *relativePath = [path substringFromIndex:equalRange.location+equalRange.length];
        [[NSUserDefaults standardUserDefaults] setObject:relativePath
                                                  forKey:ZT_SETTING_SAVE_FW_PATH];
    }
    selectedFWFilePath = path;
}

- (NSArray *)findFiles:(NSString *)extension fromPath:(NSString*)path
{
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *item;
    NSArray *contents = [manager contentsOfDirectoryAtPath:path error:nil];
    for (item in contents)
    {
        if ([[item pathExtension]isEqualToString:extension])
        {
            [matches addObject:item];
        }
    }
    
    return matches;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScannerID:(int)currentScannerID
{
    m_ScannerID = currentScannerID;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)closeHelpView:(id)sender {
    [self adjustHelpViewVisibility:YES];
}

- (IBAction)selectDatFile:(id)sender
{
    [self invokeFileSelector];
}

- (void)invokeFileSelector
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    FWFilesTableVC *startingVC = [[FWFilesTableVC alloc] initWithPath:documentsDirectory];
    
    [self.navigationController pushViewController:startingVC animated:YES];
}

- (void)showFWUPdateView
{
    [self adjustFWUpdateViewVisibility:NO];
}

- (void)hideFWUpdateView
{
    [self adjustFWUpdateViewVisibility:YES];
}

- (void)adjustFWUpdateViewVisibility:(BOOL)hiddenStatus
{
    updateFWView.hidden = hiddenStatus;
    if (hiddenStatus == NO) {
        [updateFWView.superview bringSubviewToFront:updateFWView];
    } else {
        [updateFWView.superview sendSubviewToBack:updateFWView];
    }
    progressBar.hidden = hiddenStatus;
}

- (void)setUpTemporyView
{
    temporyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIView *superViewToTmpView = nil;
    superViewToTmpView = superScrollView;
    [superViewToTmpView addSubview:temporyView];
    temporyView.backgroundColor = [[UpdateFirmwareVC getAppColor:BG_COLOUR_INACTIVE_BACKGROUND]  colorWithAlphaComponent:0.5];
    [superViewToTmpView bringSubviewToFront:temporyView];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    [abortBtn.superview bringSubviewToFront:abortBtn];
    [superViewToTmpView bringSubviewToFront:updateFWView];
    temporyView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c4];
}

- (void)removeTemporyView
{
    if (temporyView != nil) {
        [temporyView removeFromSuperview];
        temporyView = nil;
    }
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (IBAction)updateFW:(id)sender
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self performSelectorOnMainThread:@selector(showFWUPdateView) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(setUpTemporyView) withObject:nil waitUntilDone:YES];

    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDON];
    
    fwUpdateDidAbort = NO;
    progressBar.progress = 0.0;
    
    [sender setUserInteractionEnabled:NO];
    firmwareUpdateDidStop = NO;
    NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-string>%@</arg-string></cmdArgs></inArgs>", m_ScannerID, selectedFWFilePath];
    int command = 0;
    if (commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
        command = SBT_UPDATE_FIRMWARE;
    } else {
        command = SBT_UPDATE_FIRMWARE_FROM_PLUGIN;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self disableScanner];

        SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:command aInXML:in_xml aOutXML:nil forScanner:self->m_ScannerID];
        [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
        
        if (self->fwUpdateDidAbort == YES) {
            [self enableScanner];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->alertController dismissViewControllerAnimated:false completion:nil];
            });
            return;
        }
        else if (res != SBT_RESULT_SUCCESS)
        {
          [self enableScanner];
            dispatch_async(dispatch_get_main_queue(),^{
                [self->alertController dismissViewControllerAnimated:false completion:nil];
                self->firmwareUpdateDidStop = YES;
                self->progressBar.progress = START_PROGRESS_RESET_VALUE;
                [self->progressBar setNeedsDisplay];
                fwUpdateAmount = FIRMWARE_UPDATE_RESET_AMOUNT;
                
                UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                 message:FIRMWARE_UPDATE_STOPPED
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle ok action
                                            }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                [self hideFWUpdateView];
                [self resetProgressBar];
                [self removeTemporyView];
                if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
                    [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
                }
            });
        } else {
            ///Disable all virtual tether options on firmware update success
            [[ConnectionManager sharedConnectionManager] resetAllVirtualTetherHostAlarmSetting];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                                [self->alertController dismissViewControllerAnimated:false completion:nil];
                self->percentageLbl.text = @"";
                               NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", self->m_ScannerID];
                               [self->activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performStartNewFirmware:) withObject:in_xml withString:nil];
                               [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:YES];
                               [[zt_ScannerAppEngine sharedAppEngine] previousScannerpreviousScanner:self->m_ScannerID];
                               [self resetProgressBar];
                           }
                           );
        }
       
    });
     [updateBtn setUserInteractionEnabled:YES];
}

- (void)resetProgressBar
{
    firmwareUpdateDidStop = YES;
    progressBar.progress = 0.0;
    [progressBar setNeedsDisplay];
    fwUpdateAmount = 0.0f;
}

- (void)performStartNewFirmware:(NSString*)param
{
  
    [self performSelectorOnMainThread:@selector(addActivityIndicatorForReebooting) withObject:nil waitUntilDone:YES];
    
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_START_NEW_FIRMWARE aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
     
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_NEW_FIRMWARE_ACTION
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [self enableScanner];
                       }
                       );
    } else {
       
        [self performSelectorOnMainThread:@selector(removeTemporyView) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(enableScanner) withObject:nil waitUntilDone:YES];

    }
}

/// Cancel the firmware update action when the update in progress.
/// @param sender Sending the object to utilize the object details like id and the name etc.
- (IBAction)cancelFirmwareUpdateAction:(id)sender
{
 
        alertController = [UIAlertController alertControllerWithTitle:ZT_SCANNER_APP_NAME message:FIRMWARE_UPDATE_CANCEL_CONFIRMATION preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *actionYes = [UIAlertAction actionWithTitle:YES_BUTTON style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self abortFWUpdate];
        }];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NO_BUTTON
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
        [alertController addAction:actionYes];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
}


/// To abort the firmware update.
- (void)abortFWUpdate
{
    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self hideFWUpdateView];
    [self removeTemporyView];
    [updateBtn setUserInteractionEnabled:YES];
    firmwareUpdateDidStop = YES;
    if (commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
        isFWUpdatingDAT = NO;
    }
    if (commandTYpe == ZT_INFO_UPDATE_FROM_PLUGIN) {
        isFWUpdatingPLUGIN = NO;
    }
    
    NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
    
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_ABORT_UPDATE_FIRMWARE aInXML:in_xml aOutXML:nil forScanner:m_ScannerID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (res != SBT_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                 message:ZT_SCANNER_FIRMWARE_UPDATE_ABBORT_FAILED
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:OK
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle ok action
                                            }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
               [self enableScanner];
                           }
                           );
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->fwUpdateDidAbort = YES;
                self->progressBar.progress = 0.0;
                [self->progressBar setNeedsDisplay];
                fwUpdateAmount = 0.0f;
                self->percentageLbl.text = [NSString stringWithFormat:UPDATE_FIRMWARE_PERCENTAGE_LABEL_STRING_FORMAT,0];
                [self enableScanner];
            });
        }
        [NSThread sleepForTimeInterval:5.0];
    });
}
- (IBAction)pluginMisMatchOkClicked:(id)sender {
    [self adjustPluginVisibility:YES];
    if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
        [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)setCommandType:(ZT_INFO_UPDATE_FW)type;
{
    commandTYpe = type;
}


// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)updateUI:(FirmwareUpdateEvent*)event
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->firmwareUpdateDidStop == NO) {
            self->progressBar.progress = (float)event.currentRecord/event.maxRecords;
            if ((int)(float)event.currentRecord/event.maxRecords*100 < 10) {
                self->percentageLbl.text = [NSString stringWithFormat:UPDATE_FIRMWARE_PERCENTAGE_LABEL_STRING_FORMAT,(int)((float)event.currentRecord/event.maxRecords*100)];
            } else {
                self->percentageLbl.text = [NSString stringWithFormat:UPDATE_FIRMWARE_PERCENTAGE_LABEL_STRING_FORMAT,(int)((float)event.currentRecord/event.maxRecords*100+1)];
            }
            
            if (self->progressBar.progress == 0 || self->progressBar.progress == 100) {
                if (self->commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
                    isFWUpdatingDAT = NO;
                }
                if (self->commandTYpe == ZT_INFO_UPDATE_FROM_PLUGIN) {
                    isFWUpdatingPLUGIN = NO;
                }
                
                fwUpdateAmount = 0;
            } else {
                if (self->commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
                    isFWUpdatingDAT = YES;
                }
                if (self->commandTYpe == ZT_INFO_UPDATE_FROM_PLUGIN) {
                    isFWUpdatingPLUGIN = YES;
                }
            }
        }
    });
}

- (void)addActivityIndicatorForReebooting
{
    fwUpdateViewTitle.text = ZT_UPDATE_FW_VIEW_TITLE_REBOOTING;
    activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeThreeDots tintColor:[UIColor grayColor]];
    
    activityIndicatorView.frame = CGRectMake(0,progressBar.frame.origin.y-20, progressBar.frame.size.width, 100);
    [updateFWView addSubview:activityIndicatorView];
    
    [activityIndicatorView.superview bringSubviewToFront:activityIndicatorView];
    [activityIndicatorView startAnimating];

}

- (void)removeActivityIndicatorForReebooting
{
    if (activityIndicatorView != nil) {
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
        activityIndicatorView = nil;
    }
}

///Enable the scanner
- (void)enableScanner
{
    NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
     [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_SCAN_ENABLE aInXML:in_xml aOutXML:nil forScanner:m_ScannerID];
              
}

///Disable the scanner
-(void)disableScanner
{
    NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
    [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_SCAN_DISABLE aInXML:in_xml aOutXML:nil forScanner:m_ScannerID];
}

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    pluginMisMatchView.layer.borderColor = [UIColor getDarkModeLabelTextColor:traitCollection].CGColor;
    
   
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
