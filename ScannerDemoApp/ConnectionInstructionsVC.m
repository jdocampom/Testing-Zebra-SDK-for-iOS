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
 *  Description:  ConnectionInstructionsVC.m
 *
 *  Notes: Collection View controller used to display connection instruction
 *         steps.
 *
 ******************************************************************************/

#import "BarcodeImage.h"
#import "ConnectionInstructionsVC.h"
#import "ConnectionHelpView.h"
#import "UIColor+DarkModeExtension.h"

@interface zt_ConnectionInstructionsVC ()
{
    CONNECTION_INSTRUCTION instructionId;
}

@property (nonatomic,retain) IBOutlet UIScrollView *aScrollView;
@property (nonatomic,retain) zt_ConnectionHelpView *instructionView;

@end

NSString * const connectionHelpRS5100 = @"ConnectionHelpRs5100";
NSString * const pairScannerRS5100 = @"Pair RS5100";

@implementation zt_ConnectionInstructionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self darkModeCheck:self.traitCollection];
    if (instructionId == INSTRUCTION_PAIR_RFD8500)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionHelpRfd8500" owner:self options:nil] firstObject];
        
        [self setTitle:@"Pair RFD8500"];
    }
    else if (instructionId == INSTRUCTION_PAIR_CS4070)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionHelpCs4070" owner:self options:nil] firstObject];
        
        [self setTitle:@"Pair CS4070"];
    }
    else if (instructionId == INSTRUCTION_PAIR_LI_DS3678)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionHelpLiDs3678" owner:self options:nil] firstObject];
        
        [self setTitle:@"Pair LI/DS3678"];
    }
    else if (instructionId == INSTRUCTION_PAIR_DS2278)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionHelpDs2278" owner:self options:nil] firstObject];
        
        [self setTitle:@"Pair DS2278"];
    }
    else if (instructionId == INSTRUCTION_PAIR_RS5100)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:connectionHelpRS5100 owner:self options:nil] firstObject];
        
        [self setTitle:pairScannerRS5100];
    }
    else if (instructionId == INSTRUCTION_PAIR_DS8178_MFI)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionHelpDs8178Mfi" owner:self options:nil] firstObject];
        
        [self setTitle:@"Pair DS8178 (MFi)"];
    }
    else if (instructionId == INSTRUCTION_PAIR_DS8178_BTLE)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionHelpDs8178Btle" owner:self options:nil] firstObject];
        
        [self setTitle:@"Pair DS8178 (BTLE)"];
    }
    else if (instructionId == INSTRUCTION_SET_DEFAULTS)
    {
        self.instructionView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectionHelpSetDefaults" owner:self options:nil] firstObject];
        
        [self setTitle:@"Set Defaults"];
    }
    
    if (self.instructionView != nil)
    {
        self.aScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.aScrollView];
        
        self.instructionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.aScrollView addSubview:self.instructionView];
        
        // Auto-layout
        
        UIScrollView *scrollView = self.aScrollView;
        zt_ConnectionHelpView *instrView = self.instructionView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, instrView);
        
        NSArray *instructionViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[instrView(scrollView)]" options:0 metrics:nil views:views];
        [scrollView addConstraints:instructionViewConstraints];
        
        instructionViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[instrView]|" options:0 metrics:nil views:views];
        [scrollView addConstraints:instructionViewConstraints];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.instructionView setNeedsDisplay];
   
  
}

- (void) dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadInstructionsFor:(CONNECTION_INSTRUCTION)instruction
{
    instructionId = instruction;
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
    self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
}

/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
}

@end
