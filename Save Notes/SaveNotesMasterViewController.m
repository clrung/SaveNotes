//
//  SaveNotesMasterViewController.m
//  Save Notes
//
//  Created by Christopher Rung on 5/3/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//

#import "SaveNotesMasterViewController.h"
#import "SaveNotesDetailViewController.h"
#import "DropboxUtils.h"
#import <Dropbox/Dropbox.h>

@interface SaveNotesMasterViewController ()

@end

@implementation SaveNotesMasterViewController

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(displayNewNoteAlert:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (SaveNotesDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [DropboxUtils initDBAccount];
    
    [self.refreshControl addTarget:self
                            action:@selector(loadFiles)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL isLinked = [DropboxUtils checkLinked];
    if (isLinked) {
        [self loadFiles];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
// Displays an alert to get the title of the new note.
//
- (void)displayNewNoteAlert:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create New Note"
                                                        message:@"Enter note title below"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Create", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

//
// Creates a new note with the text specified in the AlertView.
//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        NSString *title = [alertView textFieldAtIndex:0].text;
        [self createNoteWithTitle:title];
    }
}

//
// Loads the note files from the Dropbox server.
//
- (void)loadFiles {
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        NSArray *immContents = [[DBFilesystem sharedFilesystem] listFolder:[DBPath root] error:nil];
        NSMutableArray *mContents = [NSMutableArray arrayWithArray:immContents];
        //[NSThread sleepForTimeInterval:2.0];         // tests network activity indicator
        dispatch_async(dispatch_get_main_queue(), ^() {
            _fileInfos = mContents;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

//
// Creates a new text file with the specified title.  If the filename already
// exists, the application will open the existing note.  If not, it will open
// a new note in the detail view controller.
//
- (void)createNoteWithTitle:(NSString*)title {
    NSString *fileName = [NSString stringWithFormat:@"%@.txt", title];
    DBPath *path = [[DBPath root] childPath:fileName];
    DBError *error;
    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:path error:&error];
    
    if (error) {
        file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
    }
    
    [_fileInfos addObject:file.info];
    [self performSegueWithIdentifier:@"showDetail" sender:file];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    DBFileInfo *fileInfo = _fileInfos[indexPath.row];
    cell.textLabel.text = [[fileInfo.path name] stringByDeletingPathExtension];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//
// Handles deletion of files.
//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *selectedCellText = selectedCell.textLabel.text;
        
        DBPath *path = [[DBPath root] childPath:[NSString stringWithFormat:@"%@.txt", selectedCellText]];
        [[DBFilesystem sharedFilesystem] deletePath:path error:nil];
        
        [_fileInfos removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - Navigation

//
// Gives the detail controller the file to display.  The sender is either
// a file or a table view item.  If it is a file, simply set the file to it.
// If it is a table view item, open the file and then set the file to the
// opened file.
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        SaveNotesDetailViewController *controller = segue.destinationViewController;
        
        if([sender isKindOfClass:[DBFile class]]) {
            [controller setFile:sender];
        } else {
            DBFileInfo *info = _fileInfos[indexPath.row];
            DBFile *file = [[DBFilesystem sharedFilesystem] openFile:info.path error:nil];
            if (!file) {
                [[[UIAlertView alloc]
                  initWithTitle:@"Unable to open note!" message:@"An error has occurred."
                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
            [controller setFile:file];
        }
    }
}

@end
