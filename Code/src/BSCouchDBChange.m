//
//  BSCouchDBChange.m
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 16/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBChange.h"


@implementation BSCouchDBChange

@synthesize sequence;
@synthesize _id;
@synthesize changes;
@synthesize deleted;

+ (BSCouchDBChange *)changeWithDictionary:(NSDictionary *)dic {
	BSCouchDBChange *change = [[BSCouchDBChange alloc] init];
	change.sequence = [[dic objectForKey:@"seq"] integerValue];
	change._id = [dic objectForKey:@"id"];
	change.changes = [dic objectForKey:@"changes"];
	change.deleted = [dic objectForKey:@"deleted"] != nil ? [[dic objectForKey:@"deleted"] boolValue] : NO;
	
	return [change autorelease];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"seq: %d, id: %@", self.sequence, self._id];
}

@end
