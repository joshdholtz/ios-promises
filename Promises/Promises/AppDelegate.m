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
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
