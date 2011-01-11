//
//  BSCouchDBResponse.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBResponse.h"


@implementation BSCouchDBResponse

@synthesize ok;
@synthesize _id;
@synthesize _rev;

- (id)initWithDictionary:(NSDictionary *)dic {
	self = [super init];
	if (self) {
		ok = [[dic objectForKey:@"ok"] boolValue];
		_id = [[dic objectForKey:@"_id"] copy];
		_rev = [[dic objectForKey:@"_rev"] copy];
	}
	return self;
}

- (void)dealloc {
	[_id release];
	[_rev release];
	[super release];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"\nCouchDB Response:\n\t _ok = %i\n\t_id = %@\n\t_rev = %@\n", ok, _id, _rev];
}

@end
