//
//  Deferred.m
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "Deferred.h"

@interface Deferred()

@property (nonatomic, assign) id value;
@property (nonatomic, strong) NSError *error;

@end

@implementation Deferred

+ (Deferred *)deferred {
    return [[Deferred alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        self.state = DeferredStatePending;
    }
    return self;
}

- (Deferred *)reject:(NSError*)error {
    _error = error;
    [self setState:DeferredStateRejected];
    return self;
}

- (Deferred *)resolve:(id)value {
    _value = value;
    [self setState:DeferredStateResolved];
    return self;
}

- (void)setState:(DeferredState)state {
    // Only set state if its pending
    if (_state == DeferredStatePending) {
        _state = state;
    }
}

- (Promise *)promise {
    return self;
}

@end
