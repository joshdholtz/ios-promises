//
//  Promise.m
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "Promise.h"

@interface Promise()

@property (nonatomic, assign) PromiseState state;
@property (nonatomic, assign) id value;
@property (nonatomic, strong) NSError *error;

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
    if (self.state == PromiseStatePending) {
        [_doneBlocks addObject:[doneBlock copy]];
    } else {
        doneBlock(self.value);
    }
    return self;
}

- (Promise *)addFail:(failBlock)failBlock {
    if (self.state == PromiseStatePending) {
        [_failBlocks addObject:[failBlock copy]];
    } else {
        failBlock(self.error);
    }
    return self;
}

- (Promise *)addAlways:(alwaysBlock)alwaysBlock {
    if (self.state == PromiseStatePending) {
        [_alwaysBlocks addObject:[alwaysBlock copy]];
    } else {
        alwaysBlock();
    }
    return self;
}

@end
