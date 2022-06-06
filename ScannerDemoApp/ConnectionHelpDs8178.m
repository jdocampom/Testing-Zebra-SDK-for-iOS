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
 *  Description:  ConnectionHelpVC.h
 *
 *  Notes: Table View controller used to navigate connection help screen
 *         for supported devices.
 *
 ******************************************************************************/

#import "ConnectionHelpDs8178.h"
#import "ConnectionInstructionsVC.h"
#import "UIColor+DarkModeExtension.h"
#import "config.h"
typedef enum
{
    INSTR_INDEX_BTLE = 0,
    INSTR_INDEX_MFI,
    INSTR_TOTAL
    
} Instruction_Index;

@interface zt_ConnectionHelpDs8178VC ()

@end

@implementation zt_ConnectionHelpDs8178VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [back autorelease];
    self.navigationItem.backBarButtonItem = back;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If true, the view is being added to the window using an animation.
- (void) viewWillAppear:(BOOL)animated
{
    [self setTitle:SCANNER_CONTROL_DS8178];
    [self darkModeCheck:self.traitCollection];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return INSTR_TOTAL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    zt_ConnectionInstructionsVC *connectionInstructions = nil;
    
    connectionInstructions = (zt_ConnectionInstructionsVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_APP_CONNECTION_INSTRUCTIONS_VC];
    
    if ([indexPath row] == INSTR_INDEX_BTLE)
    {
        [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_DS8178_BTLE];
        
    }
    else if ([indexPath row] == INSTR_INDEX_MFI)
    {
        [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_DS8178_MFI];
    }
    
    if (connectionInstructions != nil)
    {
        
        [self.navigationController pushViewController:connectionInstructions animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/// Tells the delegate the table view is about to draw a cell for a particular row
/// @param tableView The table view informing the delegate of this impending event.
/// @param cell A cell that tableView is going to use when drawing the row.
/// @param indexPath An index path locating the row in tableView
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor getDarkModeViewBackgroundColor:self.traitCollection];
    cell.textLabel.textColor = [UIColor getDarkModeLabelTextColor:self.traitCollection];
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    lablebMFI.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    lableBTLE.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    self.tableView.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    [self.tableView reloadData];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
