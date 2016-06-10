//
//  ITRDetailViewController.h
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/6/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Page.h"

@interface ITRDetailViewController : UIViewController

@property (strong, nonatomic) void (^complete)(Page *page);
@property (nonatomic, weak) Page *page;
@property (weak, nonatomic) id delegate;

@end
