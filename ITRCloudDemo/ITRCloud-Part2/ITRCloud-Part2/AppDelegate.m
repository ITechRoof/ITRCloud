//
//  AppDelegate.m
//  ITRCloud-Part2
//
//  Created by kiruthika selvavinayagam on 4/4/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import <CloudKit/CloudKit.h>
#import "MasterViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@property MasterViewController *masterController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.masterController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MasterViewController"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.masterController];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
   
    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    NSString *alertBody = cloudKitNotification.alertLocalizationKey;
    NSLog(@"Message %@",alertBody);
    
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID];
        
        if([(CKQueryNotification *)cloudKitNotification queryNotificationReason] == CKQueryNotificationReasonRecordCreated) {
            
            [self.masterController addRecordToLocalWithID:recordID];
        }else if([(CKQueryNotification *)cloudKitNotification queryNotificationReason] == CKQueryNotificationReasonRecordUpdated) {
            
            [self.masterController addRecordToLocalWithID:recordID];
        }else if([(CKQueryNotification *)cloudKitNotification queryNotificationReason] == CKQueryNotificationReasonRecordDeleted) {
            
            [self.masterController removeRecordFromLocalWithID:recordID];
        }
    }

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
   // [self subscribe];
}

- (void)subscribe {
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.publicCloudDatabase;
    NSPredicate *predicate =[NSPredicate predicateWithValue:YES];
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"UPDATE_SUBSCRIPTION"]) {
        
        CKSubscription *updateSubscription = [[CKSubscription alloc] initWithRecordType:@"ITRNotes" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordUpdate];
        
        CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
        notificationInfo.alertLocalizationKey = @"Changes detected";
        notificationInfo.shouldBadge = YES;
        updateSubscription.notificationInfo = notificationInfo;
        
        [database saveSubscription:updateSubscription
                 completionHandler:^(CKSubscription *subscription, NSError *error) {
                     if(!error) {
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UPDATE_SUBSCRIPTION"];
                     }
                 }];
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"CREATE_SUBSCRIPTION"]) {
        
        CKSubscription *createSubscription = [[CKSubscription alloc] initWithRecordType:@"ITRNotes" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
        
        CKNotificationInfo *createNotificationInfo = [CKNotificationInfo new];
        createNotificationInfo.alertLocalizationKey = @"New record found";
        createNotificationInfo.shouldBadge = YES;
        createSubscription.notificationInfo = createNotificationInfo;
        
        [database saveSubscription:createSubscription
                 completionHandler:^(CKSubscription *subscription, NSError *error) {
                     if(!error) {
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CREATE_SUBSCRIPTION"];
                     }
                 }];
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"DELETE_SUBSCRIPTION"]) {
        
        CKSubscription *deleteSubscription = [[CKSubscription alloc] initWithRecordType:@"ITRNotes" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordDeletion];
        
        CKNotificationInfo *deleteNotificationInfo = [CKNotificationInfo new];
        deleteNotificationInfo.alertLocalizationKey = @"One record deleted";
        deleteNotificationInfo.shouldBadge = YES;
        deleteSubscription.notificationInfo = deleteNotificationInfo;
        
        [database saveSubscription:deleteSubscription
                 completionHandler:^(CKSubscription *subscription, NSError *error) {
                     if(!error) {
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DELETE_SUBSCRIPTION"];
                     }
                 }];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
