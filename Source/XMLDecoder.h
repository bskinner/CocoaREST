//
//  XMLDecoder.h
//  certapi-test
//
//  Created by Blake Skinner on 5/12/10.
//  Copyright 2010. All rights reserved.
//
//

#import <Cocoa/Cocoa.h>

/*!
 *  @class XMLDecoder
 *  @abstract This class parses XML and converts it into a set of NSDictionary/NSArray/NSString
 *
 */
@interface XMLDecoder : NSObject {
    BOOL respectsWhitespace_;
	NSMutableString *string_;
    
	id result_;
    NSError *error_;

    NSMutableArray *dictionaryStack_;
	NSMutableArray *keyStack_;
    NSXMLParser *parser_;
}
@property BOOL respectsWhitespace;

- (id)parse:(NSData *)data error:(NSError **)error;
@end

