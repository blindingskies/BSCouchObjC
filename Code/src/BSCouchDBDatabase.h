//
//  BSCouchDBDatabase.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

@class BSCouchDBServer;
@class BSCouchDBDocument;
@class BSCouchDBResponse;

@interface BSCouchDBDatabase : NSObject {
@private
	BSCouchDBServer *server;
	NSString *name;
}

@property (nonatomic, readwrite, retain) BSCouchDBServer *server;
@property (nonatomic, readwrite, retain) NSString *name;
@property (nonatomic, readonly, assign) NSURL *url;

- (id)initWithServer:(BSCouchDBServer *)_server name:(NSString *)_name;

#pragma mark Information

// Information
- (NSDictionary *)info;

#pragma mark URLs and paths

// Return an authenticated URL if the Server has the credentials
- (NSURL *)authenticatedURL;

#pragma mark GET Methods

// General purpose get function.
- (NSDictionary *)get:(NSString *)argument;

// Get all the documents
- (NSArray *)allDocs;

// Get a specific (named) document, with either all revision strings, or a specific revision (or the latest) or both.
- (BSCouchDBDocument *)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil;

#pragma mark PUT & POST Methods

// General purpose post function
- (BSCouchDBResponse *)post:(NSString *)argument data:(NSData *)data;

// General purpose put function
- (BSCouchDBResponse *)put:(NSString *)argument data:(NSData *)data;

// Post a new document from a dictionary
- (BSCouchDBResponse *)postDictionary:(NSDictionary *)aDictionary;

// Put a document (dictionary) with a particular identifier
- (BSCouchDBResponse *)putDocument:(NSDictionary *)aDictionary named:(NSString *)aName;

// Put a document (dictionary) using the same
- (BSCouchDBResponse *)putDocument:(BSCouchDBDocument *)aDocument;

#pragma mark DELETE Methods

// Delete a document.
- (BSCouchDBResponse *)deleteDocument:(BSCouchDBDocument *)aDocument;

#pragma mark CouchDB _changes api

// Returns an array of BSCouchDBChange objects of the databases changes since the last sequence
// that pass the given filter, which is a string such as
// "{design document name}/{filter name}[&{query key}={query value}]"
- (NSArray *)changesSince:(NSUInteger)lastSequence filter:(NSString *)filter;

@end
