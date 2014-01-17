//
//  Deferred.h
//  Promises
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "Promise.h"

@interface Deferred : Promise

+ (Deferred*)deferred;
- (Deferred*)resolve:(id)value;
- (Deferred*)reject:(NSError*)error;
- (Promise*)promise;

@end
