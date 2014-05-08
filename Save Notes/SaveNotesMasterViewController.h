//
//  SaveNotesMasterViewController.h
//  Save Notes
//
//  Created by Christopher Rung on 5/3/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//
//  This class manages the Master view controller, where all the notes are
//  displayed in a table view.

#import <UIKit/UIKit.h>

@class SaveNotesDetailViewController;

@interface SaveNotesMasterViewController : UITableViewController

@property (strong, nonatomic) SaveNotesDetailViewController *detailViewController;
@property (strong, nonatomic) NSMutableArray *fileInfos;

@end
