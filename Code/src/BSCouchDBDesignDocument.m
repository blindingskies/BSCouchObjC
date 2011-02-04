//
//  BSCouchDBDesignDocument.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 03/02/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDesignDocument.h"
#import "BSCouchObjC.h"

@implementation BSCouchDBDesignDocument

- (void)dealloc {
	
	
	[super dealloc];	
}

+ (BSCouchDBDesignDocument *)documentWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase {
	return [[[BSCouchDBDesignDocument alloc] initWithDictionary:otherDictionary database:aDatabase] autorelease];
}


- (id)initWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase {
	self = [super initWithDictionary:otherDictionary database:aDatabase];
	if (self) {
		// Perform any design document specific initialisation here
		
	}
	return self;
}


#pragma mark -
#pragma mark Retieve information

// Return an array of strings of view names
- (NSArray *)viewNames {
	
	NSMutableArray *viewNames = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:COUCH_KEY_VIEWS] allKeys]];
	NSString *prefix = [NSString stringWithFormat:@"%@/_view/", self._id];
	NSUInteger i, len = [viewNames count];
	for(i=0; i<len; i++) {
		// Add the prefix
		NSString *obj = [viewNames objectAtIndex:i];
		[viewNames replaceObjectAtIndex:i withObject:[prefix stringByAppendingString:(NSString *)obj]];
	}
	
	return viewNames;
}


@end
