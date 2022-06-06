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
 *  Description:  LedActionVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "LedActionVC.h"
#import "RMDAttributes.h"
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "config.h"
#import "NSString+Contain.h"

// Defining the following flag will remove the Red and Yellow LED
// options for the RFD8500 device. The Red and Yellow LED's are currently
// unsupported, but will be re-enabled in the future
#define LOCAL_CONFIG_RFD8500_HIDE_RED_YELLOW_LED

@interface zt_LedActionVC ()

@end

@implementation zt_LedActionVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_LedValues = [[NSMutableArray alloc] init];
        m_LedNames = [[NSMutableArray alloc] init];
        m_ScannerID = SBT_SCANNER_ID_INVALID;
        m_ScannerModel = SST_SCANNER_MODEL_UNKNOWN;
        m_RequiredLedAction = YES;
    }
    return self;
}


- (void)dealloc
{
    if (m_LedNames != nil)
    {
        [m_LedNames removeAllObjects];
        [m_LedNames release];
    }
    if (m_LedValues != nil)
    {
        [m_LedValues removeAllObjects];
        [m_LedValues release];
    }
    
    if (activityView != nil)
    {
        [activityView release];
    }
    
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"LED Actions"];
    
    activityView = [[zt_AlertView alloc]init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScannerID:(int)scanner_id
{
    m_ScannerID = scanner_id;
    
    m_ScannerModel = [[[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID] getScannerName];
    if([m_ScannerModel containsSubString:SST_SCANNER_MODEL_SSI_CS4070]){
        // CS4070 firmware does not support SET ACTION commands to control LED. Use SSI commands instead.
        [m_LedNames addObject:@"Green LED ON"];
        [m_LedValues addObject:[NSNumber numberWithInt:SBT_LEDCODE_GREEN]];
        [m_LedNames addObject:@"Green LED OFF"];
        [m_LedValues addObject:[NSNumber numberWithInt:SBT_LEDCODE_GREEN]];
        [m_LedNames addObject:@"Amber LED ON"];
        [m_LedValues addObject:[NSNumber numberWithInt:SBT_LEDCODE_AMBER]];
        [m_LedNames addObject:@"Amber LED OFF"];
        [m_LedValues addObject:[NSNumber numberWithInt:SBT_LEDCODE_AMBER]];
        [m_LedNames addObject:@"Red LED ON"];
        [m_LedValues addObject:[NSNumber numberWithInt:SBT_LEDCODE_RED]];
        [m_LedNames addObject:@"Red LED OFF"];
        [m_LedValues addObject:[NSNumber numberWithInt:SBT_LEDCODE_RED]];
    }else{
        [m_LedNames addObject:@"Green LED ON"];
        [m_LedValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_GREEN_ON]];
        [m_LedNames addObject:@"Green LED OFF"];
        [m_LedValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_GREEN_OFF]];
        [m_LedNames addObject:@"Red LED ON"];
        [m_LedValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_RED_ON]];
        [m_LedNames addObject:@"Red LED OFF"];
        [m_LedValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_RED_OFF]];
        [m_LedNames addObject:@"Yellow LED ON"];
        [m_LedValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_YELLOW_ON]];
        [m_LedNames addObject:@"Yellow LED OFF"];
        [m_LedValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LED_YELLOW_OFF]];
    }
    
}

- (void)performLedAction:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_SET_ACTION aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_LED_ACTION
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
    }
}

- (void)performLedControl:(NSNumber*)ledCode
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] ledControl:m_RequiredLedAction aLedCode:[ledCode intValue] forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
            UIAlertController * alert = [UIAlertController
                            alertControllerWithTitle:ZT_SCANNER_APP_NAME
                                             message:ZT_SCANNER_CANNOT_PERFORM_LED_ACTION
                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:OK
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle ok action
                                        }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            [alert release];
                       }
                       );
    }
    
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [m_LedNames count] / 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *LedActionCellIdentifier = @"LedActionCell";
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:LedActionCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LedActionCellIdentifier];
    }
    cell.textLabel.text = [m_LedNames objectAtIndex:[indexPath row] + ([indexPath section] * 2)];
    
    return cell;
}

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL led_enable = ([indexPath row] == 0);
    
    m_RequiredLedAction = led_enable;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    NSUInteger ledValueIndex = [indexPath row] + ([indexPath section] * 2);
    
    // CS4070 firmware does not support SET ACTION commands to control LED. Use SSI commands instead.
    if ([m_ScannerModel containsSubString:SST_SCANNER_MODEL_SSI_CS4070])
    {
        [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performLedControl:) withObject:[m_LedValues objectAtIndex:ledValueIndex] withString:nil];
    }
    else
    {
        NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-int>%d</arg-int></cmdArgs></inArgs>", m_ScannerID, [[m_LedValues objectAtIndex:[indexPath row] + ([indexPath section] * 2)] intValue]];
        
        [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performLedAction:) withObject:in_xml withString:nil];        
    }
}

@end
