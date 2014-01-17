//
//  PromisesTests.m
//  PromisesTests
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Deferred.h"
#import "Promise.h"

@interface PromisesTests : XCTestCase

@end

@implementation PromisesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeferredStateResolved
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    [deferred resolve:nil];
    XCTAssertEqual(deferred.state, PromiseStateResolved, @"Deferred state is not equal to PromiseStateResolved");
    
    [deferred reject:nil];
    XCTAssertEqual(deferred.state, PromiseStateResolved, @"Deferred state is not equal to PromiseStateResolved");
}

- (void)testDeferredStateRejected
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    [deferred reject:nil];
    XCTAssertEqual(deferred.state, PromiseStateRejected, @"Deferred state is not equal to PromiseStateRejected");
    
    [deferred resolve:nil];
    XCTAssertEqual(deferred.state, PromiseStateRejected, @"Deferred state is not equal to PromiseStateRejected");
}

- (void)testResolvingDeferredBlockBefore
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    NSString *valueToResolveWith = @"Yay";
    
    [deferred addDone:^(id value) {
        NSLog(@"Done was called");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    }];
    [deferred addFail:^(NSError *error) {
        NSLog(@"Fail was called");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called");
    }];
    
    [deferred resolve:valueToResolveWith];
}

@end
