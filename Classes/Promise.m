//
//  Promise.m
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "Promise.h"

@interface Promise()

@property (nonatomic, strong) NSMutableArray *doneBlocks;
@property (nonatomic, strong) NSMutableArray *failBlocks;
@property (nonatomic, strong) NSMutableArray *alwaysBlocks;

@end

@implementation Promise

- (id)init {
    self = [super init];
    if (self) {
        self.doneBlocks = [NSMutableArray array];
        self.failBlocks = [NSMutableArray array];
        self.alwaysBlocks = [NSMutableArray array];
    }
    return self;
}

- (Promise *)addDone:(doneBlock)doneBlock {
    [_doneBlocks addObject:[doneBlock copy]];
    return self;
}

- (Promise *)addFail:(failBlock)failBlock {
    [_failBlocks addObject:[failBlock copy]];
    return self;
}

- (Promise *)addAlways:(alwaysBlock)alwaysBlock {
    [_alwaysBlocks addObject:[alwaysBlock copy]];
    return self;
}

@end
