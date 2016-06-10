//
//  ITRDetailViewController.m
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/6/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "ITRDetailViewController.h"

@interface ITRDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleView;
@property (weak, nonatomic) IBOutlet UITextView *contentView;

@end

@implementation ITRDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.titleView.text = self.page.pageTitle;
    self.contentView.text = self.page.pageContent;
}

- (IBAction)saveClicked:(id)sender {
    
    if(self.titleView.text.length > 0 && self.contentView.text.length > 0) {
       
        if(self.complete) {
            
            Page *page = [[Page alloc] init];
            page.pageTitle = self.titleView.text;
            page.pageContent = self.contentView.text;
            page.updatedAt = [NSDate date];
            page.createdAt = self.page.createdAt;
            if(!page.createdAt) {
                page.createdAt = [NSDate date];
            }

            self.complete(page);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"OOPS" message:@"Please enter title & content of the page" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
