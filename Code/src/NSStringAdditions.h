//
//  NSStringAdditions.h
//  Covariates
//
//  Created by Daniel Thorpe on 09/03/2009.
//  Copyright 2009 Blinding Skies Limited. All rights reserved.
//

@interface NSString (NSStringAdditions)

+ (NSString *)stringWithString:(NSString *)original repeatedNTimes:(NSUInteger)times;
+ (NSString *)stringWithSuffixForNumber:(NSUInteger)i;
+ (NSString *)stringWithEasyReadingTimeLapse:(NSTimeInterval)secondsSinceEpoch;
- (void)appendToFile:(NSString *)filename usingEncoding:(NSStringEncoding)encoding;
- (void)createDirectory;

- (NSString *)sha1;
- (NSString *)md5;


@end


