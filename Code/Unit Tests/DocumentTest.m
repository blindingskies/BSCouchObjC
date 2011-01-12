//
//  DocumentTest.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <BSCouchObjC/BSCouchObjC.h>

@interface DocumentTest : GHTestCase {
@private
    BSCouchDBDocument *document;
}

@end

@implementation DocumentTest

- (void)setUp {
    NSLog(@"Setting up DocumentTest");
    
    // Create a server object
    BSCouchDBServer *server = [[BSCouchDBServer alloc] init];
    
	NSString *databaseName = [NSString stringWithFormat:@"testdb%u", arc4random()];
	server.login = @"administrator";
	server.password = @"password";
	GHAssertTrue([server createDatabase:databaseName], @"Call failed to create databases. [%@]", databaseName);
    // Create the database
    BSCouchDBDatabase *database = [[BSCouchDBDatabase alloc] initWithServer:server name:databaseName];
    
    // Release the server (it's retained by the database)
    [server release];
    
    // Create a fake document
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Hello World", @"name", nil];
    
    // Post the document
    BSCouchDBResponse *response = [database postDictionary:dic];
    GHAssertNotNil(response, @"Failed to receive a valid HTTP response when posting a new document.");
    GHAssertTrue(response.ok, @"Failed to post a new document despite getting valid HTTP Response.");
    GHAssertNotNil(response._id, @"BSCouchDBResponse does not contain an identifier");
    GHAssertNotNil(response._rev, @"BSCouchDBResponse does not contain an revision");
    
    // Get the document
    document = [[database getDocument:response._id withRevisions:NO revision:nil] retain];
    
    // Release the database (it's retained by the document)
    [database release];    
}

- (void)tearDown {
    // Tear-down code here.
    NSLog(@"Tearing down DocumentTest");    
   	// Try and delete the database
    BSCouchDBServer *server = document.database.server;
    NSString *db = document.database.name;    
	GHAssertTrue([server deleteDatabase:db], @"Failed to delete the created database.");	
    [document release];
}

- (void)testIdentity {
    NSLog(@"Testing Document : identity");
    GHAssertTrue([document._id isEqualToString:[document objectForKey:COUCH_KEY_ID]], @"The identifier returned by the instance property does not match the object in the document's dictionary.");
}

- (void)testDocumentUpdate {
    NSLog(@"Testing Document : updates");    
    // Keep the old revision
    NSString *oldRev = [document._rev copy];
    
    // We're going to update the document a number of times
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         document._id, COUCH_KEY_ID,
                         @"Hello Again", @"name", 
                         [NSNumber numberWithDouble:M_PI], @"pi", 
                         nil];
    
    BSCouchDBResponse *response = [document updateDocumentWithDictionary:dic];
    GHAssertNotNil(response, @"Failed to receive a valid HTTP response when updating an existing document.");
    GHAssertTrue(response.ok, @"Failed to updating an existing document despite getting valid HTTP Response.");    
    // Test to make sure that the new revision is not the same as the old revision
    GHAssertFalse([oldRev isEqualToString:document._rev], @"The document's revision hasn't changed, despite it being updated");

    // Release the old revision
    [oldRev release];
    
    // Get the document again
    BSCouchDBDocument *doc = [document.database getDocument:document._id withRevisions:YES revision:nil];
    GHAssertNotNil(doc, @"Failed to GET the document after just updating it.");
    GHAssertTrue([[doc objectForKey:@"name"] isEqualToString:@"Hello Again"], @"Document contents do not match the updated dictionary");
    GHAssertTrue([[doc objectForKey:@"pi"] doubleValue] == 3.14159, @"Document contents do not match the updated dictionary");
	
}


@end
