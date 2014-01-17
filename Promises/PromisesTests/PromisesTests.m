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

- (void)testDeferredResolved
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, DeferredStatePending, @"Deferred state is not equal to DeferredStatePending");
    
    [deferred resolve:nil];
    XCTAssertEqual(deferred.state, DeferredStateResolved, @"Deferred state is not equal to DeferredStateResolved");
    
    [deferred reject:nil];
    XCTAssertEqual(deferred.state, DeferredStateResolved, @"Deferred state is not equal to DeferredStateResolved");
}

- (void)testDeferredRejected
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, DeferredStatePending, @"Deferred state is not equal to DeferredStatePending");
    
    [deferred reject:nil];
    XCTAssertEqual(deferred.state, DeferredStateRejected, @"Deferred state is not equal to DeferredStateRejected");
    
    [deferred resolve:nil];
    XCTAssertEqual(deferred.state, DeferredStateRejected, @"Deferred state is not equal to DeferredStateRejected");
}

@end
