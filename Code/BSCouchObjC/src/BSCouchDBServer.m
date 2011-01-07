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
	[request setHTTPBody:[NSData dataWithBytes:NULL length:0]];
    NSHTTPURLResponse *response;
    (void)[self sendSynchronousRequest:request returningResponse:&response];
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


@end
