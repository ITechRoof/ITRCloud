//
//  Page.h
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/6/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Page : NSObject

@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) NSString *pageContent;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@end
