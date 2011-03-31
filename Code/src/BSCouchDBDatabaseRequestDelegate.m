//
//  BSCouchDBDatabaseRequestDelegate.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 31/03/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDatabaseRequestDelegate.h"

@interface BSCouchDBDatabaseRequestDelegate ()

// Remove self from the database retained set of request delegates
- (void)cleanup;

@end


@implementation BSCouchDBDatabaseRequestDelegate

@synthesize db=_db;
@synthesize delegate=_delegate;

- (id)initWithDatabase:(BSCouchDBDatabase *)aDb delegate:(id <BSCouchDBDatabaseDelegate>)obj returnType:(BSCouchDBDatabaseRequestType)aType {
	self = [super init];
	if (self) {
		self.db = aDb;
		self.delegate = obj;
		returnType = aType;
	}
	return self;
}

// Remove self from the database retained set of request delegates
- (void)cleanup {
	[self.db removeRequestDelegate:self];
}


// We implement the ASIHTTPRequestDelegate methods here, so that we can then
// dispatch the appropriate delegate method (our delegate that is)

- (void)requestFinished:(ASIHTTPRequest *)request {

	if (!self.delegate || !self.db) {
		return;
	}
	
	// The request completed successfully. We can now process the result

	// Get the data
	NSData *data = [request responseData];
	
	// As a UTF8 string
	NSString *json = data ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;
	
	switch (returnType) {
			
		case kBSCouchDBDatabaseRequestDictionaryType:
			if ([self.delegate respondsToSelector:@selector(database:returnedDictionary:)]) {				
				[self.delegate database:self.db returnedDictionary:[json JSONValue]]; 
				break;
			}
				 
		case kBSCouchDBDatabaseRequestDocumentType:
			if ([self.delegate respondsToSelector:@selector(database:returnedDocument:)]) {
				[self.delegate database:self.db returnedDocument:[BSCouchDBDocument documentWithDictionary:[json JSONValue] database:self.db]];
				break;
			}
		case kBSCouchDBDatabaseRequestResponseType:
			if ([self.delegate respondsToSelector:@selector(database:returnedResponse:)]) {
				[self.delegate database:self.db returnedResponse:[BSCouchDBResponse responseWithJSON:json]];
			}
			break;
		default:
			break;
	}	
	
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	if (!self.delegate || !self.db) {
		return;
	}

	if ([self.delegate respondsToSelector:@selector(database:returnedError:)]) {
		[self.delegate database:self.db returnedError:[request error]];
	}	
}

@end
