//
//  ITRViewController.m
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/1/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "ITRViewController.h"
#import "ITRDetailViewController.h"
#import "PageDocument.h"
#import "ITRResolveViewController.h"

typedef NS_ENUM(NSInteger, ITRCloudOperation) {
    ITRCloudOperationSave = 0,
    ITRCloudOperationUpdate,
    ITRCloudOperationDelete,
    ITRCloudOperationLoad
};


@interface ITRPageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *pageTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *conflictButton;

@end

@implementation ITRPageCell

@end

@interface ITRViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *pagesArray;
@property NSMetadataQuery *query;

@end

@implementation ITRViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.pagesArray = [NSMutableArray array];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadAllPage];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ITRPageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ITRPageCell" forIndexPath:indexPath];
   
    PageDocument *doc = ((PageDocument *)self.pagesArray[indexPath.row]);
    cell.pageTitleLabel.text = doc.page.pageTitle;
    
    cell.conflictButton.hidden = (doc.documentState != UIDocumentStateInConflict);
    cell.conflictButton.tag = indexPath.row;
    [cell.conflictButton addTarget:self action:@selector(resolveConflict:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pagesArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ITRDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ITRDetailViewController"];
    detailViewController.page = ((PageDocument *)self.pagesArray[indexPath.row]).page;
    detailViewController.complete = ^(Page *page) {
        
        PageDocument *doc = [[PageDocument alloc] initWithFileURL:((PageDocument *)self.pagesArray[indexPath.row]).fileURL];
        doc.page = page;
        
        [self performOperation:ITRCloudOperationUpdate ForPage:page];
        
        [self.pagesArray removeObjectAtIndex:indexPath.row];
        [self.pagesArray insertObject:doc atIndex:0];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self performOperation:ITRCloudOperationDelete ForPage:((PageDocument *)self.pagesArray[indexPath.row]).page];
        [self.pagesArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)resolveConflict:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    ITRResolveViewController *resolveViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ITRResolveViewController"];
    
    PageDocument *doc = ((PageDocument *)self.pagesArray[button.tag]);
    resolveViewController.documentURL = doc.fileURL;

    resolveViewController.complete = ^(BOOL success) {
        
        if(success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    };
    
    [self.navigationController pushViewController:resolveViewController animated:YES];
}

- (IBAction)addNewPage:(id)sender {
   
    ITRDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ITRDetailViewController"];
    detailViewController.complete = ^(Page *page) {

        PageDocument *doc = [[PageDocument alloc] initWithFileURL:[self urlForPage:page]];
        doc.page = page;
        
        [self.pagesArray insertObject:doc atIndex:0];
        [self.tableView reloadData];
        
        [self performOperation:ITRCloudOperationSave ForPage:page];

    };
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)loadAllPage {
    
    [self performOperation:ITRCloudOperationLoad ForPage:nil];
}

- (void)updateDataWithNotification:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [self.pagesArray removeAllObjects];
    
    if(query.resultCount > 0) {

        [query.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURL *documentURL = [(NSMetadataItem *)obj valueForAttribute:NSMetadataItemURLKey];
            PageDocument *doc = [[PageDocument alloc] initWithFileURL:documentURL];
            
            [doc openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [self.pagesArray addObject:doc];
                }
                
                if(self.pagesArray.count == query.resultCount) {
                    
                    self.pagesArray = [[NSMutableArray alloc] initWithArray:[self.pagesArray sortedArrayUsingComparator:
                                            ^NSComparisonResult(PageDocument *page1, PageDocument *page2){
                                                return [page2.page.updatedAt compare:page1.page.updatedAt];
                                            }]];
                    [self.tableView reloadData];
                }
                
            }]; 
        }];
    }
}

- (void)performOperation:(ITRCloudOperation)operation ForPage:(Page *)page {
    
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if([self isICloudOn]) {
        
        if(!baseURL) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to access iCloud Account" message:@"Open the Settings app and enter your Apple ID into iCloud settings" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            
            [self.navigationController presentViewController:alert animated:YES completion:nil];
            
        }else {
            switch(operation) {
                case ITRCloudOperationLoad :
                {
                    self.query = [[NSMetadataQuery alloc] init];
                    [self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like '*'", NSMetadataItemFSNameKey];
                    [self.query setPredicate:predicate];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataWithNotification:) name:NSMetadataQueryDidFinishGatheringNotification object:self.query];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataWithNotification:) name:NSMetadataQueryDidUpdateNotification object:self.query];
                    
                    [self.query enableUpdates];
                    [self.query startQuery];
                }
                    break;
                case ITRCloudOperationSave:
                {
                    PageDocument *doc = [[PageDocument alloc] initWithFileURL:[self urlForPage:page]];
                    doc.page = page;
                    
                    [doc saveToURL:doc.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                        if(success) {
                            NSLog(@"Saved");
                        }
                    }];
                    
                }
                    break;
                case ITRCloudOperationUpdate:
                {
                    PageDocument *doc = [[PageDocument alloc] initWithFileURL:[self urlForPage:page]];
                    doc.page = page;
                    
                    [doc saveToURL:[self urlForPage:page] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                        if(success) {
                            NSLog(@"Updated");
                        }
                    }];
                }
                    break;
                case ITRCloudOperationDelete:
                {
                    NSError *error;
                    if(![[NSFileManager defaultManager] removeItemAtURL:[self urlForPage:page] error:&error]) {
                        NSLog(@"%@",error.localizedDescription);
                    }else {
                        NSLog(@"Deleted");
                    }
                }
                    break;
                default:
                    break;
            }
        }
        
    }else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iCloud turned off" message:@"Open the Settings app and turn on iCloud" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            });
        }];
        [alert addAction:action];
        
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
    }
}

- (NSURL *)urlForPage:(Page *)page {
    
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *documentURL = [baseURL URLByAppendingPathComponent:@"Documents"];
    NSURL *pageURL = [documentURL URLByAppendingPathComponent:[NSString stringWithFormat:@"iCloud_Demo_Page_%.0f",page.createdAt.timeIntervalSinceReferenceDate]];
    return pageURL;
}

- (BOOL) isICloudOn {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudOn"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"];
    }else {
        return YES;
    }
}

@end
