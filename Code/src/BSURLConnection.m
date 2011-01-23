//
//  BSURLConnection.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 23/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSURLConnection.h"


@implementation BSURLConnection

@synthesize delegate;
@synthesize connection;
@synthesize	request;
#if NS_BLOCKS_AVAILABLE	
@synthesize onSuccess;
@synthesize onFailure;
#endif	


#pragma mark Class Methods

#if NS_BLOCKS_AVAILABLE
+ (BSURLConnection *)connectionWithRequest:(NSURLRequest *)aRequest onSuccessBlock:(BSSuccessBlock)successBlock onFailureBlock:(BSFailureBlock)failureBlock {

	// Create a BSURLConnection
	BSURLConnection *aConnection = [[BSURLConnection alloc] initWithRequest:aRequest];

	// Set the completion blocks
	aConnection.onSuccess = successBlock;
	aConnection.onFailure = failureBlock;
	
	// Return the connection
	return [aConnection autorelease];
	
}
#endif

+ (BSURLConnection *)connectionWithRequest:(NSURLRequest *)aRequest delegate:(id)anObject {
	
	// Create a BSURLConnection
	BSURLConnection *aConnection = [[BSURLConnection alloc] initWithRequest:aRequest];
	
	// Set the delegate
	aConnection.delegate = anObject;
	
	// Return it
	return [aConnection autorelease];
}


#pragma mark -
#pragma mark Instance Methods

- (id)initWithRequest:(NSURLRequest *)aRequest {
	self = [super init];
	if (self) {
		self.request = aRequest;
	}
	return self;
}

- (void)main {
	
	// Create a NSURLConnection
	self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
	
	// Alloc and init the received data
	receivedData = [[NSMutableData alloc] init];
	
	// Start the connection
	[self.connection start];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
	// We've got enough information to create a NSURLResponse
	// Because it can be called multiple times, such as for a redirect,
	// we reset the data each time.
	NSLog(@"connection did receive response.");
	[receivedData setLength:0];	
}


- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	// We received some data
	NSLog(@"connection did receive %d bytes of data.", [data length]);
	[receivedData appendData:data];
}


- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	// We encountered an error
	
	// Release the retained connection and the data received so far
	//	self.currentConnection = nil; [currentConnection release];
	//	self.receivedData = nil; [receivedData release];
	
	// Log the error
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	// We need to check to see if we've got a delegate
	if (self.onFailure) {
		onFailure(error);
	} else if (self.delegate && [self.delegate respondsToSelector:@selector(bsURLConnection:didFailWithError:)]) {
		[self.delegate bsURLConnection:self didFailWithError:error];
	}
	
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	// We received all the data without errors
	NSLog(@"connection did finish.");	
	
	// We need to check to see if we've got a delegate
	if (self.onSuccess) {
		onSuccess(receivedData);
	} else if (self.delegate && [self.delegate respondsToSelector:@selector(bsURLConnection:didSucceedWithData:)]) {
		[self.delegate bsURLConnection:self didSucceedWithData:receivedData];
	}
	
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


- (void)connection:(NSURLConnection *)aConnection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Received authentication challenge: %@", [challenge description]);
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		if ([trustedHosts containsObject:challenge.protectionSpace.host])
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
	
}

@end
