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

- (void)executeDoneBlocks {
    for (doneBlock block in self.doneBlocks) {
        block(self.value);
    }
}

- (void)executeFailBlocks {
    for (failBlock block in self.failBlocks) {
        block(self.error);
    }
}

- (void)executeAlwaysBlocks {
    for (alwaysBlock block in self.alwaysBlocks) {
        block();
    }
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

- (void)executeDoneBlocks {
    [_promise executeDoneBlocks];
}

- (void)executeFailBlocks {
    [_promise executeFailBlocks];
}

- (void)executeAlwaysBlocks {
    [_promise executeAlwaysBlocks];
}

@end

@interface When()

@property (nonatomic, strong) NSArray *promises;
@property (nonatomic, assign) BOOL failed;
@property (nonatomic, assign) BOOL won;

@end

@implementation When

+ (When *)when:(NSArray *)promises then:(doneBlock)doneBlock fail:(failBlock)failBlock always:(alwaysBlock)alwaysBlock {
    When *when = [[When alloc] init];
    [when then:doneBlock fail:failBlock always:alwaysBlock];
    [when setPromises:promises];
    return when;
}

- (id)init {
    self = [super init];
    if (self) {
        self.failed = NO;
        self.won = NO;
    }
    return self;
}

- (void)setPromises:(NSArray *)promises {
    _promises = promises;
    
    // Check fail and win before
    if ([self fail]) return;
    if ([self win]) return;
    
    // If haven't failed or won yet, add check to each promise
    for (Promise *promise in promises) {
        [promise addFail:^(NSError *error) {
            [self fail];
        }];
        [promise addAlways:^{
            [self win];
        }];
    }
    
    // And again incase weird timing issues of things maybe?
    if ([self fail]) return;
    if ([self win]) return;
    
}

- (BOOL)fail {
    @synchronized(self) {
        if (self.failed == YES || self.won == YES) return NO;
        
        for (Promise *promise in _promises) {
            if (promise.state == PromiseStateRejected) {
                
                self.failed = YES;
                [self executeFailBlocks];
                [self executeAlwaysBlocks];
                
                return YES;
            }
        }
        
        return NO;
    }
}

- (BOOL)win {
    @synchronized(self) {
        if (self.failed == YES || self.won == YES) return NO;
        
        for (Promise *promise in _promises) {
            if (promise.state != PromiseStateResolved) {
                return NO;
            }
        }
        
        self.won = YES;
        [self executeDoneBlocks];
        [self executeAlwaysBlocks];
        
        return YES;
    }
}

@end