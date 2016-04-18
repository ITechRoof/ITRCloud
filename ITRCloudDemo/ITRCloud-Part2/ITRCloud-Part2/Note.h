//
//  Note.h
//  ITRCloud-Part2
//
//  Created by kiruthika selvavinayagam on 4/13/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property (strong, nonatomic) NSDate *createdDate;
@property (strong, nonatomic) NSString *noteText;
@property (strong, nonatomic) NSURL *imageURL;
@property (assign, nonatomic) BOOL isNew;

@end
