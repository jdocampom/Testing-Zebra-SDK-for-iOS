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
 *  Description:  ConfigurationListVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ConfigurationListVC.h"
#import "ScannerConfiguration.h"
#import "ConfigurationSingleVC.h"
#import "config.h"

@interface zt_ConfigurationListVC ()
@end

@implementation zt_ConfigurationListVC

- (id) initWithCoder:(NSCoder*) aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self != nil) {
        m_SelectedIndex = -1;
        m_SupportedConfigurations = [[NSMutableArray alloc] init];
        zt_ScannerConfiguration *cfg;
//        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"MFi mode" withCode: @"N017F12"];
//        [m_SupportedConfigurations addObject:cfg];
//        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"BTLE mode" withCode: @"N017F14"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"Set Factory Defaults" withCode: @"92"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"Battery Off" withCode: @"BATTOFF"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"Cradle Host" withCode: @"N017F0C"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"SPP Client" withCode: @"N017F0E"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"SPP Server" withCode: @"N017F0F"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"HID Server" withCode: @"N017F10"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"Low Beeper Volume" withCode: @"2050802"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"Medium Beeper Volume" withCode: @"2050801"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
        cfg = [[zt_ScannerConfiguration alloc] initWithName: @"High Beeper Volume" withCode: @"2050800"];
        [m_SupportedConfigurations addObject: cfg];
        [cfg release];
    }
    return self;
}


- (void) dealloc {
    [self.tableView setDataSource: nil];
    [self.tableView setDelegate: nil];
    if (m_SupportedConfigurations != nil) {
        [m_SupportedConfigurations removeAllObjects];
        [m_SupportedConfigurations release];
    }
    [super dealloc];
}


- (void) viewDidLoad {
    [super viewDidLoad];
    [self setTitle: @"Scanner Configurations"];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
}

// MARK: - TableView Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 1;
}


- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    return [m_SupportedConfigurations count];
}


- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    static NSString *CellIdentifier = @"ScannerConfigurationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    cell.textLabel.text = [[m_SupportedConfigurations objectAtIndex: [indexPath row]] getConfigurationName];
    return cell;
}

// MARK: - TableView Delegate

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    if (cell != nil) {
        [tableView deselectRowAtIndexPath: indexPath animated: YES];
    }
    m_SelectedIndex = [indexPath row];
    zt_ConfigurationSingleVC *cfg_single_vc = (zt_ConfigurationSingleVC*)[[UIStoryboard storyboardWithName: SCANNER_STORY_BOARD bundle :[NSBundle mainBundle]] instantiateViewControllerWithIdentifier: ID_CONFIGURATION_SINGLE_VC];
    if (cfg_single_vc != nil) {
        [cfg_single_vc setConfiguration: [m_SupportedConfigurations objectAtIndex: [indexPath row]]];
        [self.navigationController pushViewController: cfg_single_vc animated: YES];
    }
}

@end
