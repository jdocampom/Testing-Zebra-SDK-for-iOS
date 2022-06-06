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

#import "ConnectionHelpVC.h"
#import "ConnectionInstructionsVC.h"
#import "UIColor+DarkModeExtension.h"
#import "config.h"
#import "AboutAppVC.h"

typedef enum
{
    INSTR_INDEX_CS4070 = 0,
    INSTR_INDEX_RFD8500,
    INSTR_INDEX_LI3678,
    INSTR_INDEX_DS8178,
    INSTR_INDEX_DS2278,
    INSTR_INDEX_RS5100,
    INSTR_INDEX_SET_DEFAULTS,
    INSTR_TOTAL
    
} Instruction_Index;

@interface zt_ConnectionHelpVC ()

@end

@implementation zt_ConnectionHelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *aboutusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ABOUTUS_IMAGE] style:UIBarButtonItemStylePlain target:self action:@selector(aboutAction:)];
    [[self navigationItem] setRightBarButtonItem:aboutusButton];
}

/// Call the about app view controller.
/// @param sender Send the button id as a sender.
-(IBAction)aboutAction:(id)sender
{
    zt_AboutAppVC *about_vc = nil;
    about_vc = (zt_AboutAppVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_APP_ABOUT_VC];
    if (about_vc != nil)
    {
        [self.navigationController pushViewController:about_vc animated:YES];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setTitle:CONNECTION_HELP_TITLE];
    [self darkModeCheck:self.traitCollection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([indexPath row] != INSTR_INDEX_DS8178)
    {
        zt_ConnectionInstructionsVC *connectionInstructions = nil;
        
        connectionInstructions = (zt_ConnectionInstructionsVC*)[[UIStoryboard storyboardWithName:SCANNER_STORY_BOARD bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:ID_APP_CONNECTION_INSTRUCTIONS_VC];
        
        if ([indexPath row] == INSTR_INDEX_CS4070)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_CS4070];
            
        }
        else if ([indexPath row] == INSTR_INDEX_RFD8500)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_RFD8500];
        }
        else if ([indexPath row] == INSTR_INDEX_LI3678)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_LI_DS3678];
        }
        else if ([indexPath row] == INSTR_INDEX_DS2278)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_DS2278];
        }
        else if ([indexPath row] == INSTR_INDEX_RS5100)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_RS5100];
        }
        else if ([indexPath row] == INSTR_INDEX_SET_DEFAULTS)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_SET_DEFAULTS];
        }
        
        if (connectionInstructions != nil)
        {
            [self.navigationController pushViewController:connectionInstructions animated:YES];
        }
    }
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
    labelHelpCS4070Title.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    labelHelpDS2278Title.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    labelHelpSetDefaultTitle.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    labelHelpDS3678Title.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    labelHelpDS8178Title.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    labelHelpRS5100Title.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
    labelHelpRFD8500Title.textColor = [UIColor getDarkModeLabelTextColor:traitCollection];
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
