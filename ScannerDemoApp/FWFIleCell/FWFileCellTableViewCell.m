//
//  FWFileCellTableViewCell.m
//  FileBrowser
//
//  Created by pqj647 on 7/3/16.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "FWFileCellTableViewCell.h"

@implementation FWFileCellTableViewCell

- (void) awakeFromNib {
    /// Initialization code
    [super awakeFromNib];
    self.okButton.layer.cornerRadius = 3.0;
    self.okButton.layer.borderWidth = 2.0;
}


- (void) setSelected:(BOOL) selected animated:(BOOL) animated {
    [super setSelected: selected animated: animated];
}


- (IBAction) clickSelected:(id) sender {
    if (self.delegate != nil && [self.delegate respondsToSelector: @selector(didSelectFile:)]) {
        [self.delegate didSelectFile: self.fileName.text];
    }
}

@end
