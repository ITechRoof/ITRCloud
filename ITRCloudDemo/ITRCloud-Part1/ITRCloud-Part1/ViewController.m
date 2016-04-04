//
//  ViewController.m
//  ITRCloud-Part1
//
//  Created by kiruthika selvavinayagam on 3/30/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIButton *centerButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Observer to catch changes from iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:store];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];

}

#pragma mark - action method
- (IBAction)changeBackgroundClicked:(id)sender {
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Black" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self backgroundColorChangedWithColor:[UIColor blackColor] Title:@"Black"];
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Gray" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self backgroundColorChangedWithColor:[UIColor grayColor] Title:@"Gray"];

    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Purple" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self backgroundColorChangedWithColor:[UIColor purpleColor] Title:@"Purple"];
        
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)storeDidChange:(id)sender {
    
    // Retrieve the changes from iCloud
    NSData *data = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"BACKGROUND"] mutableCopy];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.view setBackgroundColor:color];
    
    NSString *title = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"TITLE"] mutableCopy];
    [self.centerButton setTitle:title forState:UIControlStateNormal];

}

- (void)backgroundColorChangedWithColor:(UIColor *)color Title:(NSString *)title {
    
    [self.view setBackgroundColor:color];
    [self.centerButton setTitle:title forState:UIControlStateNormal];
    
    // Update data on the iCloud
    [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"BACKGROUND"];
    [[NSUbiquitousKeyValueStore defaultStore] setString:title forKey:@"TITLE"];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
}

@end
