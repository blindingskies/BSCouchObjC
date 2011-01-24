//
//  BSCouchDBReplicationResponse.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 12/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//


@interface BSCouchDBReplicationResponse : NSObject {
@private
	NSDictionary *dic;	
}

@property (nonatomic, readwrite, retain) NSDictionary *dic;
@property (nonatomic, readonly) BOOL ok;
@property (nonatomic, readonly) NSUInteger source_last_seq;
@property (nonatomic, readonly) NSString *session_id;
@property (nonatomic, readonly) NSArray *history;

// Initializer
- (id)initWithDictionary:(NSDictionary *)otherDictionary;

// Convienience
+ (BSCouchDBReplicationResponse *)responseWithJSON:(NSString *)json;

@end
