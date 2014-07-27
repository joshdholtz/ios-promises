//
//  PromiseTests.m
//  Promises
//
//  Created by Graham Mueller on 7/27/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Promise.h"

@interface StubObject : NSObject

@property (assign, nonatomic) BOOL doneCalled;
@property (assign, nonatomic) BOOL failCalled;
@property (assign, nonatomic) BOOL alwaysCalled;

@end

@implementation StubObject

- (void)callAlways {
    // Since we can't call the setter directly, like we can for done and fail, we have
    // to add a method that takes no params and manually set alwaysCalled to true.
    self.alwaysCalled = YES;
}

@end

@interface PromiseTests : XCTestCase

@end

@implementation PromiseTests

- (void)testAddDoneOnObject {
    Deferred *deferred = [Deferred deferred];
    StubObject *stubObject = [[StubObject alloc] init];
    
    [deferred addDoneSelector:@selector(setDoneCalled:) onObject:stubObject];
    
    [deferred resolveWith:@YES];
    
    XCTAssertTrue(stubObject.doneCalled);
    XCTAssertFalse(stubObject.failCalled);
    XCTAssertFalse(stubObject.alwaysCalled);
}

- (void)testAddFailOnObject {
    Deferred *deferred = [Deferred deferred];
    StubObject *stubObject = [[StubObject alloc] init];
    
    [deferred addFailSelector:@selector(setFailCalled:) onObject:stubObject];
    
    [deferred rejectWith:@YES];
    
    XCTAssertFalse(stubObject.doneCalled);
    XCTAssertTrue(stubObject.failCalled);
    XCTAssertFalse(stubObject.alwaysCalled);
}

- (void)testAddAlwaysOnObject {
    Deferred *deferred1 = [Deferred deferred];
    Deferred *deferred2 = [Deferred deferred];
    StubObject *stubObject1 = [[StubObject alloc] init];
    StubObject *stubObject2 = [[StubObject alloc] init];
    
    [deferred1 addAlwaysSelector:@selector(callAlways) onObject:stubObject1];
    [deferred2 addAlwaysSelector:@selector(callAlways) onObject:stubObject2];
    
    [deferred1 rejectWith:nil];
    [deferred2 rejectWith:nil];
    
    XCTAssertFalse(stubObject1.doneCalled);
    XCTAssertFalse(stubObject1.failCalled);
    XCTAssertTrue(stubObject1.alwaysCalled);
    XCTAssertFalse(stubObject2.doneCalled);
    XCTAssertFalse(stubObject2.failCalled);
    XCTAssertTrue(stubObject2.alwaysCalled);
}

@end
