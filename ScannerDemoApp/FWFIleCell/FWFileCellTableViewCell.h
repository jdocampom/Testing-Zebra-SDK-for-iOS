//
//  FWFileCellTableViewCell.h
//  FileBrowser
//
//  Created by pqj647 on 7/3/16.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FileSelectedDelegate <NSObject>

- (void)didSelectFile:(NSString*)filePath;

@end

@interface FWFileCellTableViewCell : UITableViewCell

@property id<FileSelectedDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;
@property (weak, nonatomic) IBOutlet UILabel *fileName;

- (IBAction)clickSelected:(id)sender;

@end
