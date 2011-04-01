//
//  BSCouchDBServer.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBServer.h"
#import "BSCouchObjC.h"
#import "NSStringAdditions.h"
#import "BSCouchDBRequestDelegate.h"

#pragma mark Functions

NSString *percentEscape(NSString *str) {
	if (![str hasPrefix:@"org.couchdb.user%3A"]) {
		return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	return str;
}

#pragma mark PrivateMethods

@interface BSCouchDBServer ()

- (ASIHTTPRequest *)requestWithPath:(NSString *)aPath;

@end

#pragma mark -

@implementation BSCouchDBServer

@synthesize hostname;
@synthesize port;
@synthesize path;
@synthesize cookies;
@synthesize login;
@synthesize password;
@synthesize url;
@synthesize isSSL;

#pragma mark -
#pragma mark Initialization

+ (void)initialize {
	[super initialize];
	// Turn on the ASIHTTPRequest response cache
	[ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
}

- (id)initWithHost:(NSString *)_hostname port:(NSUInteger)_port path:(NSString *)_path ssl:(BOOL)_isSSL {
	self = [super init];
	if (self) {
		self.hostname = _hostname;
		self.port = _port;
		self.path = _path;
		self.isSSL = _isSSL;
	}
	return self;
}

- (id)initWithHost:(NSString *)_hostname port:(NSUInteger)_port {
	return [self initWithHost:_hostname port:_port path:nil ssl:NO];
}

- (id)init {
	return [self initWithHost:@"localhost" port:5984 path:nil ssl:NO];
}

- (void)dealloc {
	[hostname release];
	[path release];
	[cookies release];
	[url release];
	[super dealloc];
}

#pragma mark -
#pragma mark Dynamic methods

- (NSURL *)url {
	if (!url) {		
		self.url = [NSURL URLWithString:[self serverAuthenticatedURLAsString]];
	}
	return url;
}

#pragma mark -
#pragma mark HTTP Requests

/**
 This starts the request going synchronously.
 We perform all requests synchronously so that the function returns
 with the answer. The calling method should ideally not be run in 
 the main thread (to avoid locking the interface), although we don't
 enforce or check this. 
 */
- (NSString *)sendSynchronousRequest:(ASIHTTPRequest *)request {
	
	// Set credentials
	if (self.cookies) {
		[request setRequestCookies:self.cookies];
	} else if (self.login && self.password) {
		request.username = self.login;
		request.password = self.password;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	if (error) {
		NSLog(@"response string: %@",[request responseString]);		
		NSLog(@"Error: %@", [error userInfo]); 
		NSLog(@"There is totally an error here");
		return nil;
	}
	
	NSData *data = [request responseData];
	
	// Get the data as a UTF8 string
	NSString *str = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
	
	return [str autorelease];	
}


/**
 This starts the request going asynchronously
 */
- (void)sendAsynchronousRequest:(ASIHTTPRequest *)request usingDelegate:(id<ASIHTTPRequestDelegate>)delegate {
	// Set credentials
	if (self.cookies) {
		[request setRequestCookies:self.cookies];
	} else if (self.login && self.password) {
		request.username = self.login;
		request.password = self.password;
	}
	
	request.delegate = delegate;
	[request startAsynchronous];
}

- (void)sendAsynchronousRequest:(ASIHTTPRequest *)request 
			  usingSuccessBlock:(ASIBasicBlock)successBlock
			  usingFailureBlock:(ASIBasicBlock)failureBlock

{
	// Set credentials
	if (self.cookies) {
		[request setRequestCookies:self.cookies];
	} else if (self.login && self.password) {
		request.username = self.login;
		request.password = self.password;
	}	
	
	[request setCompletionBlock:successBlock];
	[request setFailedBlock:failureBlock];
	
	[request startAsynchronous];
}


// Returns a request so it can be added to an external queue
- (ASIHTTPRequest *)asynchronousRequest:(ASIHTTPRequest *)request usingSuccessBlock:(ASIBasicBlock)successBlock usingFailureBlock:(ASIBasicBlock)failureBlock {
	// Set credentials
	if (self.cookies) {
		[request setRequestCookies:self.cookies];
	} else if (self.login && self.password) {
		request.username = self.login;
		request.password = self.password;
	}	
	
	[request setCompletionBlock:successBlock];
	[request setFailedBlock:failureBlock];

	return request;
}



- (ASIHTTPRequest *)requestWithPath:(NSString *)aPath {
    NSURL *aUrl = self.url;
    if (aPath && ![aPath isEqualToString:@"/"])
        aUrl = [NSURL URLWithString:aPath relativeToURL:self.url];
    return [ASIHTTPRequest requestWithURL:aUrl];
}


#pragma mark -
#pragma mark Server Infomation

// Check whether the server is online/reachable
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))

// Mac OS X	
- (BOOL)isReachableWithError:(NSError *)error {
	return [self.url checkResourceIsReachableAndReturnError:&error];
}

#else		

// iPhone, use this to test for WiFi, or cell reachability
- (NetworkStatus)reachabilityStatus {
	Reachability *reachability = [Reachability reachabilityWithHostName:self.hostname];
	return [reachability currentReachabilityStatus];
}

#endif


// Returns the CouchDB version string of the server
- (NSString *)version {
    ASIHTTPRequest *request = [self requestWithPath:nil];
    NSString *json = [self sendSynchronousRequest:request];
    return [[json JSONValue] valueForKey:@"version"];
}

- (NSString *)serverURLAsString {
	
	NSString *str = [NSString stringWithFormat:@"%@://%@", self.isSSL ? @"https" : @"http", self.hostname];
	
	if (self.port != 80) {
		str = [str stringByAppendingFormat:@":%u", self.port];
	}
	
	if(self.path) {
		str = [str stringByAppendingFormat:@"/%@/", self.path];
	}
	return str;
}

// Returns the server's authenticated url as a string
- (NSString *)serverAuthenticatedURLAsString {
	if (!self.login || !self.password) {
		return [self serverURLAsString];
	}
	
	NSString *str = [NSString stringWithFormat:@"%@://%@:%@@%@", self.isSSL ? @"https" : @"http", self.login, self.password, self.hostname];
	
	if (self.port != 80) {
		str = [str stringByAppendingFormat:@":%u", self.port];
	}
	
	if(self.path) {
		str = [str stringByAppendingFormat:@"/%@/", self.path];
	}
	return str;	
}


#pragma mark -
#pragma mark Databases

// Returns a list of the databases on the server
- (NSArray *)databaseNames {	

	// Use the special CouchDB request	
	ASIHTTPRequest *request = [self requestWithPath:@"_all_dbs"];	
	NSString *json = [self sendSynchronousRequest:request];
	if (json) {
		return [json JSONValue];
	}
	
	return nil;
}

// Returns an array of BSCouchDBDatabase instances of the database on the server
- (NSArray *)databases {
	
	// Get the database names
	NSArray *tmp = [self databaseNames];
	if (!tmp) return nil;
	// Iterate through the database names and create a BSCouchDBDatabase object for each one.
	// this doesn't query the server for anything.
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[tmp count]];
	for (NSString *name in tmp) {
		BSCouchDBDatabase *db = [[BSCouchDBDatabase alloc] initWithServer:self name:name];
		[result addObject:db];
		[db release];
	}
	return [NSArray arrayWithArray:result];	
}


