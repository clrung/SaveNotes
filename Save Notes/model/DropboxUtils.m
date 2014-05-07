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

@end
