//
//  PluginFileContentReader.m
//  ScannerSDKApp
//
//  Created by PQJ647 on 10/13/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import "PluginFileContentReader.h"
#import "config.h"
#import "ZZArchive.h"
#import "ZZArchiveEntry.h"

@interface PluginFileContentReader()
{
    NSMutableArray *scannerFirmwareVersions;
}

@end

@implementation PluginFileContentReader

- (NSString*)readPluginFileData:(void (^)(FWUpdateModel *model))block
{
    fwModel = [[FWUpdateModel alloc] init];
    scannerFirmwareVersions = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //extract release note text from the zip
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *dwnLoad = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
        //first look for plugins
        NSArray *pluginArray = [self findFiles:ZT_PLUGIN_FILE_EXTENTION fromPath:dwnLoad];
        if (pluginArray.count > 0) {
            //now we have a plugin file. get the text file out of it.
            pngFileName = nil;
            NSString *pathForPlugin = [dwnLoad stringByAppendingPathComponent:pluginArray[0]];
            ZZArchive* oldArchive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:pathForPlugin] error:nil];
            for (ZZArchiveEntry *firstArchiveEntry in oldArchive.entries) {
                NSString *fileName = firstArchiveEntry.fileName;
                if ([[fileName pathExtension] isEqualToString:ZT_RELEASE_NOTES_FILE_EXTENTION]) {
                    [self readReleaseNotes:firstArchiveEntry];
                    
                    if (releaseNotes == nil) {
                        [self readReleaseNotes:firstArchiveEntry];
                    }
                } else if([fileName isEqualToString:ZT_METADATA_FILE]) {
                    NSData *releaseNoteData = [firstArchiveEntry newDataWithError:nil];
                    xmlContent = [NSString stringWithUTF8String:[releaseNoteData bytes]];
                    [self parseXMLData:releaseNoteData];
                    
                    fwModel.supportedModels = modelList;
                    NSString *formattedPlugInRev = [plugInRev stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    NSString *formattedPlugInRevNoSpace = [formattedPlugInRev stringByReplacingOccurrencesOfString:@" " withString:@""];
                    fwModel.plugInRev = formattedPlugInRevNoSpace;
                    NSString *formattedPluginDate = [plugInDate stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    NSString *formattedPluginDateNoSpace = [formattedPluginDate stringByReplacingOccurrencesOfString:@" " withString:@""];
                    fwModel.releasedDate = formattedPluginDateNoSpace;
                    fwModel.firmwareNameArray = scannerFirmwareVersions;
                    
                    NSString *plugFamilyFinlae = [plugFamily stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    NSString *plugNameFinlae = [plugName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    fwModel.plugFamily = [NSString stringWithFormat:@"%@,%@", plugFamilyFinlae, plugNameFinlae];
                    
                    if (pngFileName != nil) {
                        for (ZZArchiveEntry *crntArchiveEntry in oldArchive.entries) {
                            NSString *fileName = crntArchiveEntry.fileName;
                            if ([fileName isEqualToString:pngFileName]) {
                                //we find a match
                                fwModel.imgData = [crntArchiveEntry newDataWithError:nil];
                            }
                        }
                    }
                }
            }
        }
        if (releaseNotes == nil) {
            NSArray *pluginArray = [self findFiles:ZT_PLUGIN_FILE_EXTENTION fromPath:dwnLoad];
            if (pluginArray.count > 0) {
                //now we have a plugin file. get the text file out of it.
                pngFileName = nil;
                NSString *pathForPlugin = [dwnLoad stringByAppendingPathComponent:pluginArray[0]];
                ZZArchive* oldArchive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:pathForPlugin] error:nil];
                for (ZZArchiveEntry *firstArchiveEntry in oldArchive.entries) {
                    NSString *fileName = firstArchiveEntry.fileName;
                    if ([[fileName pathExtension] isEqualToString:ZT_RELEASE_NOTES_FILE_EXTENTION]) {
                        [self readReleaseNotes:firstArchiveEntry];
                        
                        if (releaseNotes == nil) {
                            [self readReleaseNotes:firstArchiveEntry];
                            if (releaseNotes == nil) {
                                [self readReleaseNotes:firstArchiveEntry];
                            }
                        }
                    }
                }
            }
        }
        block(fwModel);
    });
    
    return nil;
}

- (void)readReleaseNotes:(ZZArchiveEntry*)firstArchiveEntry
{
    NSData *releaseNoteData = [firstArchiveEntry newDataWithError:nil];
    releaseNotes =  [[NSString alloc] initWithData:releaseNoteData encoding:NSUTF8StringEncoding];
    fwModel.releaseNotes = releaseNotes;
}

- (NSString*)readStringFromFile:(NSString*)filePath
{
    return [NSString stringWithContentsOfFile:filePath
                                     encoding:NSUTF8StringEncoding
                                        error:NULL];
}

- (NSArray *)findFiles:(NSString *)extension fromPath:(NSString*)path
{
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *item;
    NSArray *contents = [manager contentsOfDirectoryAtPath:path error:nil];
    for (item in contents)
    {
        if ([[item pathExtension]isEqualToString:extension])
        {
            [matches addObject:item];
        }
    }
    
    return matches;
}

- (void)parseXMLData:(NSData*)xmlData
{
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    
    // set delegate
    [nsXmlParser setDelegate:self];
    
    // parsing...
    BOOL success = [nsXmlParser parse];
    
    // test the result
    if (success) {
    } else {
        NSLog(@"Error parsing document!");
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:ZT_MODEL_LIST_TAG]) {
        modelList = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:ZT_FIRMWARE_NAME_TAG]) {
        // We are done with user entry – add the parsed user
        [scannerFirmwareVersions addObject:[[[attributeDict objectForKey:@"name"]stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentElementValue) {
        // init the ad hoc string with the value
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    } else {
        // append value to the ad hoc string
        [currentElementValue appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:ZT_MODEL_LIST_TAG]) {
        // We reached the end of the XML document
        return;
    } else if ([elementName isEqualToString:ZT_MODEL_TAG]) {
        // We are done with user entry – add the parsed user
        NSString *deviceName = [[currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        [modelList addObject:deviceName];
    } else if ([elementName isEqualToString:ZT_REVISION_TAG]) {
        // We are done with user entry – add the parsed user
        plugInRev = currentElementValue;
    } else if ([elementName isEqualToString:ZT_RELEASED_DATE_TAG]) {
        // We are done with user entry – add the parsed user
        plugInDate = currentElementValue;
    } else if ([elementName isEqualToString:ZT_FAMILY_TAG]) {
        // We are done with user entry – add the parsed user
        plugFamily = currentElementValue;
    } else if ([elementName isEqualToString:ZT_NAME_TAG]) {
        // We are done with user entry – add the parsed user
        plugName = currentElementValue;
    } else if ([elementName isEqualToString:@"component"]) {
        // We are done with user entry – add the parsed user
        [scannerFirmwareVersions addObject:[[currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    } else if ([elementName isEqualToString:ZT_PICTURE_FILE_NAME]) {
        // We are done with user entry – add the parsed user
        pngFileName = [[currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }

    currentElementValue = nil;
}

@end
