//
//  NSStringAdditions.m
//  Covariates
//
//  Created by Daniel Thorpe on 09/03/2009.
//  Copyright 2009 Blinding Skies Limited. All rights reserved.
//

#import "NSStringAdditions.h"
#import <CommonCrypto/CommonDigest.h>

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import <openssl/md5.h>
#endif

@implementation NSString (NSStringAdditions)

+ (NSString *)stringWithString:(NSString *)original repeatedNTimes:(NSUInteger)times {
	// Capacity does not limit the length, it's just an initial capacity
	NSMutableString *result = [NSMutableString stringWithCapacity:[original length] * times]; 

	NSUInteger i;
	for(i=0; i<times; i++)
		[result appendString:original];
	return result;
}

+ (NSString *)stringWithSuffixForNumber:(NSUInteger)i {
	NSUInteger n = i % 100;
	if((n > 3) && (n < 21))
		return [@"th" autorelease];
	switch (n % 10) {
		case 1: return [@"st" autorelease];
		case 2: return [@"nd" autorelease];
		case 3: return [@"rd" autorelease];	
		default:
			return [@"th" autorelease];;
	}
}

+ (NSString *)stringWithEasyReadingTimeLapse:(NSTimeInterval)secondsSinceEpoch {
	NSDate *then = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)secondsSinceEpoch];
	NSTimeInterval lapseSinceThen = [then timeIntervalSinceNow];
	NSTimeInterval tmp;
	BOOL inThePast = YES;
	if(lapseSinceThen > 0) {
		inThePast = NO;
	}
	
	NSUInteger number;
	NSString *quantity = nil;
	
	// Get the modulus
	lapseSinceThen = fabs(lapseSinceThen);
	if(lapseSinceThen < 60) {
		return inThePast ? @"just now" : @"coming up";
	} else {
		tmp = lapseSinceThen / 60.0; // Get it in minutes
		if(tmp > 60) {
			// It's longer than an hour
			tmp = lapseSinceThen / 3600.0; // Calculate it in hours
			if(tmp > 24) {
				// It's longer than a day
				tmp = lapseSinceThen / 86400.0; // Calculate it in days
				if(tmp > 7) {
					// It's longer than a week
					number = round(tmp);
					quantity = @"weeks";					
				} else {
					// It's a number of days
					if(tmp < 1.5) {
						return inThePast ? @"yesterday" : @"tomorrow";
					} else if (tmp < 2.5) {
						return inThePast ? @"a couple of days ago" : @"a couple of days from now";
					} else {
						number = round(tmp);
						quantity = @"days";
					}				
				}
			} else {
				// It's more than one hour, less than a day
				if(tmp < 1.5) {
					return inThePast ? @"about an hour ago" : @"about an hour from now";
				} else if (tmp < 2.5) {
					return inThePast ? @"a couple of hours ago" : @"a couple of hours from now";
				} else {
					number = round(tmp);
					quantity = @"hours";
				}
			}
		} else {
			// It's less than an hour
			if(tmp < 5) {
				return inThePast ? @"a few minutes ago" : @"a few minutes from now";
			} else if ((tmp > 12.5) && (tmp < 17.5)) {
				return inThePast ? @"about quarter of an hour ago" : @"about quarter of an hour from now";
			} else if ((tmp > 27.5) && (tmp < 32.5)) {
				return inThePast ? @"about half an hour ago" : @"about half an hour from now";
			} else {
				number = round(tmp);
				quantity = @"minutes";
			}
		}		
	}

	// If we're still here we've got numbers and quantities
	
	return [NSString stringWithFormat:@"%d %@ %@", number, quantity, inThePast ? @"ago" : @"from now"];
	
	return nil;
}

- (void)appendToFile:(NSString *)filename usingEncoding:(NSStringEncoding)encoding {
	NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filename];
	[fh seekToEndOfFile];
	[fh writeData:[self dataUsingEncoding:encoding]];
	[fh closeFile];
}

- (void)createDirectory {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if(![fileManager fileExistsAtPath:self isDirectory:&isDirectory]) {
		NSError *error;
		[fileManager createDirectoryAtPath:self withIntermediateDirectories:NO attributes:nil error:&error];
	}				
}

- (NSString *)sha1 {
	NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(data.bytes, data.length, digest);
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
	NSInteger i = 0;
	for(i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}	
	return output;
}

- (NSString *)md5 {

	NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	uint8_t digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5(data.bytes, data.length, digest);
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	NSInteger i = 0;
	for(i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}	
	return output;
}

@end
