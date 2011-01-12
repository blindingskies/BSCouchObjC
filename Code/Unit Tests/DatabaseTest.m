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

- (void)testDocumentionCreation {
    NSLog(@"Testing Database : document creation");
    
    // Create a fake document
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Hello World", @"name", nil];
    
    // Post the document
    BSCouchDBResponse *response = [database postDictionary:dic];
    GHAssertNotNil(response, 
                   @"Failed to receive a valid HTTP response when posting a new document.");
    GHAssertTrue(response.ok, 
                 @"Failed to post a new document despite getting valid HTTP Response.");
    GHAssertNotNil(response._id, 
                   @"BSCouchDBResponse does not contain an identifier");
    GHAssertNotNil(response._rev, 
                   @"BSCouchDBResponse does not contain an revision");
    
    // Now we need to retrieve the document and make sure that we've got hello world
    BSCouchDBDocument *doc = [database getDocument:response._id withRevisions:NO revision:nil];
    GHAssertNotNil(doc, 
                   @"Failed to GET the newly created document, named %@", response._id);
    GHAssertTrue([[doc objectForKey:@"name"] isEqualToString:@"Hello World"], 
                 @"Document contents do not match the original dictionary");
    
}

@end
