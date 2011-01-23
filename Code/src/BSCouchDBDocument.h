//
//  BSCouchDBDocument.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

@class BSCouchDBDatabase;
@class BSCouchDBResponse;

@interface BSCouchDBDocument : NSObject {
@private
    NSMutableDictionary *dictionary;
	BSCouchDBDatabase *database;
}

@property (nonatomic, readwrite, retain) NSMutableDictionary *dictionary;
@property (nonatomic, readwrite, retain) BSCouchDBDatabase *database;

@property (nonatomic, readonly) NSString *_id;
@property (nonatomic, readonly) NSString *_rev;

+ (BSCouchDBDocument *)documentWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase;
- (id)initWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase;

#pragma mark Dictionary methods

- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;

#pragma mark Revision Information

// Update the revision
- (void)setRevision:(NSString *)newRev;

// Returns an array of NSString objects for each revision
- (NSArray *)revisions;

// Returns the prevision revision identifier as a NSString
- (NSString *)previousRevision;

// Returns the index of this revision of the document
- (NSInteger)revisionIndex;

#pragma mark Document updates

// Updates the document using the objects in the dictionary, which replace or are added
// to the original contents.
- (BSCouchDBResponse *)updateDocumentWithDictionary:(NSDictionary *)dic;




@end
