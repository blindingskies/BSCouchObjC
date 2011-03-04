//
//  BSCouchDBView.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 04/02/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//


@interface BSCouchDBView : NSObject {
@private
	NSString *name;
	NSString *map;
	NSString *reduce;
}

@property (nonatomic, readwrite, retain) NSString *name;
@property (nonatomic, readwrite, retain) NSString *map;
@property (nonatomic, readwrite, retain) NSString *reduce;


@end
