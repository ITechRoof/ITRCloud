//
//  DetailViewController.h
//  ITRCloud-Part2
//
//  Created by kiruthika selvavinayagam on 4/4/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface DetailViewController : UIViewController

@property (nonatomic) void (^completionBlock)(Note *);
@property (nonatomic, strong) Note *selectedNote;

@end

