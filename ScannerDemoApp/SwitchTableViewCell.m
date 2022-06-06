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
 *  Description:  SwitchTableViewCell.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SwitchTableViewCell.h"

@implementation zt_SwitchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        m_Index = 0;
    }
    return self;
}

- (void)dealloc
{
    [_cellTitle release];
    [_cellSwitch release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (int)getIndex
{
    return m_Index;
}

- (void)setIndex:(int)index
{
    m_Index = index;
}

- (void)setDelegate:(id <ISwitchTableViewCellProtocol>)delegate
{
    m_Delegate = delegate;
}

- (IBAction)switchSymbologyValueChanged:(id)sender
{
    if (m_Delegate != nil)
    {
        [m_Delegate switchValueChanged:[_cellSwitch isOn] aIndex:m_Index];
    }
}

- (void)setSwitchOn:(BOOL)on
{
    [_cellSwitch setOn:on animated:NO];
}

@end
