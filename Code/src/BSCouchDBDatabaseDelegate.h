//
//  BSCouchDBDatabaseDelegate.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 31/03/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

@class BSCouchDBDatabase;
@class BSCouchDBDocument;
@class BSCouchDBResponse;

@protocol BSCouchDBDatabaseDelegate <NSObject>

@optional

// Called when a request failed for some reason
- (void)database:(BSCouchDBDatabase *)db returnedError:(NSError *)anError;

// When calling a generic get: request this will return the result to the delegate
- (void)database:(BSCouchDBDatabase *)db returnedDictionary:(NSDictionary *)dictionary;

// When requesting a specific document, this will return it.
- (void)database:(BSCouchDBDatabase *)db returnedDocument:(BSCouchDBDocument *)document;

// When performing REST opertions that don't return data, we still want to get the response
- (void)database:(BSCouchDBDatabase *)db returnedResponse:(BSCouchDBResponse *)response;

@end
