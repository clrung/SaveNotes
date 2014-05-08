//
//  DropboxUtils.h
//  Save Notes
//
//  Created by Christopher Rung on 5/7/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//
//  This class handles the Dropbox account.

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

@interface DropboxUtils : NSObject

+ (BOOL)checkLinked;
+ (void)initDBAccount;
+ (DBFile*)getFileFromFileInfo:(DBFileInfo *)info;
+ (NSString*)getFileTitleAndContents:(DBFileInfo *)info;

@end
