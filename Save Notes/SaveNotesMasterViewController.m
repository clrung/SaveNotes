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

@interface SaveNotesMasterViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *searchResults;
@end

@implementation SaveNotesMasterViewController

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

//
// Adds the edit and add buttons to the view controller, initializes the
// Dropbox account, and initializes the refresh control.
//
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

//
// Loads the files from Dropbox if the user has linked their account.
//
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
            
            self.tableData = [[NSMutableArray alloc] init];
            for(DBFileInfo *info in _fileInfos) {
                [self.tableData addObject:[self getFileTitleAndContents:info]];
            }
            
            self.searchResults = [NSMutableArray arrayWithCapacity:_fileInfos.count];

            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

//
// Returns the file corresponding to the passed DBFileInfo object.
//
- (DBFile*)getFileFromFileInfo:(DBFileInfo *)info {
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
- (NSString*)getFileTitleAndContents:(DBFileInfo *)info {
    DBFile *file = [self getFileFromFileInfo:info];
    NSString *contents = [file readString:nil];
    NSString *title = [[[info path] name] stringByDeletingPathExtension];
    
    return [NSString stringWithFormat:@"%@\n%@", title, contents];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return _searchResults.count;
    else
        return _fileInfos.count;
}

//
// Populates the main TableView or the search TableView with the notes' titles.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        NSLog(@"cell is nil");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
  }  else {
        DBFileInfo *fileInfo = _fileInfos[indexPath.row];
        cell.textLabel.text = [[fileInfo.path name] stringByDeletingPathExtension];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"showDetail" sender:tableView];
    }
}

//
// Removes the cell from the TableView and also deletes the file from Dropbox.
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

#pragma mark - Searching

//
// Populates the search results with the results of user's query.
//
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    self.searchResults = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
}

//
// Reloads the table with the search results.
//
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
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
        
        SaveNotesDetailViewController *controller = segue.destinationViewController;
        
        if([sender isKindOfClass:[DBFile class]]) {
            [controller setFile:sender];
        } else {
            //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSIndexPath *indexPath = nil;
            
            if(sender == self.searchDisplayController.searchResultsTableView) { // search results
                indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                NSLog(@"%@", indexPath );
            } else {
                indexPath = [self.tableView indexPathForSelectedRow];
            }
            
            DBFileInfo *info = _fileInfos[indexPath.row];
            DBFile *file = [self getFileFromFileInfo:info];
            [controller setFile:file];
        }
    }
}

@end