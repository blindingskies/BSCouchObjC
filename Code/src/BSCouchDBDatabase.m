//
//  BSCouchDBDatabase.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDatabase.h"
#import "BSCouchDBDatabaseRequestDelegate.h"
#import "BSCouchObjC.h"

#pragma mark Functions

#pragma mark PrivateMethods

@interface BSCouchDBDatabase ()

- (ASIHTTPRequest *)requestWithPath:(NSString *)aPath;

@end

#pragma mark -


@implementation BSCouchDBDatabase

@synthesize server;
@synthesize delegate=_delegate;;
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

#pragma mark -
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
#pragma mark GET Methods


/**
 Use this method to query the database however you want, but don't call this on
 the main thread, and ideally don't call it at all and use the async method 
 below.
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

// General purpose asynchronous get function.
- (ASIHTTPRequest *)request:(NSString *)argument {
	return [self requestWithPath:percentEscape(argument)];
}

// General purpose asynchronous get function. It's very important that the 
// database is retained, before calling this method.
- (void)get:(NSString *)argument delegate:(id <BSCouchDBDatabaseDelegate>)obj {
	
	// Set our own delegate
	self.delegate = obj;
	
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];

	// Set a user info dictionary
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:kBSCouchDBDatabaseRequestDictionaryType], @"type", nil];
	[aRequest setUserInfo:dic];

	// Call it on the server asynchronously
	[self.server sendAsynchronousRequest:aRequest usingDelegate:self];
}

// General purpose asynchronous get function with blocks not delegates
- (void)get:(NSString *)argument onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure {
	[[self request:argument onCompletion:onCompletion onFailure:onFailure] startAsynchronous];
}

// General purpose asynchronous get function with blocks, that returns the request without starting it.
- (ASIHTTPRequest *)request:(NSString *)argument onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure {
	
	// Create a request
	__block ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	
	[aRequest setCompletionBlock:^{
		
		// Get the data
		NSData *data = [aRequest responseData];
		
		// As a UTF8 string
		NSString *json = data ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;
		
		// Call our completion block
		onCompletion([json JSONValue]);
	}];
	
	[aRequest setFailedBlock:^{
		// Call our failure block
		onFailure([aRequest error]);
	}];
		
	return aRequest;
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


// Asynchronous version of the above
- (void)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil delegate:(id <BSCouchDBDatabaseDelegate>)obj {
	NSParameterAssert(documentId);

	// Construct the URL argument depending on the options 
	NSString *arg = percentEscape(documentId);
	
	if(withRevs) {
		arg = [arg stringByAppendingString:@"?revs=true&revs_info=true"];
	}
	
	if(revisionOrNil != nil) {
		arg = [arg stringByAppendingFormat:@"&rev=%@", revisionOrNil];
	}
	
	// Set our own delegate
	self.delegate = obj;
	
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:arg];
	
	// Set a user info dictionary
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:kBSCouchDBDatabaseRequestDocumentType], @"type", nil];
	[aRequest setUserInfo:dic];
	
	// Call it on the server asynchronously
	[self.server sendAsynchronousRequest:aRequest usingDelegate:self];	
}

// Asynchronous version but using blocks
- (void)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil onCompletion:(BSCouchDBDocumentBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure {
	[[self requestDocument:documentId withRevisions:withRevs revision:revisionOrNil onCompletion:onCompletion onFailure:onFailure] startAsynchronous];
}

// Returns a Request which can then be added to an external queue
- (ASIHTTPRequest *)requestDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil onCompletion:(BSCouchDBDocumentBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure {

	NSParameterAssert(documentId);
	
	// Construct the URL argument depending on the options 
	NSString *arg = percentEscape(documentId);
	
	if(withRevs) {
		arg = [arg stringByAppendingString:@"?revs=true&revs_info=true"];
	}
	
	if(revisionOrNil != nil) {
		arg = [arg stringByAppendingFormat:@"&rev=%@", revisionOrNil];
	}
	
	// Create a request
	__block ASIHTTPRequest *aRequest = [self requestWithPath:arg];
	
	[aRequest setCompletionBlock:^{
		
		// Get the data
		NSData *data = [aRequest responseData];
		
		// As a UTF8 string
		NSString *json = data ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;
		
		// Call our completion block
		onCompletion([BSCouchDBDocument documentWithDictionary:[json JSONValue] database:self]);		
	}];
	
	[aRequest setFailedBlock:^{
		// Call our failure block
		onFailure([aRequest error]);
	}];
		
	return aRequest;
}

// Returns a request, which can then be added to an external queue, for use with delegate pattern
- (ASIHTTPRequest *)requestDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil {
	NSParameterAssert(documentId);	
	
	// Construct the URL argument depending on the options 
	NSString *arg = percentEscape(documentId);
	
	if(withRevs) {
		arg = [arg stringByAppendingString:@"?revs=true&revs_info=true"];
	}
	
	if(revisionOrNil != nil) {
		arg = [arg stringByAppendingFormat:@"&rev=%@", revisionOrNil];
	}

	// return the request
	return [self requestWithPath:arg];	
}




#pragma mark -
#pragma mark PUT & POST Methods

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
 General purpose post function.
 */
- (BSCouchDBResponse *)post:(NSString *)argument data:(NSData *)data {
	NSParameterAssert(argument);	
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

// General purpose asynchronous post functions
- (void)post:(NSString *)argument data:(NSData *)data delegate:(id <BSCouchDBDatabaseDelegate>)obj {
	NSParameterAssert(argument);
	
	// Set our own delegate
	self.delegate = obj;

	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"POST"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];
	
	// Set a user info dictionary
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:kBSCouchDBDatabaseRequestDictionaryType], @"type", nil];
	[aRequest setUserInfo:dic];
	
	// Call it on the server asynchronously
	[self.server sendAsynchronousRequest:aRequest usingDelegate:self];
}

