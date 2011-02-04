//
//  BSCouchDBDocument.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDocument.h"
#import "BSCouchObjC.h"

@implementation BSCouchDBDocument

@synthesize dictionary;
@synthesize database;

@dynamic _id;
@dynamic _rev;

+ (BSCouchDBDocument *)documentWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase {
	return [[[BSCouchDBDocument alloc] initWithDictionary:otherDictionary database:aDatabase] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase {
	self = [super init];
	if (self) {
        self.dictionary = [NSMutableDictionary dictionaryWithDictionary:otherDictionary];
		self.database = aDatabase;
	}
	return self;
}

- (void)dealloc {
    [dictionary release];// self.dictionary = nil; 
	[database release];// self.database = nil; 
	[super dealloc];	
}

- (NSString *)description {
	return [self.dictionary description];
}

#pragma mark -
#pragma mark Dictionary methods

- (void)setObject:(id)anObject forKey:(id)aKey {
    [self willChangeValueForKey:aKey];
    [self.dictionary setObject:anObject forKey:aKey];
    [self didChangeValueForKey:aKey];
}

- (id)objectForKey:(id)aKey {
    return [self.dictionary objectForKey:aKey];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation setTarget:self.dictionary];
    [invocation invoke];
}

#pragma mark -
#pragma mark Dynamic methods

- (NSString *)_id {
    return [self.dictionary objectForKey:COUCH_KEY_ID];
}

- (NSString *)_rev {
    return [self.dictionary objectForKey:COUCH_KEY_REV];        
}


#pragma mark -
#pragma mark Revision Information

// Update the revision
- (void)setRevision:(NSString *)newRev {
    // Update the revision(s)
    [self setObject:newRev forKey:COUCH_KEY_REV];
    // Delete the revisions as it's now out of date, but we're not going to automatically refresh it
    [self.dictionary removeObjectForKey:COUCH_KEY_REVISIONS];	
}

// Returns an array of NSString objects for each revision
- (NSArray *)revisions {
	return [[self.dictionary objectForKey:COUCH_KEY_REVISIONS] objectForKey:@"ids"];
}

// Returns the prevision revision identifier as a NSString
- (NSString *)previousRevision {
	return nil;	
}

// Returns the index of this revision of the document
- (NSInteger)revisionIndex {
	return 0;	
}

#pragma mark -
#pragma mark Document updates

- (BSCouchDBResponse *)updateDocumentWithDictionary:(NSDictionary *)dic {
    NSAssert([dic objectForKey:COUCH_KEY_ID] != nil, @"The update dictionary doesn't contain an identifier");
    NSAssert([[dic objectForKey:COUCH_KEY_ID] isEqualToString:[self objectForKey:COUCH_KEY_ID]], @"The update dictionary's identifier doesn't match the documents.");
    
    // Update the dictionary
    [self.dictionary addEntriesFromDictionary:dic];
    
    // Put the 'new' document on the database
    BSCouchDBResponse *response = [self.database putDocument:self.dictionary named:self._id];
    
    // Update the revision(s)
	[self setRevision:response._rev];
        
    // Return the response
    return response;
}

@end
