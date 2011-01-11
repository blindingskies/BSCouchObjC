//
//  BSCouchDBServer.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBServer.h"
#import "BSCouchDBDatabase.h"
#import "JSON.h"

#pragma mark Functions

NSString *percentEscape(NSString *str) {
	return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark PrivateMethods

@interface BSCouchDBServer ()

- (NSMutableURLRequest *)requestWithPath:(NSString *)aPath;

@end

#pragma mark -

@implementation BSCouchDBServer

@synthesize hostname;
@synthesize port;
@synthesize path;
@synthesize cookie;
@synthesize login;
@synthesize password;
@synthesize url;
@synthesize isSSL;

#pragma mark -
#pragma mark Initialization

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
	self.hostname = nil; [hostname release];
	self.path = nil; [path release];
	self.cookie = nil; [cookie release];
	self.url = nil; [url release];
	[super dealloc];
}

#pragma mark -
#pragma mark Dynamic methods

- (NSURL *)url {
	if (!url) {
		NSURL *aURL = [[NSURL alloc] initWithString:[self serverURLAsString]];
		self.url = aURL;
		[aURL release];
	}
	return url;
}

#pragma mark -
#pragma mark HTTP Requests

- (NSMutableURLRequest *)requestWithPath:(NSString *)aPath {
    NSURL *aUrl = self.url;
    if (aPath && ![aPath isEqualToString:@"/"])
        aUrl = [NSURL URLWithString:aPath relativeToURL:self.url];
    return [NSMutableURLRequest requestWithURL:aUrl];
}

// Send a request to the server and return the results as a UTF8 encoded string
- (NSString *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSHTTPURLResponse **)response {
	
	NSError *error = nil;
	
	// Create a pointer to a response buffer if we don't have one already
	NSHTTPURLResponse *responseBuffer;
	if(!response) response = &responseBuffer;
	
	NSLog(@"requesting: %@ %@", [request HTTPMethod], [[request URL] absoluteString]);
	
	// Use NSURLConnection's class method
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:&error];
	
	// Get the data as a UTF8 string
	NSString *str = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;

	// Check for errors response code
	if (!data || (*response).statusCode >= 300) {
		NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
		NSLog(@"CouchDB error.\n\tURL: %@\n\tError: %@\n\tResponse: %d %@\n\tBody: (%u bytes) %@\n\t", 
			  [request URL], 
			  error, 
			  (*response).statusCode, 
			  str, 
			  [[request HTTPBody] length], 
			  body);
		[str release];
		[body release];
		return nil;
	}
	return [str autorelease];
}

- (NSString *)sendSynchronousRequest:(NSURLRequest *)request {
	return [self sendSynchronousRequest:request returningResponse:nil];
}


#pragma mark -
#pragma mark Server Infomation

// Check whether the server is online/reachable
- (NetworkStatus)reachable {
	Reachability *reachability = [Reachability reachabilityWithHostName:self.hostname];
	return [reachability currentReachabilityStatus];
}

// Returns the CouchDB version string of the server
- (NSString *)version {
    NSMutableURLRequest *request = [self requestWithPath:nil];
    NSString *json = [self sendSynchronousRequest:request];
    return [[json JSONValue] valueForKey:@"version"];
}

- (NSString *)serverURLAsString {
	if(self.login && self.password) {
		if(!self.path)
			return [NSString stringWithFormat:@"%@://%@:%@@%@:%u", self.isSSL ? @"https" : @"http", self.login, self.password, self.hostname, self.port];  
		return [NSString stringWithFormat:@"%@://%@:%@@%@:%u/%@/", self.isSSL ? @"https" : @"http", self.login, self.password,  self.hostname, self.port, self.path];  		
	}	
	if(!self.path)
		return [NSString stringWithFormat:@"%@://%@:%u/", self.isSSL ? @"https" : @"http", self.hostname, self.port];  
	return [NSString stringWithFormat:@"%@://%@:%u/%@/", self.isSSL ? @"https" : @"http", self.hostname, self.port, self.path];  		
}

#pragma mark -
#pragma mark Databases

// Returns a list of the databases on the server
- (NSArray *)allDatabases {	
	// Use the special CouchDB request
    NSMutableURLRequest *request = [self requestWithPath:@"_all_dbs"];
	
    NSHTTPURLResponse *response;
    NSString *json = [self sendSynchronousRequest:request returningResponse:&response];
    if (200 == [response statusCode]) {
        return [json JSONValue];
    }
    return nil;
}

// Creates a database
- (BOOL)createDatabase:(NSString *)databaseName {
	// Just call PUT databasename
    NSMutableURLRequest *request = [self requestWithPath:percentEscape(databaseName)];
    [request setHTTPMethod:@"PUT"];
	[request setHTTPBody:[NSData dataWithBytes:@"" length:0]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    NSHTTPURLResponse *response;
    NSString *str = [self sendSynchronousRequest:request returningResponse:&response];
	NSLog(@"result string: %@", str);
    return 201 == [response statusCode];
}

// Deletes a database
- (BOOL)deleteDatabase:(NSString *)databaseName {
	// Just call DELETE databaseName
    NSMutableURLRequest *request = [self requestWithPath:percentEscape(databaseName)];
    [request setHTTPMethod:@"DELETE"];
    NSHTTPURLResponse *response;
    (void)[self sendSynchronousRequest:request returningResponse:&response];
    return 200 == [response statusCode];	
}

// Gets a database
- (BSCouchDBDatabase *)database:(NSString *)databaseName {
	return [[[BSCouchDBDatabase alloc] initWithServer:self name:databaseName] autorelease];
}

#pragma mark -
#pragma mark Users & Authentication

- (BOOL)loginUsingName:(NSString *)_username andPassword:(NSString *)_password {
	
	// We're going to login using the credential and the store the cookie that we get back
	NSString *post = [NSString stringWithFormat:@"name=%@&password=%@", _username, _password];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	
	// Create a request
	NSMutableURLRequest *request = [self requestWithPath:@"_session"];
	[request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
	NSHTTPURLResponse *response;
    NSString *json = [self sendSynchronousRequest:request returningResponse:&response];
	
    if (200 == [response statusCode]) {
		// We need to get the Set-Cookie response header
		self.cookie = [[response allHeaderFields] objectForKey:@"Set-Cookie"];
		return [[[json JSONValue] objectForKey:@"ok"] boolValue];
    }
    return NO;    
}


#pragma mark -
#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// We've got enough information to create a NSURLResponse
	// Because it can be called multiple times, such as for a redirect,
	// we reset the data each time.
	NSLog(@"connection did receive response.");
//	[self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// We received some data
	NSLog(@"connection did receive %d bytes of data.", [data length]);
//	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// We encountered an error
	
	// Release the retained connection and the data received so far
//	self.currentConnection = nil; [currentConnection release];
//	self.receivedData = nil; [receivedData release];

	// Log the error
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
//	failureCallback(error);
	
	// Unblock the connection
//	self.blockConnection = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// We received all the data without errors
	// Unblock the connection
	NSLog(@"connection did finish.");	
//	self.blockConnection = NO;	
}

@end
