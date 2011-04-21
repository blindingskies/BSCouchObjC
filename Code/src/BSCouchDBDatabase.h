//
//  BSCouchDBDatabase.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//
#import "BSCouchObjC.h"

typedef enum {
	kBSCouchDBDatabaseRequestDictionaryType,
	kBSCouchDBDatabaseRequestDocumentType,
	kBSCouchDBDatabaseRequestResponseType
} BSCouchDBDatabaseRequestType;

@class BSCouchDBServer;
@class BSCouchDBDocument;
@class BSCouchDBResponse;
@class BSCouchDBDatabaseRequestDelegate;
@protocol BSCouchDBDatabaseDelegate;

@interface BSCouchDBDatabase : NSObject <ASIHTTPRequestDelegate> {
@private
	BSCouchDBServer *server;
	NSString *name;
	id <BSCouchDBDatabaseDelegate> _delegate;
}

@property (nonatomic, readwrite, retain) BSCouchDBServer *server;
@property (nonatomic, readwrite, retain) NSString *name;
@property (nonatomic, readonly, assign) NSURL *url;
@property (nonatomic, readwrite, assign) id <BSCouchDBDatabaseDelegate> delegate;

- (id)initWithServer:(BSCouchDBServer *)_server name:(NSString *)_name;

#pragma mark Information

// Information
- (NSDictionary *)info;

// Get all the documents
- (NSArray *)allDocs;

// Design documents
- (NSArray *)designDocuments;

#pragma mark URLs and paths

// Return an authenticated URL if the Server has the credentials
- (NSURL *)authenticatedURL;

#pragma mark GET Methods

// General purpose synchronous get function.
- (NSDictionary *)get:(NSString *)argument;

// General purpose asynchronous get function
- (void)get:(NSString *)argument delegate:(id <BSCouchDBDatabaseDelegate>)obj;

// General purpose asynchronous get function with blocks not delegates
- (void)get:(NSString *)argument onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure;

// General purpose asynchronous get function with blocks, that returns the request without starting it.
- (ASIHTTPRequest *)request:(NSString *)argument onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure;

// Get a specific (named) document, with either all revision strings, or a specific revision (or the latest) or both.
- (BSCouchDBDocument *)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil;

// Asynchronous version of the above
- (void)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil delegate:(id <BSCouchDBDatabaseDelegate>)obj;

// Asynchronous version but using blocks
- (void)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil onCompletion:(BSCouchDBDocumentBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure;

// Returns a Request which can then be added to an external queue, using blocks
- (ASIHTTPRequest *)requestDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil onCompletion:(BSCouchDBDocumentBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure;

// Returns a request, which can then be added to an external queue, for use with delegate pattern
- (ASIHTTPRequest *)requestDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil;

#pragma mark PUT & POST Methods

// Post a new document from a dictionary [synchronous]
- (BSCouchDBResponse *)postDictionary:(NSDictionary *)aDictionary;

// General purpose synchronous post function
- (BSCouchDBResponse *)post:(NSString *)argument data:(NSData *)data;

// General purpose asynchronous post functions
- (void)post:(NSString *)argument data:(NSData *)data delegate:(id <BSCouchDBDatabaseDelegate>)obj;
- (ASIHTTPRequest *)requestToPost:(NSString *)argument data:(NSData *)data onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure;
- (ASIHTTPRequest *)requestToPost:(NSString *)argument data:(NSData *)data;

// General purpose synchronous put function
- (BSCouchDBResponse *)put:(NSString *)argument data:(NSData *)data;

// Put a document (dictionary) using it's own identifier [synchronous]
- (BSCouchDBResponse *)putDocument:(BSCouchDBDocument *)aDocument;

// Put a document (dictionary) with a particular identifier [synchronous]
- (BSCouchDBResponse *)putDocument:(NSDictionary *)aDictionary named:(NSString *)aName;

// General purpose asynchronous post functions
- (void)put:(NSString *)argument data:(NSData *)data delegate:(id <BSCouchDBDatabaseDelegate>)obj;
- (ASIHTTPRequest *)requestToPut:(NSString *)argument data:(NSData *)data onCompletion:(BSCouchDBDictionaryBlock)onCompletion onFailure:(BSCouchDBErrorBlock)onFailure;
- (ASIHTTPRequest *)requestToPut:(NSString *)argument data:(NSData *)data;
- (ASIHTTPRequest *)requestToPut:(NSDictionary *)aDictionary named:(NSString *)aName;

#pragma mark DELETE Methods

// Delete a document.
- (BSCouchDBResponse *)deleteDocument:(BSCouchDBDocument *)aDocument;

#pragma mark CouchDB _changes api

// Returns an array of BSCouchDBChange objects of the databases changes since the last sequence
// that pass the given filter, which is a string such as
// "{design document name}/{filter name}[&{query key}={query value}]"
- (NSArray *)changesSince:(NSUInteger)lastSequence filter:(NSString *)filter;


#pragma mark Miscellancy


@end
