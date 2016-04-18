//
//  MasterViewController.m
//  ITRCloud-Part2
//
//  Created by kiruthika selvavinayagam on 4/4/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Note.h"

@interface MasterViewController ()

@property NSMutableArray *notes;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.notes = [[NSMutableArray alloc] init];
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)fetchData {
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.publicCloudDatabase;
    NSPredicate *predicate =[NSPredicate predicateWithValue:YES];

    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"ITRNotes" predicate:predicate];
    
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        
        if(results.count > 0) {
            
            for (CKRecord *record in results) {
                
                Note *note = [[Note alloc] init];
                note.createdDate = [record objectForKey:@"TITLE"];
                note.noteText = [record objectForKey:@"TEXT"];
                CKAsset *asset = [record objectForKey:@"IMAGE"];
                note.imageURL = asset.fileURL;
                note.isNew = NO;
                
                [self.notes addObject:note];
            }
            
            [self.tableView reloadData];
        }
    }];
    
}

- (void)insertNewObject:(id)sender {
   
    if (!self.notes) {
        self.notes = [[NSMutableArray alloc] init];
    }
    
    Note *newNote = [[Note alloc] init];
    newNote.createdDate = [NSDate date];
    newNote.isNew = YES;
    [self.notes insertObject:newNote atIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self openDetailViewControllerAtIndex:indexPath.row];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Note *note = self.notes[indexPath.row];
    cell.textLabel.text = [note.createdDate description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openDetailViewControllerAtIndex:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:((Note *)self.notes[indexPath.row]).createdDate.description];
        CKContainer *container = [CKContainer defaultContainer];
        CKDatabase *database = container.publicCloudDatabase;
        
        [database deleteRecordWithID:recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
            if(!error) {
                NSLog(@"Deleted");
            }
        }];
        
        [self.notes removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)openDetailViewControllerAtIndex:(NSInteger)index {
   
    DetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.selectedNote = self.notes[index];
    
    __weak DetailViewController *weakDetail = detailViewController;
    detailViewController.completionBlock = ^(Note *updatedNote){
        
        [self.notes replaceObjectAtIndex:index withObject:updatedNote];
        [weakDetail.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:detailViewController animated:YES];

}

#pragma CRUD
- (void)removeRecordFromLocalWithID:(CKRecordID *)recordID {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [activityIndicator startAnimating];
    activityIndicator.color = [UIColor grayColor];
    
    UIBarButtonItem *loaderView = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.leftBarButtonItem = loaderView;
    self.navigationItem.title = @"Updating";
    [self.navigationController.navigationBar setNeedsLayout];
    
    NSInteger row = -1;
    NSInteger index = 0;
    for (Note *note in self.notes) {
        if([recordID.recordName isEqualToString:note.createdDate.description]) {
            row = index;
            break;
        }
        index++;
    }
    
    if(row != -1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        [self.notes removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    self.navigationItem.title = @"Master";
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)addRecordToLocalWithID:(CKRecordID *)recordID {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [activityIndicator startAnimating];
    activityIndicator.color = [UIColor grayColor];
    
    UIBarButtonItem *loaderView = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.leftBarButtonItem = loaderView;
    self.navigationItem.title = @"Updating";
    [self.navigationController.navigationBar setNeedsLayout];
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.publicCloudDatabase;
    
    [database fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.navigationItem.leftBarButtonItem = nil;
             self.navigationItem.title = @"Master";
            
            if(record) {
                
                Note *note = [[Note alloc] init];
                note.createdDate = [record objectForKey:@"TITLE"];
                note.noteText = [record objectForKey:@"TEXT"];
                CKAsset *asset = [record objectForKey:@"IMAGE"];
                note.imageURL = asset.fileURL;
                note.isNew = NO;
                
                NSInteger row = -1;
                NSInteger index = 0;
                
                for (Note *note in self.notes) {
                    if([note.createdDate.description isEqualToString:[record objectForKey:@"TITLE"]]) {
                        row = index;
                        break;
                    }
                    index++;
                }
                
                if(row == -1)
                {
                    [self.notes insertObject:note atIndex:0];
                    
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    
                }else {
                    
                    [self.notes replaceObjectAtIndex:row withObject:note];
                }
                
            }
        });
    }];
}

@end
