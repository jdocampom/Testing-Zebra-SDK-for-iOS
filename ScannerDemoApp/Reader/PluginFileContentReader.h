//
//  PluginFileContentReader.h
//  ScannerSDKApp
//
//  Created by PQJ647 on 10/13/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFWModelContentReader.h"

@interface PluginFileContentReader : NSObject<PFWModelContentReader, NSXMLParserDelegate> {
    NSString *plugFamily;//family+name
    NSString *plugName;
    NSString *plugInRev;//revision
    NSString *plugInDate;//release-date
    NSString *matchingPlugInFWName;//TBD
    NSString *pngFileName;
    NSString *releaseNotes;
    
    NSString *releaseNotesFilePath;
    NSString *metadataFilePath;
    NSString *xmlContent;
    
    NSMutableArray *modelList;
    
    //for nsxmlparser sml parsing
    // an ad hoc string to hold element value
    NSMutableString *currentElementValue;
    FWUpdateModel *fwModel;
}

@property(nonatomic, retain)NSString *pluginFilePath;

@end
