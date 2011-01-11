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
	NSURL *url;	
}

@property (nonatomic, readwrite, retain) BSCouchDBServer *server;
@property (nonatomic, readwrite, retain) NSString *name;
@property (nonatomic, readwrite, retain) NSURL *url;

- (id)initWithServer:(BSCouchDBServer *)_server name:(NSString *)_name;

#pragma mark Get Methods

// General purpose get function.
- (NSDictionary *)get:(NSString *)argument;

// Get a specific (named) document, with either all revision strings, or a specific revision (or the latest) or both.
- (BSCouchDBDocument *)getDocument:(NSString *)documentId withRevisions:(BOOL)withRevs revision:(NSString *)revisionOrNil;

#pragma mark PUT & POST Methods

// General purpose post function
- (BSCouchDBResponse *)post:(NSString *)argument data:(NSData *)data;

// Post a new document from a dictionary
- (BSCouchDBResponse *)postDictionary:(NSDictionary *)aDictionary;

@end
