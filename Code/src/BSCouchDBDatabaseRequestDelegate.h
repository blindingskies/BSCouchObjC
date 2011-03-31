//
//  BSCouchDBDatabaseRequestDelegate.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 31/03/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//
#import "BSCouchObjC.h"
#import "BSCouchDBRequestDelegate.h"
#import "BSCouchDBDatabaseDelegate.h"

typedef enum {
	kBSCouchDBDatabaseRequestDictionaryType,
	kBSCouchDBDatabaseRequestDocumentType,
	kBSCouchDBDatabaseRequestResponseType
} BSCouchDBDatabaseRequestType;

@interface BSCouchDBDatabaseRequestDelegate : BSCouchDBRequestDelegate {
@private
	BSCouchDBDatabase *_db;
	id <BSCouchDBDatabaseDelegate> _delegate;
	BSCouchDBDatabaseRequestType returnType;
}
@property (nonatomic, readwrite, assign)BSCouchDBDatabase *db;
@property (nonatomic, readwrite, assign) id <BSCouchDBDatabaseDelegate> delegate;

// Constructor, the return type is used to distinguish which delegate method will get called.
// GET requests for Documents will be Document type, other GET requests should be Dictionary
// type, and POST, PUT, DELETE should be Response type.
- (id)initWithDatabase:(BSCouchDBDatabase *)aDb delegate:(id <BSCouchDBDatabaseDelegate>)obj returnType:(BSCouchDBDatabaseRequestType)aType;

@end
