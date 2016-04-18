//
//  MasterViewController.h
//  ITRCloud-Part2
//
//  Created by kiruthika selvavinayagam on 4/4/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

- (void)addRecordToLocalWithID:(CKRecordID *)recordID;
- (void)removeRecordFromLocalWithID:(CKRecordID *)recordID;

@end

