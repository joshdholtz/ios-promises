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
    if (doneBlock == nil) return self;
    if (self.state == PromiseStatePending) {
        [_doneBlocks addObject:[doneBlock copy]];
    } else {
        doneBlock(self.value);
    }
    return self;
}

- (Promise *)addFail:(failBlock)failBlock {
    if (failBlock == nil) return self;
    if (self.state == PromiseStatePending) {
        [_failBlocks addObject:[failBlock copy]];
    } else {
        failBlock(self.error);
    }
    return self;
}

- (Promise *)addAlways:(alwaysBlock)alwaysBlock {
    if (alwaysBlock == nil) return self;
    if (self.state == PromiseStatePending) {
        [_alwaysBlocks addObject:[alwaysBlock copy]];
    } else {
        alwaysBlock();
    }
    return self;
}

- (Promise *)then:(doneBlock)doneBlock fail:(failBlock)failBlock always:(alwaysBlock)alwaysBlock {
    if (self.state == PromiseStatePending) {
        if (doneBlock != nil) [_doneBlocks addObject:[doneBlock copy]];
        if (failBlock != nil) [_failBlocks addObject:[failBlock copy]];
        if (alwaysBlock != nil) [_alwaysBlocks addObject:[alwaysBlock copy]];
    } else {
        if (doneBlock != nil) doneBlock(self.value);
        if (failBlock != nil)failBlock(self.error);
        if (alwaysBlock != nil) alwaysBlock();
    }
    return self;
}

@end

@interface Deferred()

@property (nonatomic, strong) Promise *promise;

@end

@implementation Deferred

+ (Deferred *)deferred {
    return [[Deferred alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _promise = [[Promise alloc] init];
    }
    return self;
}

- (Deferred *)reject:(NSError*)error {
    if (self.state != PromiseStatePending) return self;
    
    self.error = error;
    [self setState:PromiseStateRejected];
    
    [self executeFailBlocks];
    [self executeAlwaysBlocks];
    
    return self;
}

- (Deferred *)resolve:(id)value {
    if (self.state != PromiseStatePending) return self;
    
    self.value = value;
    [self setState:PromiseStateResolved];
    
    [self executeDoneBlocks];
    [self executeAlwaysBlocks];
    
    return self;
}

- (Promise *)promise {
    return _promise;
}

#pragma mark - Block execution

- (void)executeDoneBlocks {
    for (doneBlock block in _promise.doneBlocks) {
        block(self.value);
    }
}

- (void)executeFailBlocks {
    for (failBlock block in _promise.failBlocks) {
        block(self.error);
    }
}

- (void)executeAlwaysBlocks {
    for (alwaysBlock block in _promise.alwaysBlocks) {
        block();
    }
}

#pragma mark - Override Promise

- (PromiseState)state {
    return _promise.state;
}

- (void)setState:(PromiseState)state {
    [_promise setState:state];
}

- (id)value {
    return _promise.value;
}

- (void)setValue:(id)value {
    [_promise setValue:value];
}

- (NSError *)error {
    return _promise.error;
}

- (void)setError:(NSError *)error {
    [_promise setError:error];
}

- (Promise *)addDone:(doneBlock)doneBlock {
    [_promise addDone:doneBlock];
    return self;
}

- (Promise *)addFail:(failBlock)failBlock {
    [_promise addFail:failBlock];
    return self;
}

- (Promise *)addAlways:(alwaysBlock)alwaysBlock {
    [_promise addAlways:alwaysBlock];
    return self;
}

- (Promise *)then:(doneBlock)doneBlock fail:(failBlock)failBlock always:(alwaysBlock)alwaysBlock {
    [_promise then:doneBlock fail:failBlock always:alwaysBlock];
    return self;
}

@end
