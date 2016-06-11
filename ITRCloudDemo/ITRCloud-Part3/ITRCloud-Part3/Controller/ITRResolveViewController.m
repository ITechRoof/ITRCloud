//
//  ITRResolveViewController.m
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/11/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "ITRResolveViewController.h"
#import "PageDocument.h"
#import "ConflictPage.h"

@interface ITRPageConflictCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *pageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageUpdatedLabel;

@end

@implementation ITRPageConflictCell

@end

@interface ITRResolveViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *versionEntries;

@end

@implementation ITRResolveViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self fetchAllVersion];
}

- (void)fetchAllVersion {
    
    self.versionEntries = [NSMutableArray array];
    NSMutableArray * fileVersions = [NSMutableArray array];
    
    NSFileVersion * currentVersion = [NSFileVersion currentVersionOfItemAtURL:self.documentURL];
    [fileVersions addObject:currentVersion];
    
    NSArray * otherVersions = [NSFileVersion otherVersionsOfItemAtURL:self.documentURL];
    [fileVersions addObjectsFromArray:otherVersions];
    
    for (NSFileVersion * fileVersion in fileVersions) {
        
        ConflictPage *versionEntry = [[ConflictPage alloc] initWithFileVersion:fileVersion];
        [self.versionEntries addObject:versionEntry];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.versionEntries.count-1 inSection:0];

        PageDocument *doc = [[PageDocument alloc] initWithFileURL:fileVersion.URL];
        
        [doc openWithCompletionHandler:^(BOOL success) {
            
            if(success) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    versionEntry.page = doc.page;
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
    }
    
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ITRPageConflictCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ITRPageConflictCell" forIndexPath:indexPath];
    
    ConflictPage *conflictPage = ((ConflictPage *)self.versionEntries[indexPath.row]);
    
    cell.pageTitleLabel.text = conflictPage.page.pageTitle;
    cell.pageContentLabel.text = conflictPage.page.pageContent;
    cell.pageUpdatedLabel.text = [NSDateFormatter localizedStringFromDate:conflictPage.page.updatedAt
                                                                dateStyle:NSDateFormatterShortStyle
                                                                timeStyle:NSDateFormatterShortStyle];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.versionEntries.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ConflictPage * conflictPage = [self.versionEntries objectAtIndex:indexPath.row];
    
    if (![conflictPage.version isEqual:[NSFileVersion currentVersionOfItemAtURL:self.documentURL]]) {
        [conflictPage.version replaceItemAtURL:self.documentURL options:0 error:nil];
    }
    [NSFileVersion removeOtherVersionsOfItemAtURL:self.documentURL error:nil];
    NSArray* conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:self.documentURL];
    for (NSFileVersion* fileVersion in conflictVersions) {
        fileVersion.resolved = YES;
    }

    if(self.complete) {
        self.complete(YES);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
