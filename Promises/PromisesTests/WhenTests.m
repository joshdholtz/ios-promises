//
//  WhenTests.m
//  Promises
//
//  Created by Graham Mueller on 7/27/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Promise.h"

@interface WhenTests : XCTestCase

@end

@implementation WhenTests

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
