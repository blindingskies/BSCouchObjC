//
//  BSCouchDBDatabase.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDatabase.h"
#import "BSCouchDBServer.h"
#import "BSCouchDBDocument.h"
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
	// We always re-compute this, because it's possible that the server has been given authentication credentials
	// after this method was first called.
	return [NSURL URLWithString:[percentEscape(self.name) stringByAppendingString:@"/"] relativeToURL:self.server.url];
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

/**
 Get a specific (named) document, with either all revision strings, or a specific revision (or the latest) or both.
 */
- (BSCouchDBDocument *)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil {
	
	// Construct the URL argument depending on the options 
	NSMutableString *arg = [NSMutableString stringWithString:percentEscape(documentId)];
	
	if(withRevs) {
		[arg appendString:@"?revs=true&revs_info=true"];
	}
	
	if(revisionOrNil != nil) {
		[arg appendFormat:@"&rev=%@", revisionOrNil];
	}
	
	return [BSCouchDBDocument documentWithDictionary:[self get:arg] database:self];
}


#pragma mark -
#pragma mark PUT & POST Methods

/**
 General purpose post function.
 */
- (BSCouchDBResponse *)post:(NSString *)argument data:(NSData *)data {
	
	// Create a request
	NSURLRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setHTTPMethod:@"POST"];
	[aRequest setHTTPBody:data];
	
	NSHTTPURLResponse *response = nil;
	NSString *str = [self.server sendSynchronousRequest:aRequest returningResponse:&response];
	
	// Check the response
	if (201 == [response statusCode]) {
		return [[[BSCouchDBResponse alloc] initWithDictionary:[str JSONValue]] autorelease];
	}
	return nil;
}


/**
 Post a new document from a dictionary
 */
- (BSCouchDBResponse *)postDictionary:(NSDictionary *)aDictionary {
	
	// Encode the dictionary
	NSData *data = [[aDictionary JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	
	// Post it
	return [self post:nil data:data];
}


@end
