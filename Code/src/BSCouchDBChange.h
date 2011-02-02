//
//  BSCouchDBChange.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 16/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//


@interface BSCouchDBChange : NSObject {
@private
	NSUInteger sequence;
	NSString *_id;
	NSArray *changes;
	BOOL deleted;
}

@property (nonatomic, readwrite) NSUInteger sequence;
@property (nonatomic, readwrite, copy) NSString *_id;
@property (nonatomic, readwrite, copy) NSArray *changes;
@property (nonatomic, readwrite) BOOL deleted;


+ (BSCouchDBChange *)changeWithDictionary:(NSDictionary *)dic;

@end
