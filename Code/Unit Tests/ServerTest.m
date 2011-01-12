//
//  ServerTest.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 07/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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

@end
