//
//  BSCouchDBDesignDocument.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 03/02/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDesignDocument.h"


@implementation BSCouchDBDesignDocument

- (void)dealloc {
    [dictionary release];// self.dictionary = nil; 
	[database release];// self.database = nil; 
	[super dealloc];	
}

+ (BSCouchDBDesignDocument *)documentWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase {
	return [[[BSCouchDBDesignDocument alloc] initWithDictionary:otherDictionary database:aDatabase] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase {
	self = [super initWithDictionary:otherDictionary database:aDatabase];
	if (self) {

		// Extract views and filters from the design documents
		// in the future we can support more things.
		
		// Get the dictionary of views from the design document
		NSDictionary *rawViews = [self.dictionary valueForKey:COUCH_KEY_VIEWS];
		
		// Iterate though the views, and for each one create a BSCouchDBView object,
		// which we store in a member dictionary
		for (NSString *viewName in [rawViews allKeys]) {
			
		}
		
	}
	return self;
}




@end
