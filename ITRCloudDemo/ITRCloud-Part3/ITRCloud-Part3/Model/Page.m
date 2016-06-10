//
//  Page.m
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/6/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "Page.h"

#define kPageTitle @"Page Title"
#define kPageContent  @"Page Content"
#define kPageCreatedAt @"Page Created At"
#define kPageUpdatedAt  @"Page Updated At"

@implementation Page

#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.pageTitle forKey:kPageTitle];
    [coder encodeObject:self.pageContent forKey:kPageContent];
    [coder encodeObject:self.createdAt forKey:kPageCreatedAt];
    [coder encodeObject:self.updatedAt forKey:kPageUpdatedAt];
}

- (id)initWithCoder:(NSCoder *)coder  {
    self = [super init];
    
    if (self != nil) {
        self.pageTitle = [coder decodeObjectForKey:kPageTitle];
        self.pageContent = [coder decodeObjectForKey:kPageContent];
        self.createdAt = [coder decodeObjectForKey:kPageCreatedAt];
        self.updatedAt = [coder decodeObjectForKey:kPageUpdatedAt];
    }
    
    return self;
}

@end
