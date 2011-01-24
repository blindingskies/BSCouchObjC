//
//  BSCouchDBReplicationResponse.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 12/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBReplicationResponse.h"
#import "JSON.h"

@implementation BSCouchDBReplicationResponse

@synthesize dic;

@dynamic ok;
@dynamic source_last_seq;
@dynamic session_id;
@dynamic history;

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
	self = [super init];
	if (self) {
		self.dic = otherDictionary;
	}
	return self;
}

// Convienience
+ (BSCouchDBReplicationResponse *)responseWithJSON:(NSString *)json {
	BSCouchDBReplicationResponse *response = [[BSCouchDBReplicationResponse alloc] initWithDictionary:[json JSONValue]];
	return [response autorelease];
}

- (BOOL)ok {
	return [[self.dic objectForKey:@"ok"] boolValue];
}

- (NSUInteger)source_last_seq {
	return [[self.dic objectForKey:@"source_last_seq"] integerValue];
}

- (NSString *)session_id {
	return [self.dic objectForKey:@"session_id"];
}

- (NSArray *)history {
	return [self.dic objectForKey:@"history"];
}

@end
