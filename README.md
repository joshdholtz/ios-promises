# iOS-Promises

Asynchronous code... blah blah blah... standard interface for... blah blah blah... handling asynchronous actions... blah blah blah... chaining callbacks.

### Features
- `Deferred` objects (the controller for the promise) are used change state for promise behavior which triggers callbacks
- `Promise` objects are really just read-only `Deferred` objects
- Add done, fail, and always blocks to a `Deferred` or `Promise` object
    - Add 0 to many done, fail, and always blocks
    - Can use "then" method for shortcut to add one done, one fail, and one always block
- Create a `When` object to link `Promise` objects together
    - The done block executes when all promise object states are "resolved"
    - The fail block executes when one promise object state is "rejected"
    - The always block executes when all promises are no longer pending

## Installation

### Drop-in Classes
Clone the repository and drop in the .h and .m files from the "Classes" directory into your project.

### CocoaPods
Promises is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'Promises', :git => 'git@github.com:joshdholtz/ios-promises.git'

## Examples

### Deferred - resolving

```objc
Deferred *deferred1 = [Deferred deferred];
[deferred1 addDone:^(id value) {
    NSLog(@"WOOT - deferred1 is done - %@", value);
}];
[deferred1 resolve:@"Josh is awesome"];

```

### Deferred - rejecting with a promise
Rejecting a deferred's promise (promise is the same as deferred but doesn't show method for resolving or rejecting.

This would be used if you wanted to return a promise from some method.

```objc
Deferred *deferred2 = [Deferred deferred];

Promise *promise = deferred2.promise;
[promise addDone:^(id value) {
    NSLog(@"WOOT - deferred2 is done - %@", value);
}];
[promise addFail:^(NSError *error) {
    NSLog(@":( - deferred2 failed - %@", error.domain);
}];

[deferred2 reject:[NSError errorWithDomain:@"Oops" code:0 userInfo:nil]];

```

### When - chaining promises

```objc
Deferred *deferred1 = [Deferred deferred];
Deferred *deferred2 = [Deferred deferred];

[When when:@[deferred1, deferred2] then:^{
    NSLog(@"WHEN RESOLVING done called");
} fail:^(NSError *error) {
    NSLog(@"WHEN RESOLVING fail called - %@", error.domain);
} always:^{
    NSLog(@"WHEN RESOLVING always called");
}];

[deferred1 resolve:@"Yay"];
[deferred2 resolve:@"Woot"];

```

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

Promises is available under the MIT license. See the LICENSE file for more info.

