//
//  BSCouchDBDatabase.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDatabase.h"
#import "BSCouchDBServer.h"
#import "JSON.h"

#pragma mark Functions

#pragma mark PrivateMethods

@interface BSCouchDBDatabase ()

- (NSMutableURLRequest *)requestWithPath:(NSString *)aPath;

@end

#pragma mark -


@implementation BSCouchDBDatabase

@synthesize server;
@synthesize name;
@synthesize url;

- (id)initWithServer:(BSCouchDBServer *)_server name:(NSString *)_name {	
	self = [super init];
	if (self) {
		self.server = _server;
		self.name = _name;
	}
	return self;
}

- (void)dealloc {
	self.server = nil; [server release];
	self.name = nil; [name release];
	self.url = nil; [url release];	
	[super dealloc];
}

#pragma mark -
#pragma mark Dynamic methods

- (NSURL *)url {
	if (!url) {
		NSURL *aURL = [[NSURL alloc] initWithString:[percentEscape(self.name) stringByAppendingString:@"/"] relativeToURL:self.server.url];
		self.url = aURL;
		[aURL release];
	}
	return url;
}

#pragma mark -
#pragma mark Private methods

- (NSMutableURLRequest *)requestWithPath:(NSString *)aPath {
    NSURL *aUrl = self.url;
    if (aPath && ![aPath isEqualToString:@"/"])
        aUrl = [NSURL URLWithString:aPath relativeToURL:self.url];
    return [NSMutableURLRequest requestWithURL:aUrl];	
}

#pragma mark -
#pragma mark GET Methods

/**
 Use this method to query the database however you want
 */
- (NSDictionary *)get:(NSString *)argument {
	// Create a request
	NSURLRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	// Make a pointer to a response
	NSHTTPURLResponse *aResponse = nil;
	// Send the request to the server	
	NSString *str = [self.server sendSynchronousRequest:aRequest returningResponse:&aResponse];
	if (200 == [aResponse statusCode]) {
		return [str JSONValue];
	}
	return nil;
}

@end
