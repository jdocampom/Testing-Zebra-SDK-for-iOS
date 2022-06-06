//
//  PFWModelContentReader.h
//  ScannerSDKApp
//
//  Created by PQJ647 on 10/13/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWUpdateModel.h"

@protocol PFWModelContentReader <NSObject>

- (NSString*)readPluginFileData:(void (^)(FWUpdateModel *model))block;

- (FWUpdateModel*)getFWUpdateModel;

- (void)setReleaseNoteFilePath:(NSString*)path;

- (void)setMetaDataFilePath:(NSString*)path;

@end
