//
//  CSimpleHTMLParser.m
//  CoreText
//
//  Created by Jonathan Wight on 07/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CSimpleHTMLParser.h"

@implementation CSimpleHTMLParser

@synthesize openTagHandler;
@synthesize closeTagHandler;
@synthesize textHandler;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        openTagHandler = ^(NSString *tag, NSArray *tagStack) {};
        closeTagHandler = ^(NSString *tag, NSArray *tagStack) {};
        textHandler = ^(NSString *text, NSArray *tagStack) {};
		}
	return(self);
	}


- (BOOL)parseString:(NSString *)inString error:(NSError **)outError
    {
    void (^theErrorBlock)(NSString *reason) = ^(NSString *reason) { 
        if (outError)
            {
            NSDictionary *theDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                reason, NSLocalizedDescriptionKey,
                NULL];
            *outError = [NSError errorWithDomain:@"TODO" code:-1 userInfo:theDictionary];
            }
        };
    
    
    
    NSMutableCharacterSet *theCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
    [theCharacterSet addCharactersInString:@"<&"];
    [theCharacterSet invert];

    NSScanner *theScanner = [[NSScanner alloc] initWithString:inString];
    theScanner.charactersToBeSkipped = NULL;

    NSMutableArray *theTagStack = [NSMutableArray array];

    __block NSMutableString *theString = [NSMutableString string]; 

    BOOL theLastCharacterWasWhitespace = NO;

    while ([theScanner isAtEnd] == NO)
        {
        NSString *theRun = NULL;

        NSString *theTag = NULL;

        if ([theScanner scanString:@"</" intoString:NULL] == YES)
            {
            if ([theScanner scanUpToString:@">" intoString:&theTag] == NO)
                {
                theErrorBlock(@"</ not followed by >");
                return(NO);
                }
            if ([theScanner scanString:@">" intoString:NULL] == NO)
                {
                theErrorBlock(@"</ not followed by >");
                return(NO);
                }

            if (theString.length > 0)
                {
                theLastCharacterWasWhitespace = [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[theString characterAtIndex:theString.length - 1]];
                self.textHandler(theString, theTagStack);
                }
            theString = [NSMutableString string]; 

            self.closeTagHandler(theTag, theTagStack);

            NSUInteger theIndex = [theTagStack indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) { return([obj isEqualToString:theTag]); }];
            if (theIndex == NSNotFound)
                {
                theErrorBlock(@"Stack underflow");
                return(NO);
                }
            
            [theTagStack removeObjectsInRange:(NSRange){ .location = theIndex, .length = theTagStack.count - theIndex }];
            
            }
        else if ([theScanner scanString:@"<" intoString:NULL] == YES)
            {
            if ([theScanner scanUpToString:@">" intoString:&theTag] == NO)
                {
                theErrorBlock(@"< not followed by >");
                return(NO);
                }
            if ([theScanner scanString:@">" intoString:NULL] == NO)
                {
                theErrorBlock(@"< not followed by >");
                return(NO);
                }            
        
            if (theString.length > 0)
                {
                theLastCharacterWasWhitespace = [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[theString characterAtIndex:theString.length - 1]];
                self.textHandler(theString, theTagStack);
                }
            
            theString = [NSMutableString string]; 
            
            self.openTagHandler(theTag, theTagStack);
            
            [theTagStack addObject:theTag];
            }
        else if ([theScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL])
            {
            if (theLastCharacterWasWhitespace == NO)
                {
                [theString appendString:@" "];
                }
            }
        else if ([theScanner scanCharactersFromSet:theCharacterSet intoString:&theRun])
            {
            [theString appendString:theRun];
            }
        }
    
    if (theString.length > 0)
        {
        theLastCharacterWasWhitespace = [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[theString characterAtIndex:theString.length - 1]];
        self.textHandler(theString, theTagStack);
        }

    return(YES);
    }


@end
