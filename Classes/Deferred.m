//
//  Deferred.m
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "Deferred.h"

@interface Deferred()

@property (nonatomic, strong) Promise *promise;


// Dynamic properties
@property (nonatomic, assign) PromiseState state;
@property (nonatomic, assign) id value;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSMutableArray *doneBlocks;
@property (nonatomic, strong) NSMutableArray *failBlocks;
@property (nonatomic, strong) NSMutableArray *alwaysBlocks;


@end

@implementation Deferred

@dynamic state;
@dynamic value;
@dynamic error;

@dynamic doneBlocks;
@dynamic failBlocks;
@dynamic alwaysBlocks;

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

#pragma mark - Override Promise

//- (Promise *)addDone:(doneBlock)doneBlock {
//    return [_promise addDone:doneBlock];
//}
//
//- (Promise *)addFail:(failBlock)failBlock {
//    return [_promise addFail:failBlock];
//}
//
//- (Promise *)addAlways:(alwaysBlock)alwaysBlock {
//    return [_promise addAlways:alwaysBlock];
//}

@end
