/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  SymbologiesVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SymbologiesVC.h"
#import "SwitchTableViewCell.h"
#import "config.h"
#import "ScannerAppEngine.h"
#import "Symbology.h"
#import "RMDAttributes.h"
#import "SSCheckBoxView.h"
#import "NSString+Contain.h"
#import "ScannerDemoAppDelegate.h"

@interface zt_SymbologiesVC ()
{
    dispatch_queue_t queue;
    dispatch_group_t group;
    BOOL shouldSavePermanantly;
}

@end

@implementation zt_SymbologiesVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_SymbologiesRetrieved = FALSE;
        
        m_ScannerID = -1;
        
        m_Symbologies = [[NSMutableArray alloc] init];
        
        zt_Symbology *tmp;
        
        tmp = [[zt_Symbology alloc] init:@"UPC-A" aRMDAttr:RMD_ATTR_SYM_UPC_A];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"UPC-E" aRMDAttr:RMD_ATTR_SYM_UPC_E];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"UPC-E1" aRMDAttr:RMD_ATTR_SYM_UPC_E_1];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"EAN-8/JAN8" aRMDAttr:RMD_ATTR_SYM_EAN_8_JAN_8];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"EAN-13/JAN13" aRMDAttr:RMD_ATTR_SYM_EAN_13_JAN_13];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Bookland EAN" aRMDAttr:RMD_ATTR_SYM_BOOKLAND_EAN];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Code 128" aRMDAttr:RMD_ATTR_SYM_CODE_128];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"GS1-128" aRMDAttr:RMD_ATTR_SYM_UCC_EAN_128];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Code 39" aRMDAttr:RMD_ATTR_SYM_CODE_39];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Code 93" aRMDAttr:RMD_ATTR_SYM_CODE_93];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Code 11" aRMDAttr:RMD_ATTR_SYM_CODE_11];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Interleaved 2 of 5" aRMDAttr:RMD_ATTR_SYM_INTERLEAVED_2_OF_5];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Discrete 2 of 5" aRMDAttr:RMD_ATTR_SYM_DISCRETE_2_OF_5];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Chinese 2 of 5" aRMDAttr:RMD_ATTR_SYM_CHINESE_2_OF_5];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Codabar" aRMDAttr:RMD_ATTR_SYM_CODABAR];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"MSI" aRMDAttr:RMD_ATTR_SYM_MSI];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Data Matrix" aRMDAttr:RMD_ATTR_SYM_DATAMATRIXQR];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"PDF" aRMDAttr:RMD_ATTR_SYM_PDF];
        [m_Symbologies addObject:tmp];
        
        //add new symbologies
        tmp = [[zt_Symbology alloc] init:@"ISBT 128" aRMDAttr:RMD_ATTR_SYM_ISBT_128];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"UCCCouponExtendedCode" aRMDAttr:RMD_ATTR_UCC_COUPEN_EXTENDED_CODE];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"US Postnet" aRMDAttr:RMD_ATTR_SYM_US_Postnet];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"US Planet" aRMDAttr:RMD_ATTR_SYM_US_Planet];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"UKPost" aRMDAttr:RMD_ATTR_SYM_UK_POST];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"USPostal Check Digit" aRMDAttr:RMD_ATTR_SYM_US_POSTAL_CHECK_DIGIT];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"UKPostal Check Digit" aRMDAttr:RMD_ATTR_SYM_UK_POSTAL_CHECK_DIGIT];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"JapanPost" aRMDAttr:RMD_ATTR_SYM_JAPAN_POST];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"AusPost" aRMDAttr:RMD_ATTR_SYM_AUS_POST];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"GS1DataBar14" aRMDAttr:RMD_ATTR_SYM_GS1_DATABAR_14];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"GS1DataBarLimited" aRMDAttr:RMD_ATTR_SYM_GS1_DATABAR_LIMITED];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"GS1DataBarExpanded" aRMDAttr:RMD_ATTR_SYM_GS1_DATABAR_EXPANDED];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"MicroPDF" aRMDAttr:RMD_ATTR_SYM_MICRO_PDF];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"MaxiCode" aRMDAttr:RMD_ATTR_SYM_MAXI_CODE];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"ISSN EAN" aRMDAttr:RMD_ATTR_ISSN_EAN];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Matrix 2 of 5" aRMDAttr:RMD_ATTR_MATRIX_2_OF_5];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Korean 3 of 5" aRMDAttr:RMD_ATTR_KOREAN_3_OF_5];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"QR Code" aRMDAttr:RMD_ATTR_QR_CODE];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Micro QR Code" aRMDAttr:RMD_ATTR_MICRO_QR];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Aztec" aRMDAttr:RMD_ATTR_AZTEC];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"HanXin" aRMDAttr:RMD_ATTR_HANXIN];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Composite CC-C" aRMDAttr:RMD_ATTR_COMPOSITE_CC_C];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Composite CC-A/B" aRMDAttr:RMD_ATTR_COMPOSITE_CC_A_B];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Composite TLC-39" aRMDAttr:RMD_ATTR_COMPOSITE_TLC_39];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"Netherlands KIX" aRMDAttr:RMD_ATTR_SYM_Netherlands_KIX];
        [m_Symbologies addObject:tmp];
        
        tmp = [[zt_Symbology alloc] init:@"UPU FICS" aRMDAttr:RMD_ATTR_SYM_UPU_FICS];
        [m_Symbologies addObject:tmp];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            /* iphone */
            tmp = [[zt_Symbology alloc] init:@"USPS 4CB/ONE Code" aRMDAttr:RMD_ATTR_SYM_USPS_4CB_ONECODE_INTELLIGENT_MAIL];
        }
        else
        {
            /* ipad */
            tmp = [[zt_Symbology alloc] init:@"USPS 4CB/ONE Code/Intelligent Mail" aRMDAttr:RMD_ATTR_SYM_USPS_4CB_ONECODE_INTELLIGENT_MAIL];
        }
        
        [m_Symbologies addObject:tmp];
        
    }
    didStartDataRetrieving = NO;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Symbologies"];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
    
    self.tableView.tableHeaderView = headerView;
    
    SSCheckBoxView *check = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(0, 5, 200, 44) style:kSSCheckBoxViewStyleDark checked:NO];
    [headerView addSubview:check];
    [check setText:@"Permanent"];
    //disabled the symbology saving permanantly for CS4070
    if ([[[[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID] getScannerName]containsSubString:SST_SCANNER_MODEL_SSI_CS4070]) {
        check.hidden = YES;
    }
    [check setStateChangedBlock:^(SSCheckBoxView *v) {
        [self checkBoxViewChangedState:v];
    }];
    
    if (NO == m_SymbologiesRetrieved)
    {
        [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(getSymbologiesConfiguration) withObject:nil withString:@"Retrieving Symbologies..."];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (group)
    {
        dispatch_suspend(group);
    }
}

- (void) checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    shouldSavePermanantly = cbv.checked;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setScannerID:(int)scanner_id
{
    m_ScannerID = scanner_id;
}

- (void)getSymbologiesConfiguration
{
    /* get supported symbologies */
    didStartDataRetrieving = YES;
    
    NSString* in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    SBT_RESULT res1 = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GETALL aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    if (res1 != SBT_RESULT_SUCCESS)
    {
        [NSThread sleepForTimeInterval:2.0];
        SBT_RESULT resSecond = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GETALL aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
        if (resSecond != SBT_RESULT_SUCCESS)
        {
            [NSThread sleepForTimeInterval:2.0];
            SBT_RESULT resSecond = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GETALL aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
            if (resSecond != SBT_RESULT_SUCCESS)
            {
                [self operationComplete];
                if (!didStartDataRetrieving) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(),^{
                    zt_ScannerDemoAppDelegate *appDelegate = (zt_ScannerDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
                    if (self->alert) {
                        if (appDelegate.window.rootViewController.presentedViewController == self->alert)
                        {
                            [self->alert dismissViewControllerAnimated:FALSE completion:nil];
                            
                        }
                    }
                    if (self->didStartDataRetrieving) {
                        
                        self->alert = [UIAlertController
                                        alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                         message:ZT_SCANNER_CANNOT_RETRIEVE_SUPPORT_SYMBOLOGYS
                                                  preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction
                                            actionWithTitle:OK
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Handle ok action
                                                    }];
                        [self->alert addAction:okButton];

                        [self presentViewController:self->alert animated:YES completion:nil];
                        self->didStartDataRetrieving = NO;
                    }
                });
                return;
            }
        }
    }
    
    /* get ids of all supported attributes */
    NSString* res_str = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString* tmp = @"<attrib_list><attribute name=\"\">";
    NSRange range = [res_str rangeOfString:tmp];
    
    if ((range.location == NSNotFound) || (range.length != [tmp length]))
    {
        [self operationComplete];
        return;
    }
    
    res_str = [res_str substringFromIndex:(range.location + range.length)];
    
    tmp = @"</attribute></attrib_list>";
    range = [res_str rangeOfString:tmp];
    
    if ((range.location == NSNotFound) || (range.length != [tmp length]))
    {
        [self operationComplete];
        return;
    }
    range.length = [res_str length] - range.location;
    
    res_str = [res_str stringByReplacingCharactersInRange:range withString:@""];
    NSArray *attrs = [res_str componentsSeparatedByString:@"</attribute><attribute name=\"\">"];
    
    if ([attrs count] == 0)
    {
        [self operationComplete];
        return;
    }
    
    BOOL one_supported = NO;
    
    /* check which symbologies are supported */
    for (zt_Symbology *s in m_Symbologies)
    {
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        int sym_attr_id = [s getRMDAttributeID];
        for (NSString *str in attrs)
        {
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
            if (sym_attr_id == [str intValue])
            {
                [s setSupported:YES];
                one_supported = YES;
                break;
            }
        }
    }
    
    if (NO == one_supported)
    {
        [self operationComplete];
        return;
    }
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    group = dispatch_group_create();
    
    /* For CS4070 we request each symbology in a seperate xml.
     For others, all can be requested using a single xml
     */
    
    BOOL isCS4070 = [[[[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID] getScannerName]containsSubString:SST_SCANNER_MODEL_SSI_CS4070];
    
    in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>", m_ScannerID];
    
    zt_Symbology *sym;
    for (int i = 0; i < [m_Symbologies count]; i++)
    {
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        sym = [m_Symbologies objectAtIndex:i];
        
        if ([sym isSupported] == YES)
        {
            if (isCS4070) {
                if (i % 15 != 0) {
                    in_xml = [in_xml stringByAppendingString:[NSString stringWithFormat:@"%d,", [sym getRMDAttributeID]]];
                    if (i == [m_Symbologies count]-1) {
                         [self sendRequest:in_xml withOutXml:result withSymbology:sym];
                    }
                } else if (i % 15 == 0 && i != 0){
                    in_xml = [in_xml stringByAppendingString:[NSString stringWithFormat:@"%d,", [sym getRMDAttributeID]]];
                    [self sendRequest:in_xml withOutXml:result withSymbology:sym];
                    in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>", m_ScannerID];
                } else if (i == 0) {
                    in_xml = [in_xml stringByAppendingString:[NSString stringWithFormat:@"%d,", [sym getRMDAttributeID]]];
                }
                
            } else {
                in_xml = [in_xml stringByAppendingString:[NSString stringWithFormat:@"%d,", [sym getRMDAttributeID]]];
            }
        }
    }
    
    if (!isCS4070) {
        [self sendRequest:in_xml withOutXml:result withSymbology:sym];
    }
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(),^{
            self->didStartDataRetrieving = NO;
            [self operationComplete];
            
        });
    });
}

