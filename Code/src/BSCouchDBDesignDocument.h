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

@end
