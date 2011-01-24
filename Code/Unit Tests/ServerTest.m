//
//  ServerTest.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <BSCouchObjC/BSCouchObjC.h>

@interface ServerTest : GHTestCase {
@private
	BSCouchDBServer *server;
}

@end

@implementation ServerTest

- (void)setUp {
	server = [[BSCouchDBServer alloc] init];
	server.login = @"administrator";
	server.password = @"password";
}

- (void)tearDown {
	[server release];
}

- (void)testSupportedVersion {
    NSLog(@"Testing Server : supported version");    
    NSString *version = [server version];
    NSArray *v = [version componentsSeparatedByString: @"."];
    GHAssertTrue([[v objectAtIndex: 0] integerValue] >= 1 || [[v objectAtIndex: 1] integerValue] >= 8, @"CouchDB version %@ not supported", version);
}

- (void)testAllDatabases {
    NSLog(@"Testing Server : all databases");  
	server.login = @"administrator";
	server.password = @"password";
	NSArray *allDatabases = [server allDatabases];
	NSLog(@"allDatabases: %@", [allDatabases description]);
}

- (void)testLogin {
    NSLog(@"Testing Server : login");    
	GHAssertTrue([server loginUsingName:@"administrator" andPassword:@"password"], @"Failed to log into server");
}

- (void)testDatabaseCreateAndDelete {
    NSLog(@"Testing Server : database creation & deletion");
	// Get a random name
	NSString *databaseName = [NSString stringWithFormat:@"testdb%u", arc4random()];
	server.login = @"administrator";
	server.password = @"password";
	GHAssertTrue([server createDatabase:databaseName], @"Call failed to create databases. [%@]", databaseName);
	// List all the databases
	NSArray *listOfDatabases = [server allDatabases];
	GHAssertTrue([listOfDatabases containsObject:databaseName], @"Couldn't find the created database");
	// Try and delete the database
	GHAssertTrue([server deleteDatabase:databaseName], @"Tried to delete the created database");	
	server.login = nil;
	server.login = nil;	
}

- (void)testUserCreation {
	NSLog(@"Testing Server : create user");
	
	// Authenticate the user
	server.login = @"administrator";
	server.password = @"password";

	// Create a username and password
	NSString *username = [NSString stringWithFormat:@"user%u", arc4random()];
	NSString *password = @"mypassword";
	
	// Create a new user
	BSCouchDBResponse *response = [server createUser:username password:password];
	GHAssertTrue(response.ok, @"Failed to create a user.");
	
	// Try to login with the user
	BOOL ok = [server loginUsingName:username andPassword:password];
	GHAssertTrue(ok, @"Failed to login as the newly created user.");
	
	server.login = nil;
	server.password = nil;
}

- (void)testReplication {
	NSLog(@"Testing Server : replication");

	// Authenticate the server
	server.login = @"administrator";
	server.password = @"password";
		
	// Create a new database
	// Get a random name
	NSString *sourceName = [NSString stringWithFormat:@"testdb%u", arc4random()];
	GHAssertTrue([server createDatabase:sourceName], @"Call failed to create source database. [%@]", sourceName);
	
	// Add a document to the source database
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Hello World", @"name", nil];
    
    // Post the document
	BSCouchDBDatabase *db = [server database:sourceName];
    BSCouchDBResponse *response = [db postDictionary:dic];
    GHAssertNotNil(response, @"Failed to receive a valid HTTP response when posting a new document.");
    GHAssertTrue(response.ok, @"Failed to post a new document despite getting valid HTTP Response.");
    GHAssertNotNil(response._id, @"BSCouchDBResponse does not contain an identifier");
    GHAssertNotNil(response._rev, @"BSCouchDBResponse does not contain an revision");
	
	// Create a target database
	NSString *targetName = [NSString stringWithFormat:@"testdb%u", arc4random()];
	
	GHAssertTrue([server createDatabase:targetName], @"Call failed to create target database. [%@]", targetName);
		
	// Replicate the database
	BSCouchDBReplicationResponse *replicationResponse = [server replicateFrom:sourceName to:targetName docs:nil filter:nil params:nil];
	GHAssertTrue(replicationResponse.ok, @"Failed to replicate %@ to %@.", sourceName, targetName);
	GHAssertNotNil(replicationResponse.session_id, @"Failed to provide a session id.");
	GHAssertNotNil(replicationResponse.history, @"Failed to provide a history.");
	
}

@end
