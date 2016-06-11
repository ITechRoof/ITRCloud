//
//  ConflictPage.h
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/11/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Page.h"

@interface ConflictPage : NSObject

@property (nonatomic, strong) NSFileVersion *version;
@property (nonatomic, strong) Page *page;

- (id)initWithFileVersion:(NSFileVersion *)version;

@end
