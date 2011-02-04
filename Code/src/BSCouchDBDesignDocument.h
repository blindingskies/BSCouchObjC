//
//  BSCouchDBDesignDocument.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 03/02/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import "BSCouchDBDocument.h"

@interface BSCouchDBDesignDocument : BSCouchDBDocument {

}

+ (BSCouchDBDesignDocument *)documentWithDictionary:(NSDictionary *)otherDictionary database:(BSCouchDBDatabase *)aDatabase;


#pragma mark Retieve information

// Return an array of strings of view names, these are in the form
// <design document _id>/_view/<view name>, where the design document
// _id is in the form _design/<design document domain>
- (NSArray *)viewNames;

@end
