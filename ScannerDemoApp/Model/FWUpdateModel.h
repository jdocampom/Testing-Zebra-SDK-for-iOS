//
//  FWUpdateModel.h
//  ScannerSDKApp
//
//  Created by pqj647 on 10/9/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWUpdateModel : NSObject

@property (nonatomic,retain) NSString *modelTitle;
@property (nonatomic,retain) NSString *datFileName;
@property (nonatomic,retain) NSString *releasedDate;
@property (nonatomic,retain) NSString *releaseNotes;
@property (nonatomic,retain) NSArray *supportedModels;
@property (nonatomic,retain) NSString *plugInRev;
@property (nonatomic,retain) NSString *plugFamily;//family+name
@property (nonatomic,retain) NSMutableArray *firmwareNameArray;
@property (nonnull, retain) NSData *imgData;

@end
