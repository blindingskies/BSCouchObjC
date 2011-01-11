//
//  BSCouchDBResponse.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 11/01/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BSCouchDBResponse : NSObject {
@private
	BOOL ok;
	NSString *_id;
	NSString *_rev;
}

@property (nonatomic, readonly) BOOL ok;
@property (nonatomic, readonly) NSString *_id;
@property (nonatomic, readonly) NSString *_rev;


@end
