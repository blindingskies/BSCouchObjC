//
//  BSCouchDBRequestDelegate.h
//  BSCouchObjC
//
//  Created by Daniel Thorpe on 31/03/2011.
//  Copyright 2011 Blinding Skies Limited. All rights reserved.
//

// The block support of this class was originally written by mloop's fork on github 

#import "BSCouchObjC.h"

@interface BSCouchDBRequestDelegate : NSObject <ASIHTTPRequestDelegate> {
@private
	void (^sBlock)(ASIHTTPRequest *);
	void (^fBlock)(ASIHTTPRequest *);	
}

- (id)initWithSuccessBlock:(void (^)(ASIHTTPRequest *))successBlock failureBlock:(void (^)(ASIHTTPRequest *))failureBlock;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
