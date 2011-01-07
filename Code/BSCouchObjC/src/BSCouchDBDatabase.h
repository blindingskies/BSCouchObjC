//
//  BSCouchDBDatabase.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

@class BSCouchDBServer;

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

- (NSDictionary *)get:(NSString *)argument;


@end