- (void)sendRequest:(NSString*)in_xml withOutXml:(NSMutableString*)result withSymbology:(zt_Symbology*)sym
{
    in_xml = [in_xml stringByReplacingCharactersInRange:NSMakeRange(in_xml.length - 1, 1) withString:@""];
    
    in_xml = [in_xml stringByAppendingString:@"</attrib_list></arg-xml></cmdArgs></inArgs>"];
    result = [[NSMutableString alloc] init];
    [result setString:@""];
    
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    SBT_RESULT resCode = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
    if (!didStartDataRetrieving) {
        [self operationComplete];
        return;
    }
    
    if (SBT_RESULT_SUCCESS != resCode)
    {
        SBT_RESULT resCodeTwo = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
        if (SBT_RESULT_SUCCESS != resCodeTwo)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                zt_ScannerDemoAppDelegate *appDelegate = (zt_ScannerDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
                [self operationComplete];
                if (self->alert) {
                    if (appDelegate.window.rootViewController.presentedViewController == self->alert)
                         {
                             [self->alert dismissViewControllerAnimated:FALSE completion:nil];
                         }
                }
                if (self->didStartDataRetrieving) {
                     self->alert = [UIAlertController
                                       alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                                        message:ZT_SCANNER_CANNOT_RETRIEVE_SUPPORT_SYMBOLOGYS_TRY_AGAIN
                                                 preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction* okButton = [UIAlertAction
                                           actionWithTitle:OK
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       //Handle ok action
                                                   }];
                       [self->alert addAction:okButton];
                       [self presentViewController:self->alert animated:YES completion:nil];
                }
                self->didStartDataRetrieving = NO;
           });
            return;
        }
    }
    
    dispatch_group_async(group, queue, ^{
        [self updateUI:sym withInXML:in_xml withResult:result];
    });
}

