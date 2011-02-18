//
//  DesignDocumentTest.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 04/02/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <BSCouchObjC/BSCouchObjC.h>

@interface DesignDocumentTest : GHTestCase {
@private
    BSCouchDBDesignDocument *designDocument;
}

@end


@implementation DesignDocumentTest

- (void)setUp {
	
    // Create a server object
    BSCouchDBServer *server = [[BSCouchDBServer alloc] init];
    
    // Create a database	
	NSString *databaseName = [NSString stringWithFormat:@"testdb%u", arc4random()];
	server.login = @"administrator";
	server.password = @"password";
	GHAssertTrue([server createDatabase:databaseName], @"Call failed to create databases. [%@]", databaseName);
    BSCouchDBDatabase *database = [[BSCouchDBDatabase alloc] initWithServer:server name:databaseName];
    // Release the server (it's retained by the database)
    [server release];
	
	// Create a fake design document
	// Create some dictionaries
	NSDictionary *trivialView = [NSDictionary dictionaryWithObjectsAndKeys:@"function(doc) { emit(doc._id, doc._rev); }", @"map", nil];	
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:trivialView, @"trivial", nil], @"views", nil];
	
	// PUT the fake design document on the db
	NSString *designDocName = @"_design/test";
	BSCouchDBResponse *response = [database putDocument:dic named:designDocName];
    GHAssertNotNil(response, @"Failed to receive a valid HTTP response when posting a new document.");
    GHAssertTrue(response.ok, @"Failed to post a new document despite getting valid HTTP Response.");
    GHAssertNotNil(response._id, @"BSCouchDBResponse does not contain an identifier");
    GHAssertNotNil(response._rev, @"BSCouchDBResponse does not contain an revision");
	
	// Now get the design documents that are on the database
	NSDictionary *doc = [database get:designDocName];	
	designDocument = [[BSCouchDBDesignDocument documentWithDictionary:doc database:database] retain];
}

- (void)tearDown {
    // Tear-down code here.
    
   	// Try and delete the database
	GHAssertTrue([designDocument.database.server deleteDatabase:designDocument.database.name], @"Failed to delete the created database.");	
    [designDocument release];
}


- (void)testDesignDocuments {
	NSLog(@"design documents: %@", [designDocument description]);
	GHAssertTrue([[designDocument viewNames] containsObject:@"_design/test/_view/trivial"], @"The list of CouchDB views doesn't contain the trivial view we created.");
}

@end
