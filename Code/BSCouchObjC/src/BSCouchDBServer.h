//
//  BSCouchDBServer.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "Reachability.h"

@class BSCouchDBDatabase;

NSString *percentEscape(NSString *str);

@interface BSCouchDBServer : NSObject {
@private
	
	NSString *hostname;
	NSString *path;
	NSString *cookie;
	NSUInteger port;	
	BOOL isSSL;	
	NSURL *url;
}

@property (nonatomic, readwrite, retain) NSString *hostname;
@property (nonatomic, readwrite, retain) NSString *path;
@property (nonatomic, readwrite, retain) NSString *cookie;
@property (nonatomic, readwrite, retain) NSURL *url;
@property (nonatomic, readwrite) NSUInteger port;
@property (nonatomic, readwrite) BOOL isSSL;




// Initialise a CouchDB server object with a host, port, path, ssl flag
- (id)initWithHost:(NSString *)_hostname port:(NSUInteger)_port path:(NSString *)_path ssl:(BOOL)_isSSL;

// Initialises a CouchDB server object with no SSL or path
- (id)initWithHost:(NSString *)_hostname port:(NSUInteger)_port;

#pragma mark Server Infomation

// Check whether the server is online/reachable
- (NetworkStatus)reachable;

// Returns the CouchDB version string of the server
- (NSString *)version;

// Returns the server's url as a string
- (NSString *)serverURLAsString;

#pragma mark HTTP Requests

// Send a request to the server and return the results as a UTF8 encoded string
- (NSString *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSHTTPURLResponse **)response;

// Send a request to the server without needing a response
- (NSString *)sendSynchronousRequest:(NSURLRequest *)request;

#pragma mark Databases

// Returns a list of the databases on the server
- (NSArray *)allDatabases;

// Creates a database
- (BOOL)createDatabase:(NSString *)databaseName;

// Deletes a database
- (BOOL)deleteDatabase:(NSString *)databaseName;

// Gets a database
- (BSCouchDBDatabase *)database:(NSString *)databaseName;

@end
