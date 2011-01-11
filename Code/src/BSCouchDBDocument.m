//
//  BSCouchDBDocument.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDocument.h"
#import "BSCouchDBDatabase.h"

@implementation BSCouchDBDocument

@synthesize dictionary;
@synthesize database;

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
	self.database = nil; [database release];
	[super dealloc];	
}

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
#pragma mark Revision Information

// Returns this revision identifier
- (NSString *)revision {
	return [self.dictionary objectForKey:@"_rev"];
}

// Returns an array of NSString objects for each revision
- (NSArray *)revisions {
	return nil;
}

// Returns the prevision revision identifier as a NSString
- (NSString *)previousRevision {
	return nil;	
}

// Returns the index of this revision of the document
- (NSInteger)revisionIndex {
	return 0;	
}


@end
