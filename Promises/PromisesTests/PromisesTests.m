//
//  PromisesTests.m
//  PromisesTests
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>

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
    
    [deferred resolveWith:nil];
    XCTAssertEqual(deferred.state, PromiseStateResolved, @"Deferred state is not equal to PromiseStateResolved");
    
    [deferred rejectWith:nil];
    XCTAssertEqual(deferred.state, PromiseStateResolved, @"Deferred state is not equal to PromiseStateResolved");
}

- (void)testDeferredStateRejected
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    [deferred rejectWith:nil];
    XCTAssertEqual(deferred.state, PromiseStateRejected, @"Deferred state is not equal to PromiseStateRejected");
    
    [deferred resolveWith:nil];
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
    [deferred addDone:^(id value) {
        NSLog(@"Done was called again");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    }];
    [deferred addDone:^(id value) {
        NSLog(@"Done was called again again");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    }];
    [deferred addFail:^(id error) {
        NSLog(@"Fail was called");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again again");
    }];
    
    [deferred resolveWith:valueToResolveWith];
}

- (void)testResolvingDeferredBlockAfter
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    NSString *valueToResolveWith = @"Yay";
    
    [deferred resolveWith:valueToResolveWith];
    
    [deferred addDone:^(id value) {
        NSLog(@"Done was called");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    }];
    [deferred addDone:^(id value) {
        NSLog(@"Done was called again");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    }];
    [deferred addDone:^(id value) {
        NSLog(@"Done was called again again");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    }];
    [deferred addFail:^(id error) {
        NSLog(@"Fail was called");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again again");
    }];
}

- (void)testRejectingDeferredBlockBefore
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    NSError *errorToRejectWith = [NSError errorWithDomain:@"Ooops!" code:0 userInfo:nil];
    
    [deferred addDone:^(id value) {
        NSLog(@"Done was called");
    }];
    [deferred addFail:^(NSError *error) {
        NSLog(@"Fail was called");
        XCTAssert([error.domain isEqualToString:errorToRejectWith.domain], @"Error domain should equal %@", errorToRejectWith.domain);
    }];
    [deferred addFail:^(NSError *error) {
        NSLog(@"Fail was called again");
        XCTAssert([error.domain isEqualToString:errorToRejectWith.domain], @"Error domain should equal %@", errorToRejectWith.domain);
    }];
    [deferred addFail:^(NSError *error) {
        NSLog(@"Fail was called again again");
        XCTAssert([error.domain isEqualToString:errorToRejectWith.domain], @"Error domain should equal %@", errorToRejectWith.domain);
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again again");
    }];
    
    [deferred rejectWith:errorToRejectWith];
}

- (void)testRejectingDeferredBlockAfter
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    NSError *errorToRejectWith = [NSError errorWithDomain:@"Ooops!" code:0 userInfo:nil];
    
    [deferred rejectWith:errorToRejectWith];
    
    [deferred addDone:^(id value) {
        NSLog(@"Done was called");
    }];
    [deferred addFail:^(NSError *error) {
        NSLog(@"Fail was called");
        XCTAssert([error.domain isEqualToString:errorToRejectWith.domain], @"Error domain should equal %@", errorToRejectWith.domain);
    }];
    [deferred addFail:^(NSError *error) {
        NSLog(@"Fail was called again");
        XCTAssert([error.domain isEqualToString:errorToRejectWith.domain], @"Error domain should equal %@", errorToRejectWith.domain);
    }];
    [deferred addFail:^(NSError *error) {
        NSLog(@"Fail was called again again");
        XCTAssert([error.domain isEqualToString:errorToRejectWith.domain], @"Error domain should equal %@", errorToRejectWith.domain);
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again");
    }];
    [deferred addAlways:^{
        NSLog(@"Always was called again again");
    }];
}

- (void)testResolvingDeferredThenBlockBefore
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    NSString *valueToResolveWith = @"Yay";
    
    [deferred then:^(id value) {
        NSLog(@"Done was called");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    } fail:^(NSError *error) {
        NSLog(@"Fail was called");
    } always:^{
        NSLog(@"Always was called");
    }];
    
    [deferred resolveWith:valueToResolveWith];
}

- (void)testResolvingDeferredThenBlockAfter
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    NSString *valueToResolveWith = @"Yay";
    
    [deferred resolveWith:valueToResolveWith];
    
    [deferred then:^(id value) {
        NSLog(@"Done was called");
        XCTAssert([value isEqualToString:valueToResolveWith], @"Value should equal %@", valueToResolveWith);
    } fail:^(NSError *error) {
        NSLog(@"Fail was called");
    } always:^{
        NSLog(@"Always was called");
    }];
}


- (void)testWhenNotDefined
{
    Deferred *deferred = [Deferred deferred];
    XCTAssertEqual(deferred.state, PromiseStatePending, @"Deferred state is not equal to PromiseStatePending");
    
    NSString *valueToResolveWith = @"Anything";
    [deferred resolveWith:valueToResolveWith];
    
    [deferred then:^(id value) {
        NSLog(@"Done was called");
    } fail:^(NSError *error) {
        NSLog(@"Fail was called");
    } always:^{
        NSLog(@"Always was called");
    }];
    
    [When when:@[deferred] then:nil fail:nil always:^{
        NSLog(@"Always was called with When");
        XCTAssertTrue(@"Should not crash when the 'then' and 'fail' blocks are not defined");
    }];
}

@end
