//
//  BSURLConnection.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 23/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NS_BLOCKS_AVAILABLE
typedef void (^BSSuccessBlock)(NSData *);
typedef void (^BSFailureBlock)(NSError *);
#endif

@class BSURLConnection;

@protocol BSURLConnectionDelegate <NSObject>
- (void)bsURLConnection:(BSURLConnection *)connection didSucceedWithData:(NSData *)data;
- (void)bsURLConnection:(BSURLConnection *)connection didFailWithError:(NSError *)error;
@end;

@interface BSURLConnection : NSOperation {
@private

	// The Connection that we manage
	NSURLConnection *connection;
	
	// The URL request
	NSURLRequest *request;
		
	// The Delegate
	id <BSURLConnectionDelegate> delegate;

#if NS_BLOCKS_AVAILABLE	
	// Completion Blocks
	BSSuccessBlock onSuccess;
	BSFailureBlock onFailure;
#endif	
	
	// NSURLConnection stuff
	NSMutableData *receivedData;
	
	
}

@property (nonatomic, readwrite, assign) id <BSURLConnectionDelegate> delegate;
@property (nonatomic, readwrite, retain) NSURLConnection *connection;
@property (nonatomic, readwrite, retain) NSURLRequest *request;
#if NS_BLOCKS_AVAILABLE	
@property (nonatomic, readwrite, retain) BSSuccessBlock onSuccess;
@property (nonatomic, readwrite, retain) BSFailureBlock onFailure;
#endif	


#if NS_BLOCKS_AVAILABLE
+ (BSURLConnection *)connectionWithRequest:(NSURLRequest *)aRequest onSuccessBlock:(BSSuccessBlock)successBlock onFailureBlock:(BSFailureBlock)failureBlock;
#endif

+ (BSURLConnection *)connectionWithRequest:(NSURLRequest *)aRequest delegate:(id)anObject;

- (id)initWithRequest:(NSURLRequest *)aRequest;


@end
