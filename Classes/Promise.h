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
typedef void (^failBlock)(NSError *error);
typedef void (^alwaysBlock)();

#import <Foundation/Foundation.h>

@interface Promise : NSObject

- (PromiseState)state;
- (Promise*)addDone:(doneBlock)doneBlock;
- (Promise*)addFail:(failBlock)failBlock;
- (Promise*)addAlways:(alwaysBlock)alwaysBlock;

@end
