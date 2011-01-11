//
//  DocumentTest.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GHUnit/GHUnit.h>
#import <BSCouchObjC/BSCouchObjC.h>

@interface DocumentTest : GHTestCase {
@private
    BSCouchDBDocument *document;
}

@end

@implementation DocumentTest

- (void)setUp {
    [super setUp];    
    
    // Create a server object
    BSCouchDBServer *server = [[BSCouchDBServer alloc] init];
    
	NSString *databaseName = [NSString stringWithFormat:@"testdb%u", arc4random()];
	server.login = @"administrator";
	server.password = @"password";
	GHAssertTrue([server createDatabase:databaseName], @"Call failed to create databases. [%@]", databaseName);
    // Create the database
    BSCouchDBDatabase *database = [[BSCouchDBDatabase alloc] initWithServer:server name:databaseName];
    
    // Create a fake document
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Hello World", @"name", nil];
    
    // Post the document
    BSCouchDBResponse *response = [database postDictionary:dic];
    GHAssertNotNil(response, @"Failed to receive a valid HTTP response when posting a new document.");
    GHAssertTrue(response.ok, @"Failed to post a new document despite getting valid HTTP Response.");
    GHAssertNotNil(response._id, @"BSCouchDBResponse does not contain an identifier");
    GHAssertNotNil(response._rev, @"BSCouchDBResponse does not contain an revision");
    
    // Get the document
    document = [database getDocument:response._id withRevisions:NO revision:nil];
    
    // Release the server (it's retained by the database)
    [server release];
    // Release the database (it's retained by the document)
    [database release];
}

- (void)tearDown {
    // Tear-down code here.
    
   	// Try and delete the database
	GHAssertTrue([document.database.server deleteDatabase:document.database.name], @"Failed to delete the created database.");	
    [document release];    
    [super tearDown];
}

@end
