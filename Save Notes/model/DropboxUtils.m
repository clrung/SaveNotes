//
//  DropboxUtils.m
//  Save Notes
//
//  Created by Christopher Rung on 5/7/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//

#import "DropboxUtils.h"

@implementation DropboxUtils

//
// Displays an alert if the user hasn't linked a Dropbox account to the
// application yet. Returns YES if the Dropbox account is linked, NO otherwise.
//
+ (BOOL)checkLinked {
    if(![[[DBAccountManager sharedManager] linkedAccount] isLinked]) {
        [[[UIAlertView alloc] initWithTitle:@"No account found!"
                                    message:@"Please link your Dropbox account in the Settings tab."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

//
// Initializes the Dropbox account
//
+ (void)initDBAccount {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
}

#pragma mark - File Operations

//
// Returns the file corresponding to the passed DBFileInfo object.
//
+ (DBFile*)getFileFromFileInfo:(DBFileInfo *)info {
    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:info.path error:nil];
    if (!file) {
        [[[UIAlertView alloc]
          initWithTitle:@"Unable to open note!" message:@"An error has occurred."
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    return file;
}

//
// Returns the file info's title and contents of the note
//
+ (NSString*)getFileTitleAndContents:(DBFileInfo *)info {
    DBFile *file = [self getFileFromFileInfo:info];
    NSString *contents = [file readString:nil];
    NSString *title = [[[info path] name] stringByDeletingPathExtension];
    
    return [NSString stringWithFormat:@"%@\n%@", title, contents];
}

@end
