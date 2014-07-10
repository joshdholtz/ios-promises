//
//  Promise.m
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "Promise.h"

#pragma mark - Promise

@interface Promise()

@property (nonatomic, assign) PromiseState state;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) id error;

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

/*
 * Adds done block to array to execute when resolved
 * If already resolved, block gets executed
 */
- (Promise *)addDone:(doneBlock)doneBlock {
    if (doneBlock == nil) return self;
    if (self.state == PromiseStatePending) {
        [_doneBlocks addObject:[doneBlock copy]];
    } else if (self.state == PromiseStateResolved) {
        doneBlock(self.value);
    }
    return self;
}

/*
 * Adds done block to array to execute when rejected
 * If already rejected, block gets executed
 */
- (Promise *)addFail:(failBlock)failBlock {
    if (failBlock == nil) return self;
    if (self.state == PromiseStatePending) {
        [_failBlocks addObject:[failBlock copy]];
    } else if (self.state == PromiseStateRejected) {
        failBlock(self.error);
    }
    return self;
}

/*
 * Adds done block to array to execute when no longer pending
 * If no longer pending, block gets executed
 */
- (Promise *)addAlways:(alwaysBlock)alwaysBlock {
    if (alwaysBlock == nil) return self;
    if (self.state == PromiseStatePending) {
        [_alwaysBlocks addObject:[alwaysBlock copy]];
    } else {
        alwaysBlock();
    }
    return self;
}

/*
 * Adds done, fail, and always block to arrays to execute when no longer pending
 * If no longer pending, block gets executed (if in correct state)
 */
- (Promise *)then:(doneBlock)doneBlock fail:(failBlock)failBlock always:(alwaysBlock)alwaysBlock {
    if (self.state == PromiseStatePending) {
        if (doneBlock != nil) [_doneBlocks addObject:[doneBlock copy]];
        if (failBlock != nil) [_failBlocks addObject:[failBlock copy]];
        if (alwaysBlock != nil) [_alwaysBlocks addObject:[alwaysBlock copy]];
    } else {
        if (self.state == PromiseStateResolved) {
            if (doneBlock != nil) doneBlock(self.value);
        } else if (self.state == PromiseStateRejected) {
            if (failBlock != nil)failBlock(self.error);
        }
        if (alwaysBlock != nil) alwaysBlock();
    }
    return self;
}

/*
 * Executes all done blocks
 */
- (void)executeDoneBlocks {
    for (doneBlock block in self.doneBlocks) {
        block(self.value);
    }
}

/*
 * Executes all fail blocks
 */
- (void)executeFailBlocks {
    for (failBlock block in self.failBlocks) {
        block(self.error);
    }
}

/*
 * Executes all always blocks
 */
- (void)executeAlwaysBlocks {
    for (alwaysBlock block in self.alwaysBlocks) {
        block();
    }
}

@end

#pragma mark - Deferred

@interface Deferred()

// Retains internal promise object
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

- (Deferred *)reject {
    return [self rejectWith:nil];
}

- (Deferred *)resolve {
    return [self resolveWith:nil];
}

/*
 * Rejects deferred if in pending sate and executes all fail and always blocks
 */
- (Deferred *)rejectWith:(id)error {
    if (self.state != PromiseStatePending) return self;
    
    self.error = error;
    [self setState:PromiseStateRejected];
    
    [self executeFailBlocks];
    [self executeAlwaysBlocks];
    
    return self;
}

/*
 * Resolves deferred if in pending sate and executes all done and always blocks
 */
- (Deferred *)resolveWith:(id)value {
    if (self.state != PromiseStatePending) return self;
    
    self.value = value;
    [self setState:PromiseStateResolved];
    
    [self executeDoneBlocks];
    [self executeAlwaysBlocks];
    
    return self;
}

/*
 * Returns a promise object
 * This can be used to there is access to this object without having
 * ability to change state
 */
- (Promise *)promise {
    return _promise;
}

#pragma mark - Override Promise

/*
 * Override all the promise methods
 * Alls methods on retained promise object
 */

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

- (id)error {
    return _promise.error;
}

- (void)setError:(id)error {
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

#pragma mark - When

@interface When()

@property (nonatomic, strong) NSArray *promises;
@property (nonatomic, assign) BOOL failed;
@property (nonatomic, assign) BOOL won;
@property (nonatomic, assign) BOOL always;

@property (readwrite, copy) whenBlock when;

@end

@implementation When

/*
 * Creates a when object with promises and the then blocks
 */
+ (When *)when:(NSArray *)promises then:(whenBlock)whenBlock fail:(failBlock)failBlock always:(alwaysBlock)alwaysBlock {
    When *when = [[When alloc] init];
    
    // Sets then blocks (wraps the when block in the done block)
    when.when = whenBlock;
    [when then:^(id value) {
        when.when();
    } fail:failBlock always:alwaysBlock];
    
    // Sets promises
    [when setPromises:promises];
    
    return when;
}

- (id)init {
    self = [super init];
    if (self) {
        self.failed = NO;
        self.won = NO;
        self.always = NO;
    }
    return self;
}

/*
 * Sets promises and adds a fail and always promise for chaining purposes
 */
- (void)setPromises:(NSArray *)promises {
    _promises = promises;

    
    // If haven't failed or won yet, add check to each promise
    for (Promise *promise in promises) {
        [promise addFail:^(id error) {
            [self doFail];
        }];
        [promise addAlways:^{
            [self doWin];
            [self doAlways];
        }];
    }
    
    // Checking incase things finished before we added thise promises
    [self doFail];
    [self doWin];
    [self doAlways];
    
}

/*
 * Executes fail block if one promise is rejected and if failed on this when promise
 * hasn't been called yet
 */
- (BOOL)doFail {
    @synchronized(self) {
        if (self.failed == YES || self.won == YES) return NO;
        
        for (Promise *promise in _promises) {
            if (promise.state == PromiseStateRejected) {
                
                self.failed = YES;
                self.error = promise.error;
                [self executeFailBlocks];
                
                return YES;
            }
        }
        
        return NO;
    }
}

/*
 * Executes done block if all promises are resolved and if done on this when promise
 * hasn't been called yet
 */
- (BOOL)doWin {
    @synchronized(self) {
        if (self.failed == YES || self.won == YES) return NO;
        
        for (Promise *promise in _promises) {
            if (promise.state != PromiseStateResolved) {
                return NO;
            }
        }
        
        self.won = YES;
        [self executeDoneBlocks];
        
        return YES;
    }
}

/*
 * Executes always block if all promises are not pending and if always on this when promise
 * hasn't been called yet
 */
- (BOOL)doAlways {
    @synchronized(self) {
        if (self.always) return NO;
        
        for (Promise *promise in _promises) {
            if (promise.state == PromiseStatePending) {
                return NO;
            }
        }
        
        self.always = YES;
        [self executeAlwaysBlocks];
        
        return YES;
    }
}

@end
