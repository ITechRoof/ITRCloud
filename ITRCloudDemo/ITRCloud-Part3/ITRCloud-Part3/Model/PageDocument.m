//
//  PageDocument.m
//  ITRCloud-Part3
//
//  Created by kiruthika selvavinayagam on 6/6/16.
//  Copyright © 2016 kiruthika selvavinayagam. All rights reserved.
//

#import "PageDocument.h"

#define kArchiveKey @"Page"

@implementation PageDocument


- (BOOL)loadFromContents:(id)contents ofType:(nullable NSString *)typeName error:(NSError **)outError {
   
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:contents];
    self.page = [unarchiver decodeObjectForKey:kArchiveKey];
    [unarchiver finishDecoding];
  
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
   
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.page forKey:kArchiveKey];
    [archiver finishEncoding];
    
    return data;
}

@end
