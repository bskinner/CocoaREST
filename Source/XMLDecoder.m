//
//  XMLDecoder.m
//  CocoaREST
//
//  Created by Blake Skinner on 5/12/10.
//  Copyright 2010. All rights reserved.
//

#import "XMLDecoder.h"

@interface XMLDecoder (NSXMLParserDelegate)
- (void)parserDidStartDocument:(NSXMLParser *)parser;
- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
@end

@interface NSMutableArray (StackAdditions)
- (id)popObject;
- (void)pushObject:(id)object;
- (id)peekObject;
@end

@implementation XMLDecoder
@synthesize respectsWhitespace = respectsWhitespace_;

- (id)init {
    self = [super init];
    if (self != nil) {
        self.respectsWhitespace = NO;
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (id)parse:(NSData *)data error:(NSError **)error {
    parser_ = [[[NSXMLParser alloc] initWithData:data] autorelease];
    [parser_ setDelegate: self];
    
    if ([parser_ parse]) {
        parser_ = nil;
        return [result_ autorelease];
    } else {
        if (error) {
            (*error) = [error_ autorelease];
        }
        error_ = nil;
        parser_ = nil;
        return nil;
    }
    
}
@end


@implementation XMLDecoder (NSXMLParserDelegate)
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    dictionaryStack_ = [[NSMutableArray alloc] init];
    keyStack_ = [[NSMutableArray alloc] init];
    [string_ release];
    string_ = nil;
    
    /* XML must have exactly 1 root element so this makes the top-level
     * dictionary easy.
     */
    [dictionaryStack_ pushObject:[NSMutableDictionary dictionary]];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    /*
     * Pop off the NSDictionary we pushed onto the stack in
     * parserDidStartDocument:. If everything worked right
     * this should the converted structure...
     */
    if (!error_) {
        result_ = [[dictionaryStack_ popObject] retain];
    } else {
        [result_ release];
        result_ = nil;
    }

    [dictionaryStack_ release];
    dictionaryStack_ = nil;
    [keyStack_ release];
    keyStack_ = nil;
    [string_ release];
    string_ = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([attributeDict count] > 0) {
        for (NSString* key in attributeDict) {
            [dict setObject:[attributeDict objectForKey:key]
                     forKey:[@"@" stringByAppendingString:key]];
        }
    }
    
    [keyStack_ pushObject:elementName];
    [dictionaryStack_ pushObject:dict];
    
    
    /* This is needed for proper character parsing.
     * See the comments in parser:foundCharacters:
     * for more information.
     */
    [string_ release];
    string_ = nil;
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSString *key = [keyStack_ popObject];
    NSMutableDictionary *container = [dictionaryStack_ popObject];
    NSMutableDictionary *parent = [dictionaryStack_ peekObject];
    
    id obj = [parent objectForKey:elementName];
    if (obj != nil) {
        /* Another element with the same name
         * in the same parent was already processed.
         * Change the data into an array (if it isn't
         * already one) and add the current elements
         * to it
         */
        NSMutableArray *array = nil;
        if ([obj isKindOfClass:[NSArray class]]) {
            array = (NSMutableArray*)obj;
        } else {
            array = [NSMutableArray array];
            [array addObject:obj];
        }
        
        if ([container count] == 0) {
            [array addObject: [NSNull null]];
        } else {
            [array addObject:container];
        }
        
        [parent setObject: array
                   forKey: key];
    } else {
        if (([container count] == 1) && ([container objectForKey:@"#text"] != nil)) {
            /* The current dictionary only contains a single text element so I can
             * ditch the '#text' key. There's probably a better way to do this.
             */
            [parent setObject: [container objectForKey:[[container allKeys] objectAtIndex:0]]
                       forKey: key];
        } else if ([container count] > 0) {
            [parent setObject: container
                       forKey: key];
        } else {
            [parent setObject: [NSNull null]
                       forKey: key];
        }
    }
    
    /* This is needed for proper character parsing.
     * See the comments in parser:foundCharacters:
     * for more information.
     */
    [string_ release];
    string_ = nil;
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString {
    if (!respectsWhitespace_) {
        aString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if ([aString length] == 0) {
        return;
    }
    
    /* I am assuming that the start/closing elements also
     * act as delimiters when parsing the text nodes. If
     * the string is not cleared out at end of the didStartElement
     * and didEndElement methods the contents of all the
     * child text nodes of an element will be concatenated.
     * For example:
     *  <elem>some<elem2/>text</elem> will be: "sometest"
     *  instead of ("some","text")
     */
    if (string_ != nil) {
        [string_ appendString:aString];
    } else {
        NSMutableDictionary *container = [dictionaryStack_ peekObject];
        
        string_ = [[NSMutableString alloc] initWithString: aString];
        
        id obj = [container objectForKey:@"#text"];
        if (obj == nil) {
            [container setObject: string_
                       forKey: @"#text"];
        } else {
            NSMutableArray *array = nil;
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                array = (NSMutableArray*)obj;
            } else {
                array = [NSMutableArray array];
                [array addObject:obj];
            }
            
            [array addObject: string_];
            [container setObject:array
                          forKey:@"#text"];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    error_ = (NSError*)[parseError copy];
}
@end


@implementation NSMutableArray (StackAdditions)
- (id)popObject {
    if ([self count] == 0) {
        return nil;
    }
    
    id obj = [self lastObject];
    [self removeLastObject];
    return obj;
}

- (void)pushObject:(id)object {
    if (object == nil) {
        return;
    }
    
    [self addObject:object];
}

- (id)peekObject {
    return [self lastObject];
}
@end