// Creates a database
- (BOOL)createDatabase:(NSString *)databaseName {
	// Just call PUT databasename
    ASIHTTPRequest *request = [self requestWithPath:percentEscape(databaseName)];
    request.requestMethod = @"PUT";
	request.postBody = [NSData dataWithBytes:@"" length:0];
	request.contentLength = 0;
	NSString *json = [self sendSynchronousRequest:request];
	BSCouchDBResponse *response = [BSCouchDBResponse responseWithJSON:json];	
	return response.ok;
}

// Deletes a database
- (BOOL)deleteDatabase:(NSString *)databaseName {
	// Just call DELETE databaseName
    ASIHTTPRequest *request = [self requestWithPath:percentEscape(databaseName)];
    request.requestMethod = @"DELETE";
	// Make the request
	NSString *json = [self sendSynchronousRequest:request];
	// Get the CouchDB response
	BSCouchDBResponse *response = [BSCouchDBResponse responseWithJSON:json];	
	return response.ok;
}

// Gets a database
- (BSCouchDBDatabase *)database:(NSString *)databaseName {
	if ([[self databaseNames] containsObject:databaseName]) {
		return [[[BSCouchDBDatabase alloc] initWithServer:self name:databaseName] autorelease];
	} else {
		return nil;
	}
}




#pragma mark -
#pragma mark Users & Authentication

