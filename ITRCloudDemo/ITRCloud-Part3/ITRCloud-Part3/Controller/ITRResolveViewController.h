//
//  ITRResolveViewController.h
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/11/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITRResolveViewController : UIViewController

@property (nonatomic, strong) NSURL *documentURL;
@property (strong, nonatomic) void (^complete)(BOOL success);

@end
