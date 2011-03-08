//
//  BSCouchDBDatabase.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDatabase.h"
#import "BSCouchObjC.h"

#pragma mark Functions

#pragma mark PrivateMethods

@interface BSCouchDBDatabase ()

- (ASIHTTPRequest *)requestWithPath:(NSString *)aPath;

@end

#pragma mark -


@implementation BSCouchDBDatabase

@synthesize server;
@synthesize name;

@dynamic url;

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
	[super dealloc];
}

#pragma mark -
#pragma mark Information

// Information
- (NSDictionary *)info {
	return [self get:nil];
}


/**
 Get all the documents
 */
- (NSArray *)allDocs {
	// Get the list of documents
	NSDictionary *list = [self get:COUCH_VIEW_ALL];
	
	// Return the rows
	return [list objectForKey:@"rows"];
}


// Design documents
- (NSArray *)designDocuments {
	// Until we add views and query options this is the best we can do at the moment
	NSString *query = @"_all_docs?startkey=\"_design\"&endkey=\"_design0\"";
	// Perform the get
	NSDictionary *results = [self get:query];
	if (results) {
		return [[results objectForKey:@"rows"] valueForKey:@"id"];
	}
	return nil;
}


#pragma mark -
#pragma mark Dynamic methods

- (NSURL *)url {
	// We always re-compute this, because it's possible that the server has been given authentication credentials
	// after this method was first called.
	return [NSURL URLWithString:[percentEscape(self.name) stringByAppendingString:@"/"] relativeToURL:self.server.url];
}

#pragma mark URLs and paths

// Return an authenticated URL if the Server has the credentials
- (NSURL *)authenticatedURL {
	if (!self.server.login || !self.server.password) {
		return [NSURL URLWithString:[percentEscape(self.name) stringByAppendingString:@"/"] relativeToURL:self.server.url];
	}
	NSURL *authenticatedServerURL = [NSURL URLWithString:[self.server serverAuthenticatedURLAsString]];
	return [NSURL URLWithString:[percentEscape(self.name) stringByAppendingString:@"/"] relativeToURL:authenticatedServerURL];
}


#pragma mark -
#pragma mark Private methods

- (ASIHTTPRequest *)requestWithPath:(NSString *)aPath {
    NSURL *aUrl = self.url;
    if (aPath && ![aPath isEqualToString:@"/"])
        aUrl = [NSURL URLWithString:aPath relativeToURL:self.url];
    return [ASIHTTPRequest requestWithURL:aUrl];		
}

#pragma mark -
#pragma mark GET Methods


/**
 Use this method to query the database however you want
 */
- (NSDictionary *)get:(NSString *)argument {
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	// Send the request to the server	
	NSString *json = [self.server sendSynchronousRequest:aRequest];
	if (200 == [aRequest responseStatusCode]) {
		return [json JSONValue];
	}
	return nil;
}


/**
 Get a specific (named) document, with either all revision strings, or a specific revision (or the latest) or both.
 */
- (BSCouchDBDocument *)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil {
	NSParameterAssert(documentId);
    
	// Construct the URL argument depending on the options 
	NSString *arg = percentEscape(documentId);
	
	if(withRevs) {
		arg = [arg stringByAppendingString:@"?revs=true&revs_info=true"];
	}
	
	if(revisionOrNil != nil) {
		arg = [arg stringByAppendingFormat:@"&rev=%@", revisionOrNil];
	}
	NSDictionary *dic = [self get:arg];
	return !dic ? nil : [BSCouchDBDocument documentWithDictionary:dic database:self];
}


#pragma mark -
#pragma mark PUT & POST Methods


/**
 General purpose post function.
 */
- (BSCouchDBResponse *)post:(NSString *)argument data:(NSData *)data {
	
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"POST"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];
	
	NSString *json = [self.server sendSynchronousRequest:aRequest];
	
	// Check the response
	if ([aRequest responseStatusCode] < 300) {
		return [BSCouchDBResponse responseWithJSON:json];
	}
	return nil;
}


/**
 General purpose put function
 */
- (BSCouchDBResponse *)put:(NSString *)argument data:(NSData *)data {
    
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"PUT"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];
	
	NSString *json = [self.server sendSynchronousRequest:aRequest];
	
	// Check the response
	if (201 == [aRequest responseStatusCode]) {
		return [BSCouchDBResponse responseWithJSON:json];
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


/**
 Put a document (dictionary) with a particular identifier
 */
- (BSCouchDBResponse *)putDocument:(NSDictionary *)aDictionary named:(NSString *)aName {
    
	// Encode the dictionary
	NSData *data = [[aDictionary JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	
	// Put it
	return [self put:aName data:data];
    
}


/**
 Put a document using it's own identifier.
 */
- (BSCouchDBResponse *)putDocument:(BSCouchDBDocument *)aDocument {

	// Call the general method
	BSCouchDBResponse *response = [self putDocument:aDocument.dictionary named:aDocument._id];
	
	// Check to see if we've got a proper response
	if (response && response.ok) {
		// Update the revision
		[aDocument setRevision:response._rev];
	}
	
	return response;
}


#pragma mark DELETE Methods

/**
 Delete a document.
 */
- (BSCouchDBResponse *)deleteDocument:(BSCouchDBDocument *)aDocument {
	NSParameterAssert(aDocument);
	
	// Generate a request
	ASIHTTPRequest *aRequest = [self requestWithPath:[NSString stringWithFormat:@"%@?rev=%@", percentEscape(aDocument._id), aDocument._rev]];
	
	// Set the method
	[aRequest setRequestMethod:@"DELETE"];
	
	// Execute the request
	NSString *json = [self.server sendSynchronousRequest:aRequest];
	
	// Check the response
	if (200 == [aRequest responseStatusCode]) {
		return [BSCouchDBResponse responseWithJSON:json];
	}
	return nil;
}


#pragma mark -
#pragma mark CouchDB _changes api

// Returns an array of BSCouchDBChange objects of the databases changes since the last sequence
// that pass the given filter, which is a string of the path such as
// "{design document name}/{filter name}[&{query key}={query value}]"
- (NSArray *)changesSince:(NSUInteger)lastSequence filter:(NSString *)filter {
	
	// Create a query string
	NSString *query = @"_changes";
	if (filter) {
		query = [query stringByAppendingFormat:@"?filter=%@&since=%d", filter, lastSequence];
	} else {
		query = [query stringByAppendingFormat:@"?since=%d", lastSequence];
	}

	// GET the result from the changes api
	NSDictionary *changesResult = [self get:query];
	
	// Make BSCouchDBChange objects
	NSArray *changesResults = [changesResult objectForKey:@"results"];
	NSUInteger numberOfResults = [changesResults count];
	
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:numberOfResults];
	for (NSDictionary *dic in changesResults) {
		BSCouchDBChange *change = [BSCouchDBChange changeWithDictionary:dic];
		[results addObject:change];
	}
	return results;
}


@end