// Create a database reader (non admin user)
- (BSCouchDBResponse *)createUser:(NSString *)_name password:(NSString *)_password {
	
	NSParameterAssert(_name);
	NSParameterAssert(_password);	
	NSAssert(self.login != nil, @"The server need's an administrator login name");
	NSAssert(self.password != nil, @"The server need's an administrator login password");
	
	// Create a salt
	NSString *salt = [[NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]] sha1];
	
	// Hash the password and salt
	NSString *digest = [[NSString stringWithFormat:@"%@%@", _password, salt] sha1];
	
	// Create the document id
	NSString *docid = [NSString stringWithFormat:@"org.couchdb.user%%3A%@", _name];
	
	// Create a dictionary
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:6];
	
	// Create an empty roles array
	NSArray *roles = [[NSArray alloc] init];	
	
	// Set the properties of the dictionary
	[dic setObject:salt forKey:@"salt"];
	[dic setObject:digest forKey:@"password_sha"];
	[dic setObject:_name forKey:@"name"];
	[dic setObject:@"user" forKey:@"type"];
	[dic setObject:roles forKey:@"roles"];
	[dic setObject:docid forKey:@"_id"];
	
	// Release memory
	[roles release];
	
	// Now we push the dictionary to the authentication db
	NSString *authenticationDB = @"_users";
	
	// Create a SBCouchDatabase instance
	BSCouchDBDatabase *db = [self database:authenticationDB];
	
	// Put the document on the server
	BSCouchDBResponse *response = [db putDocument:dic named:docid];
	
	// Release memory
	[dic release];
	
	return response;	
}

// Login using a name / password
- (BOOL)loginUsingName:(NSString *)_username andPassword:(NSString *)_password {
	
	// We're going to login using the credential and the store the cookie that we get back
	NSString *post = [NSString stringWithFormat:@"name=%@&password=%@", _username, _password];
	NSMutableData *postData = [NSMutableData dataWithData:[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
	
	// Create a request
	NSURL *baseURL = [NSURL URLWithString:[self serverURLAsString]];
	NSURL *sessionURL = [NSURL URLWithString:@"_session" relativeToURL:baseURL];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:sessionURL];
	[request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
	[request setPostBody:postData];
	
    NSString *json = [self sendSynchronousRequest:request];
	BSCouchDBResponse *response = [BSCouchDBResponse responseWithJSON:json];	
	
    if (response.ok) {
		// We need to get the Set-Cookie response header
		self.cookies = [NSMutableArray arrayWithArray:[NSHTTPCookie cookiesWithResponseHeaderFields:[request responseHeaders] forURL:[NSURL URLWithString:[self serverURLAsString]]]];
    }
	return response.ok;
}

// Logout of the server
- (BOOL)logoutUsingName:(NSString *)_username andPassword:(NSString *)_password {
	// We're going to login using the credential and the store the cookie that we get back
	NSString *post = [NSString stringWithFormat:@"name=%@&password=%@", _username, _password];
	NSMutableData *postData = [NSMutableData dataWithData:[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
	
	// Create a request
	ASIHTTPRequest *request = [self requestWithPath:@"_session"];
	[request setRequestMethod:@"DELETE"];
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
	[request setPostBody:postData];
	
    NSString *json = [self sendSynchronousRequest:request];
	BSCouchDBResponse *response = [BSCouchDBResponse responseWithJSON:json];	
	
    if (response.ok) {
		// We need to remove the Set-Cookie response header
		self.cookies = nil;
    }
	return response.ok;	
}




#pragma mark -
#pragma mark Replication

- (BSCouchDBReplicationResponse *)replicateFrom:(BSCouchDBDatabase *)source to:(BSCouchDBDatabase *)target docs:(NSArray *)doc_ids filter:(NSString *)filter params:(NSDictionary *)queryParams {
	
	NSParameterAssert(source);
	NSParameterAssert(target);	
	NSAssert([self isEqual:target.server], @"We make the call from the target");
	NSAssert(target.server.login, @"We require admin privileges to the target database");	
	NSAssert(target.server.password, @"We require admin privileges to the target database");
	
	// Work out the payload
	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
	[dic setValue:[[source authenticatedURL] absoluteString] forKey:@"source"];
	[dic setValue:[[target authenticatedURL] absoluteString] forKey:@"target"];
	
	if(doc_ids) {
		[dic setValue:doc_ids forKey:@"doc_ids"];
	}
	if(filter) {
		[dic setValue:filter forKey:@"filter"];
	}
	if(queryParams) {
		[dic setValue:queryParams forKey:@"query_params"];
	}
	
	// Get the JSON representation of this (this is the post data)
	NSString *json = [dic JSONRepresentation];
	
	// Create a request
	ASIHTTPRequest *request = [self requestWithPath:@"_replicate"];
	NSMutableData *body = [NSMutableData dataWithData:[json dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
	[request setRequestMethod:@"POST"];
	[request addRequestHeader:@"Content-Type" value:@"application/json; charset=UTF-8"];
	[request setPostBody:body];
	
    json = [self sendSynchronousRequest:request];
//	NSLog(@"json: %@", json);
    if (200 == [request responseStatusCode] && json) {
        return [BSCouchDBReplicationResponse responseWithJSON:json];
    }
    return nil;
}

@end
