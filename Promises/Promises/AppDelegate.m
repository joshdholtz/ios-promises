//
//  AppDelegate.m
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "AppDelegate.h"

#import "Promise.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Example 1: resolving a deferred
    Deferred *deferred1 = [Deferred deferred];
    [deferred1 addDone:^(id value) {
        NSLog(@"WOOT - deferred1 is done - %@", value);
    }];
    [deferred1 resolveWith:@"Josh is awesome"];
    
    // Example 2: rejecting a deferred's promise (promise is the same as deferred but doesn't
    // show method for resolving or rejecting
    // This is used when you want to return just a promise from a method
    Deferred *deferred2 = [Deferred deferred];
    Promise *promise = deferred2.promise;
    [promise addDone:^(id value) {
        NSLog(@"WOOT - deferred2 is done - %@", value);
    }];
    [promise addFail:^(NSError *error) {
        NSLog(@":( - deferred2 failed - %@", error.domain);
    }];
    [deferred2 rejectWith:[NSError errorWithDomain:@"Oops" code:0 userInfo:nil]];
    
    // Example 3: multiple dones, fails, and always
    Deferred *deferred3 = [Deferred deferred];
    [deferred3 addDone:^(id value) {
        NSLog(@"DONE 1 - deferred3 is done - %@", value);
    }];
    [deferred3 addDone:^(id value) {
        NSLog(@"DONE 2 - deferred3 is done - %@", value);
    }];
    [deferred3 addDone:^(id value) {
        NSLog(@"DONE 3 - deferred3 is done - %@", value);
    }];
    [deferred3 addFail:^(NSError *error) {
        NSLog(@":( - deferred3 failed - %@", error.domain);
    }];
    [deferred3 addFail:^(NSError *error) {
        NSLog(@":( - deferred3 failed - %@", error.domain);
    }];
    [deferred3 addAlways:^{
        NSLog(@":) 1 - deferred3 always!");
    }];
    [deferred3 addAlways:^{
        NSLog(@":) 2- deferred3 always!");
    }];
    
    [deferred3 resolveWith:@"Sweet stuff"];
    
    // When examples
    [self testWhenRejecting];
    [self testWhenResolving];
    [self testWhenNotFinishing];
    [self testWhenSlowAlways];
    [self testDoneOnAnObject];
    
    return YES;
}

/*
 * The fail and always will get called
 */
- (void)testWhenRejecting {
    Deferred *deferred1 = [Deferred deferred];
    Deferred *deferred2 = [Deferred deferred];
    
    [When when:@[deferred1, deferred2] then:^{
        NSLog(@"WHEN REJECTING done called");
    } fail:^(NSError *error) {
        NSLog(@"WHEN REJECTING fail called - %@", error.domain);
    } always:^{
        NSLog(@"WHEN REJECTING always called");
    }];
    
    [deferred1 resolveWith:@"Yay"];
    [deferred2 rejectWith:[NSError errorWithDomain:@"Oops" code:0 userInfo:nil]];
}

/*
 * The then/done and always will get called
 */
- (void)testWhenResolving {
    Deferred *deferred1 = [Deferred deferred];
    Deferred *deferred2 = [Deferred deferred];
    
    [When when:@[deferred1, deferred2] then:^{
        NSLog(@"WHEN RESOLVING done called");
    } fail:^(NSError *error) {
        NSLog(@"WHEN RESOLVING fail called - %@", error.domain);
    } always:^{
        NSLog(@"WHEN RESOLVING always called");
    }];
    
    [deferred1 resolveWith:@"Yay"];
    [deferred2 resolveWith:@"Woot"];
}

/*
 * Nothing will get called because all promises were never finished
 */
- (void)testWhenNotFinishing {
    Deferred *deferred1 = [Deferred deferred];
    Deferred *deferred2 = [Deferred deferred];
    
    [When when:@[deferred1, deferred2] then:^{
        NSLog(@"WHEN NOT FINISHING done called");
    } fail:^(NSError *error) {
        NSLog(@"WHEN NOT FINISHING fail called - %@", error.domain);
    } always:^{
        NSLog(@"WHEN NOT FINISHING always called");
    }];
    
    [deferred1 resolveWith:@"Yay"];
}

/*
 * Nothing will get called because all promises were never finished
 */
- (void)testWhenSlowAlways {
    Deferred *deferred1 = [Deferred deferred];
    Deferred *deferred2 = [Deferred deferred];
    
    [When when:@[deferred1, deferred2] then:^{
        NSLog(@"WHEN NOT FINISHING done called");
    } fail:^(NSError *error) {
        NSLog(@"WHEN NOT FINISHING fail called - %@", error.domain);
    } always:^{
        NSLog(@"WHEN NOT FINISHING always called");
    }];
    
    [deferred1 rejectWith:[NSError errorWithDomain:@"Oops" code:0 userInfo:nil]];
    
    sleep(5);
    [deferred2 resolveWith:@"Yay"];
}

/*
 * The following method should result in the method below it getting called
 */
- (void)testDoneOnAnObject {
    Deferred *deferred1 = [Deferred deferred];
    Deferred *deferred2 = [Deferred deferred];
    
    [deferred1.promise addDoneSelector:@selector(doneOnAppDelegateWithObject:) onObject:self];
    [deferred2.promise addFailSelector:@selector(failOnAppDelegateWithError:) onObject:self];
    [deferred1.promise addAlwaysSelector:@selector(alwaysOnAppDelegate) onObject:self];
    [deferred2.promise addAlwaysSelector:@selector(alwaysOnAppDelegate) onObject:self];
    
    [deferred1 resolveWith:@"Yay"];
    [deferred2 rejectWith:@"Ruh Roh"];
}

- (void)doneOnAppDelegateWithObject:(id)object {
    NSLog(@"Done called on AppDelegate with object: %@", object);
}

- (void)failOnAppDelegateWithError:(id)error {
    NSLog(@"Fail called on AppDelegate with error: %@", error);
}

- (void)alwaysOnAppDelegate {
    NSLog(@"Always called on AppDelegate -- This should happen twice!");
}

@end
