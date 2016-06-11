//
//  ConflictPage.m
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/11/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "ConflictPage.h"

@implementation ConflictPage

- (id)initWithFileVersion:(NSFileVersion *)version {
    
    if ((self = [super init])) {
        self.version = version;
    }
    return self;
}

@end
