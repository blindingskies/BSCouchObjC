//
//  DatabaseTest.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <BSCouchObjC/BSCouchObjC.h>

@interface DatabaseTest : GHTestCase {
@private
    BSCouchDBDatabase *database;
}

@end


@implementation DatabaseTest

- (void)setUp {
    // Create a server object
    BSCouchDBServer *server = [[BSCouchDBServer alloc] init];
    
	NSString *databaseName = [NSString stringWithFormat:@"testdb%u", arc4random()];
	server.login = @"administrator";
	server.password = @"password";
	GHAssertTrue([server createDatabase:databaseName], @"Call failed to create databases. [%@]", databaseName);
    // Create the database
    database = [[BSCouchDBDatabase alloc] initWithServer:server name:databaseName];
    // Release the server (it's retained by the database)
    [server release];
}

- (void)tearDown {
    // Tear-down code here.
    
   	// Try and delete the database
	GHAssertTrue([database.server deleteDatabase:database.name], @"Failed to delete the created database.");	
    [database release];
}

- (void)testDocumentionCreateAndDelete {
    NSLog(@"Testing Database : document create & delete.\n");
    
    // Create a fake document
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Hello World", @"name", nil];
    
    // Post the document
    BSCouchDBResponse *response = [database postDictionary:dic];
    GHAssertNotNil(response, @"Failed to receive a valid HTTP response when posting a new document.");
    GHAssertTrue(response.ok, @"Failed to post a new document despite getting valid HTTP Response.");
    GHAssertNotNil(response._id, @"BSCouchDBResponse does not contain an identifier");
    GHAssertNotNil(response._rev, @"BSCouchDBResponse does not contain an revision");
    
    // Now we need to retrieve the document and make sure that we've got hello world
    BSCouchDBDocument *doc = [database getDocument:response._id withRevisions:NO revision:nil];
    GHAssertNotNil(doc, @"Failed to GET the newly created document, named %@", response._id);
    GHAssertTrue([[doc objectForKey:@"name"] isEqualToString:@"Hello World"], @"Document contents do not match the original dictionary");
    
	// Try and delete the document
	response = [database deleteDocument:doc];
	GHAssertNotNil(response, @"Failed to get a response when trying to delete a document");
	GHAssertTrue(response.ok, @"Failed to get an OK response when trying to delete a document");
	
}

- (void)testChangesAPI {
	NSLog(@"Testing Database : _changes api.\n");
	
	// To test the changes api we need to create/modify some documents
	
	NSDictionary *dic = nil;
	NSUInteger i, len = arc4random() % 10;
	
	for (i=0; i < len; i++) {
		// Create a dictionary		
		dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Hello World", @"name", nil];
		
		// Post the document
		[database postDictionary:dic];		
	}
	
	// Get the changes
	NSArray *changes = [database changesSince:0 filter:nil];
	
	// Check that the number of changes is equal to the number of documents created
	GHAssertTrue(len == [changes count], @"Number of changes doesn't match the number of created documents");
	
	// Get all documents
	NSArray *allDocs = [database allDocs];
	
	// Make some changes
	for (NSDictionary *dicDoc in allDocs) {
		// Get the document
		BSCouchDBDocument *doc = [database getDocument:[dicDoc objectForKey:@"id"] withRevisions:NO revision:nil];
		// Change it
		[doc setObject:@"Hello Again!" forKey:@"name"];
		// Update it
		[doc updateDocumentWithDictionary:doc.dictionary];
	}
	
	// Make some changes
	NSUInteger randLen = arc4random() % len;
	for (i=0; i<randLen; i++) {
		// Get the document
		BSCouchDBDocument *doc = [database getDocument:[[allDocs objectAtIndex:i] objectForKey:@"id"] withRevisions:NO revision:nil];
		// Change it
		[doc setObject:@"Hello Again!" forKey:@"name"];
		// Update it
		[doc updateDocumentWithDictionary:doc.dictionary];
	}	

	// Get new changes
	NSArray *newChanges = [database changesSince:((BSCouchDBChange *)[changes lastObject]).sequence filter:nil];
	
	// Check that the number of changes is equal to the number of documents created
	GHAssertTrue(len == [newChanges count], @"Number of changes doesn't match the number of modified documents");
		
}


@end
