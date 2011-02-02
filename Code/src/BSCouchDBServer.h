//
//  BSCouchDBServer.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "Reachability.h"

@class BSCouchDBDatabase;
@class BSCouchDBResponse;
@class BSCouchDBReplicationResponse;
@class ASIHTTPRequest;

NSString *percentEscape(NSString *str);

@interface BSCouchDBServer : NSObject {
@private
	
	NSString *hostname;
	NSString *path;
	NSString *cookie;
	NSString *login;
	NSString *password;	
	NSUInteger port;	
	BOOL isSSL;	
	NSURL *url;
	
}

@property (nonatomic, readwrite, retain) NSString *hostname;
@property (nonatomic, readwrite, retain) NSString *path;
@property (nonatomic, readwrite, retain) NSString *cookie;
@property (nonatomic, readwrite, retain) NSString *login;
@property (nonatomic, readwrite, retain) NSString *password;
@property (nonatomic, readwrite, retain) NSURL *url;
@property (nonatomic, readwrite) NSUInteger port;
@property (nonatomic, readwrite) BOOL isSSL;



// Initialise a CouchDB server object with a host, port, path, ssl flag
- (id)initWithHost:(NSString *)_hostname port:(NSUInteger)_port path:(NSString *)_path ssl:(BOOL)_isSSL;

// Initialises a CouchDB server object with no SSL or path
- (id)initWithHost:(NSString *)_hostname port:(NSUInteger)_port;

#pragma mark Server Infomation

// Check whether the server is online/reachable
- (BOOL)isReachableWithError:(NSError *)error;

// Returns the CouchDB version string of the server
- (NSString *)version;

// Returns the server's url as a string
- (NSString *)serverURLAsString:(BOOL)authenticateIfPossible;

// Return the url with the option of authentication details or not
- (NSURL *)urlWithAuthentication:(BOOL)authenticateIfPossible;


#pragma mark HTTP Requests

/**
 This does starts the request going synchronously.
 We perform all requests synchronously so that the function returns
 with the answer. The calling method should ideally not be run in 
 the main thread (to avoid locking the interface), although we don't
 enforce or check this. 
 */
- (NSString *)sendSynchronousRequest:(ASIHTTPRequest *)request;

- (void)sendAsynchronousRequest:(ASIHTTPRequest *)request 
				  usingDelegate:(id<ASIHTTPRequestDelegate>)delegate;

- (void)sendAsynchronousRequest:(ASIHTTPRequest *)request 
			  usingSuccessBlock:(void (^)(ASIHTTPRequest *))successBlock
			  usingFailureBlock:(void (^)(ASIHTTPRequest *))failureBlock

#pragma mark Databases

// Returns a list of the databases on the server
- (NSArray *)allDatabases;

// Creates a database
- (BOOL)createDatabase:(NSString *)databaseName;

// Deletes a database
- (BOOL)deleteDatabase:(NSString *)databaseName;

// Gets a database
- (BSCouchDBDatabase *)database:(NSString *)databaseName;


#pragma mark Users & Authentication

// Create a database reader (non admin user)
- (BSCouchDBResponse *)createUser:(NSString *)_name password:(NSString *)_password;

// Login to the server
- (BOOL)loginUsingName:(NSString *)_username andPassword:(NSString *)_password;


#pragma mark Replication

// Replicate databases
- (BSCouchDBReplicationResponse *)replicateFrom:(NSString *)source to:(NSString *)target docs:(NSArray *)doc_ids filter:(NSString *)filter params:(NSDictionary *)queryParams;
@end
