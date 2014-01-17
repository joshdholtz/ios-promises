//
//  Deferred.m
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "Deferred.h"

@interface Deferred()

@property (nonatomic, assign) PromiseState state;

@property (nonatomic, assign) id value;
@property (nonatomic, strong) NSError *error;

@end

@implementation Deferred

@dynamic state;

+ (Deferred *)deferred {
    return [[Deferred alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (Deferred *)reject:(NSError*)error {
    if (self.state != PromiseStatePending) return self;
    
    _error = error;
    [self setState:PromiseStateRejected];
    return self;
}

- (Deferred *)resolve:(id)value {
    if (self.state != PromiseStatePending) return self;
    
    _value = value;
    [self setState:PromiseStateResolved];
    return self;
}

- (Promise *)promise {
    return self;
}

@end
