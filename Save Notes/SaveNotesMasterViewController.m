//
//  SaveNotesMasterViewController.m
//  Save Notes
//
//  Created by Christopher Rung on 5/3/14.
//  Copyright (c) 2014 Christopher Rung. All rights reserved.
//

#import "SaveNotesMasterViewController.h"
#import "SaveNotesDetailViewController.h"
#import <Dropbox/Dropbox.h>

@interface SaveNotesMasterViewController () {
    NSMutableArray *_fileInfos;
}
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
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (SaveNotesDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self initDBAccount];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL isLinked = [self checkLinked];
    if (isLinked) {
        [self loadFiles];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create New Note"
                                                        message:@"Enter note title below"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Create", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    
    
    
    /*
     
     if (!_objects) {
     _objects = [[NSMutableArray alloc] init];
     }
     [_objects insertObject:[NSDate date] atIndex:0];
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
     [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic]; */
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
// Displays an alert if the user hasn't linked a Dropbox account to the
// application yet. Returns YES if the Dropbox account is linked, NO otherwise.
//
- (BOOL)checkLinked {
    if(![[[DBAccountManager sharedManager] linkedAccount] isLinked]) {
        [[[UIAlertView alloc] initWithTitle:@"No account found!"
                                    message:@"Please go to settings and link your Dropbox account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

//
// Creates a new text file with the specified title.  If the file is created
// successfully, switches to the detail view controller.
//
- (void) createNoteWithTitle:(NSString*)title {
    NSString *fileName = [NSString stringWithFormat:@"%@.txt", title];
    DBPath *path = [[DBPath root] childPath:fileName];
    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:path error:nil];
    
    if (!file) {
        [[[UIAlertView alloc] initWithTitle:@"Unable to create note!"
                                    message:@"The filename may already exist."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        [_fileInfos addObject:file.info];
        [self performSegueWithIdentifier:@"showDetail" sender:file];
    }
}

- (void) initDBAccount {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
}

- (void)loadFiles {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        NSArray *immContents = [[DBFilesystem sharedFilesystem] listFolder:[DBPath root] error:nil];
        NSMutableArray *mContents = [NSMutableArray arrayWithArray:immContents];
        //[mContents sortUsingFunction:sortFileInfos context:NULL];
        dispatch_async(dispatch_get_main_queue(), ^() {
            _fileInfos = mContents;
            [self.tableView reloadData];
        });
    });
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_fileInfos removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

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