- (ASIHTTPRequest *)requestToPost:(NSString *)argument data:(NSData *)data onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure {
	NSParameterAssert(argument);
	// Create a request
	__block ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"POST"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];	
	
	// Set the blocks
	[aRequest setCompletionBlock:^{
		// Get the data
		NSData *data = [aRequest responseData];
		
		// As a UTF8 string
		NSString *json = data ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;
		
		// Call our completion block
		onCompletion([json JSONValue]);
	}];
	
	[aRequest setFailedBlock:^{
		// Call our failure block
		onFailure([aRequest error]);
	}];
	
	return aRequest;
}

- (ASIHTTPRequest *)requestToPost:(NSString *)argument data:(NSData *)data {
	NSParameterAssert(argument);
	
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"POST"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];	
	
	// Just return the request, leaving delegates, callbacks, scheduling up to the calling code
	return aRequest;
}



/**
 General purpose put function
 */
- (BSCouchDBResponse *)put:(NSString *)argument data:(NSData *)data {
	NSParameterAssert(argument);
    
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

/**
 Put a document (dictionary) with a particular identifier
 */
- (BSCouchDBResponse *)putDocument:(NSDictionary *)aDictionary named:(NSString *)aName {
    
	// Encode the dictionary
	NSData *data = [[aDictionary JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	
	// Put it
	return [self put:aName data:data];
    
}

// General purpose asynchronous post functions
- (void)put:(NSString *)argument data:(NSData *)data delegate:(id <BSCouchDBDatabaseDelegate>)obj {
	NSParameterAssert(argument);
	
	// Set our own delegate
	self.delegate = obj;
	
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"PUT"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];
	
	// Set a user info dictionary
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:kBSCouchDBDatabaseRequestDictionaryType], @"type", nil];
	[aRequest setUserInfo:dic];
	
	// Call it on the server asynchronously
	[self.server sendAsynchronousRequest:aRequest usingDelegate:self];	
}

- (ASIHTTPRequest *)requestToPut:(NSString *)argument data:(NSData *)data onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure {
	NSParameterAssert(argument);
	// Create a request
	__block ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"PUT"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];
		
	// Set the blocks
	[aRequest setCompletionBlock:^{
		// Get the data
		NSData *data = [aRequest responseData];
		
		// As a UTF8 string
		NSString *json = data ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;
		
		// Call our completion block
		onCompletion([json JSONValue]);
	}];
	
	[aRequest setFailedBlock:^{
		// Call our failure block
		onFailure([aRequest error]);
	}];
	
	return aRequest;
	
}

- (ASIHTTPRequest *)requestToPut:(NSString *)argument data:(NSData *)data {
	NSParameterAssert(argument);
    
	// Create a request
	ASIHTTPRequest *aRequest = [self requestWithPath:percentEscape(argument)];
	[aRequest setRequestMethod:@"PUT"];
	[aRequest addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[aRequest setPostBody:[NSMutableData dataWithData:data]];

	// Just return the request, leaving delegates, callbacks, scheduling up to the calling code
	return aRequest;	
}

- (ASIHTTPRequest *)requestToPut:(NSDictionary *)aDictionary named:(NSString *)aName {
	
	// Encode the dictionary
	NSData *data = [[aDictionary JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	
	// Put it
	return [self requestToPut:aName data:data];
	
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


#pragma mark -
#pragma mark Private methods

- (ASIHTTPRequest *)requestWithPath:(NSString *)aPath {
    NSURL *aUrl = self.url;
    if (aPath && ![aPath isEqualToString:@"/"])
        aUrl = [NSURL URLWithString:aPath relativeToURL:self.url];
    return [ASIHTTPRequest requestWithURL:aUrl];		
}

#pragma mark ASIHTTPRequestMethods

// We implement the ASIHTTPRequestDelegate methods here, so that we can then
// dispatch the appropriate delegate method (our delegate that is)

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	// Get the request's user info dictionary
	NSDictionary *dic = [request userInfo];
	
	BSCouchDBDatabaseRequestType type = [[dic objectForKey:@"type"] integerValue];
	
	if (!self.delegate) {
		return;
	}
	
	// The request completed successfully. We can now process the result
	
	// Get the data
	NSData *data = [request responseData];
	
	// As a UTF8 string
	NSString *json = data ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;
	
	switch (type) {
			
		case kBSCouchDBDatabaseRequestDictionaryType:
			if ([self.delegate respondsToSelector:@selector(database:returnedDictionary:)]) {				
				[self.delegate database:self returnedDictionary:[json JSONValue]]; 
				break;
			}
			
		case kBSCouchDBDatabaseRequestDocumentType:
			if ([self.delegate respondsToSelector:@selector(database:returnedDocument:)]) {
				[self.delegate database:self returnedDocument:[BSCouchDBDocument documentWithDictionary:[json JSONValue] database:self]];
				break;
			}
			
		case kBSCouchDBDatabaseRequestResponseType:
			if ([self.delegate respondsToSelector:@selector(database:returnedResponse:)]) {
				[self.delegate database:self returnedResponse:[BSCouchDBResponse responseWithJSON:json]];
			}
			break;
			
		default:
			break;
	}	
	
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	// Get the request's user info dictionary
	NSDictionary *dic = [request userInfo];
	
	id <BSCouchDBDatabaseDelegate> delegate = [dic objectForKey:@"delegate"];
	
	if (!delegate) {
		return;
	}
	
	if ([delegate respondsToSelector:@selector(database:returnedError:)]) {
		[delegate database:self returnedError:[request error]];
	}	
}


@end
