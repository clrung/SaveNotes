//
//  SaveNotesDetailViewController.h
//  Save Notes
//
//  Created by Christopher Rung on 5/3/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//
//  This class manages the detail view, where the notes' content is displayed
//  and editable.

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface SaveNotesDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (void)setFile:(DBFile *)file;

@end
