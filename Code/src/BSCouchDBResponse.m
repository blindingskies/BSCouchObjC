//
//  BSCouchDBResponse.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBResponse.h"
#import "BSCouchObjC.h"

@implementation BSCouchDBResponse

@synthesize ok;
@synthesize _id;
@synthesize _rev;
@synthesize dictionary;

- (id)initWithDictionary:(NSDictionary *)dic {
	self = [super init];
	if (self) {
		ok = [[dic objectForKey:@"ok"] boolValue];
		_id = [[dic objectForKey:@"id"] copy];
		_rev = [[dic objectForKey:@"rev"] copy];
		// You can send POST requests to CouchDB views, which means that the results will
		// need to be accessed through here.
		dictionary = [dic copy];
	}
	return self;
}

// Convienience
+ (BSCouchDBResponse *)responseWithJSON:(NSString *)json {
	BSCouchDBResponse *response = [[BSCouchDBResponse alloc] initWithDictionary:[json JSONValue]];
	return [response autorelease];
}

- (void)dealloc {
	[_id release];
	[_rev release];
	[dictionary release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"\nCouchDB Response:\n\t _ok = %i\n\t_id = %@\n\t_rev = %@\n", ok, _id, _rev];
}

@end
