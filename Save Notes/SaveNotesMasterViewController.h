//
//  SaveNotesMasterViewController.h
//  Save Notes
//
//  Created by Christopher Rung on 5/3/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SaveNotesDetailViewController;

@interface SaveNotesMasterViewController : UITableViewController

@property (strong, nonatomic) SaveNotesDetailViewController *detailViewController;

@end
