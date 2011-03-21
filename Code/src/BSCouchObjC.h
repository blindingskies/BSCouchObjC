/*
 *  BSCouchObjC.h
 *  BSCouchObjC
 *
 *  Created by Daniel Thorpe on 07/01/2011.
 *  Copyright 2011 Blinding Skies Limited. All rights reserved.
 *
 */

#define COUCH_KEY_LANGUAGE         @"language"
#define COUCH_KEY_LANGUAGE_DEFAULT @"javascript"
#define COUCH_KEY_DESIGN_PREFIX    @"_design/"
#define COUCH_KEY_VIEWS            @"views"
#define COUCH_KEY_MAP              @"map"
#define COUCH_KEY_REDUCE           @"reduce"
#define COUCH_KEY_ID               @"_id"
#define COUCH_KEY_REV              @"_rev"
#define COUCH_KEY_REVS_INFO        @"_revs_info"
#define COUCH_KEY_REVISIONS        @"_revisions"
#define COUCH_KEY_IDS              @"ids"
#define COUCH_VIEW_SLOW            @"_slow_view"
#define COUCH_VIEW_ALL             @"_all_docs"

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_EMBEDDED)

// OS X only headers
#import "JSON.h"
#import "ASIHTTPRequestFramework.h"

#else

// iOS only headers
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "SBJsonStreamWriter.h"
#import "SBJsonStreamParser.h"
#import "SBJsonStreamParserAdapter.h"
#import "NSObject+JSON.h"

#import "../vendor/asi-http-request/Classes/ASIHTTPRequestConfig.h"
#import "../vendor/asi-http-request/Classes/ASIHTTPRequestDelegate.h"
#import "../vendor/asi-http-request/Classes/ASIProgressDelegate.h"
#import "../vendor/asi-http-request/Classes/ASICacheDelegate.h"
#import "../vendor/asi-http-request/Classes/ASIHTTPRequest.h"
#import "../vendor/asi-http-request/Classes/ASIDataCompressor.h"
#import "../vendor/asi-http-request/Classes/ASIDataDecompressor.h"
#import "../vendor/asi-http-request/Classes/ASIFormDataRequest.h"
#import "../vendor/asi-http-request/Classes/ASIInputStream.h"
#import "../vendor/asi-http-request/Classes/ASIFormDataRequest.h"
#import "../vendor/asi-http-request/Classes/ASINetworkQueue.h"
#import "../vendor/asi-http-request/Classes/ASIDownloadCache.h"
#import "../vendor/asi-http-request/Classes/ASIAuthenticationDialog.h"
#import "../vendor/asi-http-request/External/Reachability/Reachability.h"

#endif

#import "BSCouchDBServer.h"
#import "BSCouchDBDatabase.h"
#import "BSCouchDBChange.h"
#import "BSCouchDBDocument.h"
#import "BSCouchDBDesignDocument.h"
#import "BSCouchDBResponse.h"
#import "BSCouchDBReplicationResponse.h"



