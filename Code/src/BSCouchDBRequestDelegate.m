//
//  BSCouchDBRequestDelegate.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 31/03/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBRequestDelegate.h"


@implementation BSCouchDBRequestDelegate

- (id)initWithSuccessBlock:(void (^)(ASIHTTPRequest *))successBlock failureBlock:(void (^)(ASIHTTPRequest *))failureBlock {
	self = [super init];
	if (self) {
		sBlock = successBlock;
		fBlock = failureBlock;
	}
	return self;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	sBlock(request);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	fBlock(request);
}

// We don't have implementation for the @optional ASIHTTPRequestDelegate
// methods. So this delegate is only used to support block callbacks from
// asynchronous server requests.

// However, as all requests are made by BSCouchDBDatabase objects, this
// object is subclassed to support extended delegate features. See
// BSCouchDBDatabaseRequestDelegate

@end
