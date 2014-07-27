//
//  Promise.h
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

typedef enum {
    PromiseStatePending, PromiseStateResolved, PromiseStateRejected
} PromiseState;

typedef void (^doneBlock)(id value);
typedef void (^failBlock)(id error);
typedef void (^alwaysBlock)();
typedef void (^whenBlock)();

#import <Foundation/Foundation.h>

// Promise
@interface Promise : NSObject

- (PromiseState)state;
- (Promise*)addDone:(doneBlock)doneBlock;
- (Promise*)addDoneSelector:(SEL)selector onObject:(id)object;

- (Promise*)addFail:(failBlock)failBlock;
- (Promise*)addFailSelector:(SEL)selector onObject:(id)object;

- (Promise*)addAlways:(alwaysBlock)alwaysBlock;
- (Promise*)addAlwaysSelector:(SEL)selector onObject:(id)object;

- (Promise*)then:(doneBlock)doneBlock fail:(failBlock)failBlock always:(alwaysBlock)alwaysBlock;

@end

// Deferred
@interface Deferred : Promise

+ (Deferred*)deferred;
- (Deferred*)resolve;
- (Deferred*)reject;
- (Deferred*)resolveWith:(id)value;
- (Deferred*)rejectWith:(id)error;
- (Promise*)promise;

@end

// When
@interface When : Promise

+ (When*)when:(NSArray*)promises then:(whenBlock)whenBlock fail:(failBlock)failBlock always:(alwaysBlock)alwaysBlock;

@end