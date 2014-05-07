//
//  SaveNotesDetailViewController.m
//  Save Notes
//
//  Created by Christopher Rung on 5/3/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//

#import "SaveNotesDetailViewController.h"
#import <Dropbox/Dropbox.h>

@interface SaveNotesDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) DBFile *file;
@property (strong, nonatomic) IBOutlet UITextView *detailTextView;
- (void)configureView;
@end

@implementation SaveNotesDetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self configureView];
}

- (void)setFile:(DBFile *)file {
    _file = file;
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.navigationItem.title = [[_file.info.path name] stringByDeletingPathExtension];
    [_detailTextView setText:[_file readString:nil]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
// Removes blank space at the top of the TextView.
//
- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

//
// Updates the file to reflect any changes in the note before returning
// to the Master.
//
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_file writeString:_detailTextView.text error:nil];
}

@end