- (void)updateUI:(zt_Symbology*)sym withInXML:(NSString*)in_xml withResult:(NSMutableString*)result
{
    BOOL success = FALSE;
    
    /* success */
    do {
        if (!didStartDataRetrieving) {
            [self operationComplete];
            return;
        }
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
        BOOL attr_val;
        
        for (NSString *pstr in attrs)
        {
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
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
            
            attr_str = [attr_str lowercaseString];
            
            if ([attr_str isEqualToString:@"false"] == YES)
            {
                attr_val = NO;
            }
            else if ([attr_str isEqualToString:@"true"] == YES)
            {
                attr_val = YES;
            }
            else
            {
                break;
            }
            
            BOOL found = NO;
            for (int j = 0; j < [m_Symbologies count]; j++)
            {
                if (!didStartDataRetrieving) {
                    [self operationComplete];
                    return;
                }
                sym = (zt_Symbology*)[m_Symbologies objectAtIndex:j];
                if ([sym getRMDAttributeID] == attr_id)
                {
                    found = YES;
                    [sym setEnabled:attr_val];
                }
            }
            
            if (NO == found)
            {
                break;
            }
        }
        
        success = TRUE;
        
    } while (0);
    
    
    if (FALSE == success)
    {
        for (zt_Symbology *s in m_Symbologies)
        {
            if (!didStartDataRetrieving) {
                [self operationComplete];
                return;
            }
            [s setEnabled:NO];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        for (int i = 0; i < [self->m_Symbologies count]; i++){
           if (!self->didStartDataRetrieving) {
               [self operationComplete];
               return;
           }
           zt_Symbology *sym = (zt_Symbology*)[self->m_Symbologies objectAtIndex:i];
           
           zt_SwitchTableViewCell* cell = (zt_SwitchTableViewCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
           
           if (cell != nil){
               [cell setSwitchOn:[sym isEnabled]];
               [cell.cellSwitch setEnabled:[sym isSupported]];
           }
       }
    });
    
    m_SymbologiesRetrieved = TRUE;
}

- (void)setSymbologyConfiguration:(NSString*)param withIndex:(int)index withStatuc:(BOOL)isON
{
    SBT_RESULT res;
    if (shouldSavePermanantly) {
        res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_STORE aInXML:param aOutXML:nil forScanner:m_ScannerID];
    } else {
        res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_SET aInXML:param aOutXML:nil forScanner:m_ScannerID];
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [self operationComplete];
    });
    
    
    if (SBT_RESULT_SUCCESS !=  res )
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_SYMBOLOGY_CONFIG_FAILED
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
        
        /* failed, return to previous value */
        
        NSString *pattern = @"<inArgs><scannerID>(\\d+)</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>(\\d+)</id><datatype>F</datatype><value>(.+)/value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>";
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:pattern
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
        
        NSTextCheckingResult *res = [regex firstMatchInString:param options:0 range:NSMakeRange(0, param.length)];
        
        if ([res numberOfRanges] == 4)
        {
            int sym_attr_id = [[param substringWithRange:[res rangeAtIndex:2]] intValue];
            NSString *sym_attr_value = [param substringWithRange:[res rangeAtIndex:3]];
            BOOL enabled = [sym_attr_value isEqualToString:@"True"];
            
            zt_Symbology *s;
            
            for (int i = 0; i < [m_Symbologies count]; i++)
            {
                s = [m_Symbologies objectAtIndex:i];
                if ([s getRMDAttributeID] == sym_attr_id)
                {
                    zt_SwitchTableViewCell *cell = (zt_SwitchTableViewCell*)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    dispatch_async(dispatch_get_main_queue(),^{
                        if (cell != nil)
                        {
                            [cell setSwitchOn:(enabled == YES) ? NO : YES];
                        }
                    });
                    break;
                }
            }
        }
    } else {
        zt_Symbology  *sym = [m_Symbologies objectAtIndex:index];
        [sym setEnabled:isON];
    }
}

/* ###################################################################### */
/* ########## ISwitchTableViewCell Protocol implementation ############## */
/* ###################################################################### */
- (void)switchValueChanged:(BOOL)on aIndex:(int)index
{
    if (index < [m_Symbologies count])
    {
        if (YES == m_SymbologiesRetrieved)
        {
            zt_Symbology *sym = (zt_Symbology *)[m_Symbologies objectAtIndex:index];
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list><attribute><id>%d</id><datatype>F</datatype><value>%@</value></attribute></attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, [sym getRMDAttributeID], (on == YES) ? @"True" : @"False"];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^void{
                [self setSymbologyConfiguration:in_xml withIndex:index withStatuc:on];
            });
        }
        else
        {
            [self operationComplete];
            
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_SUPPORT_SYMBOLOGYS_NOT_RETRIEVED
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
    }
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_Symbologies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SymbologyCell";
    zt_SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[zt_SwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setIndex:(int)[indexPath row]];
    [cell setDelegate:self];
    zt_Symbology *sym = [m_Symbologies objectAtIndex:[indexPath row]];
    cell.cellTitle.text = [sym getSymbologyName];
    [cell.cellSwitch setEnabled:[sym isSupported]];
    [cell setSwitchOn:[sym isEnabled]];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
