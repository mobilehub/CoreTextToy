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
        openTagHandler = ^(NSString *tag) {};
        closeTagHandler = ^(NSString *tag) {};
        textHandler = ^(NSString *tag) {};
		}
	return(self);
	}


- (BOOL)parseString:(NSString *)inString error:(NSError **)outError
    {
    NSCharacterSet *theNotTagCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"< "] invertedSet];

    NSScanner *theScanner = [[NSScanner alloc] initWithString:inString];
    theScanner.charactersToBeSkipped = NULL;

    NSMutableArray *theTagStack = [NSMutableArray array];

    __block NSMutableString *theString = [NSMutableString string]; 

    while ([theScanner isAtEnd] == NO)
        {
        NSString *theRun = NULL;

        NSString *theTag = NULL;

        if ([theScanner scanString:@"</" intoString:NULL] == YES)
            {
            [theScanner scanUpToString:@">" intoString:&theTag];
            [theScanner scanString:@">" intoString:NULL];

            if (theString.length > 0)
                {
                self.textHandler(theString);
                }
            theString = [NSMutableString string]; 

            NSAssert([[theTagStack lastObject] isEqualToString:theTag], @"Tag mismatch");

            self.closeTagHandler(theTag);

            [theTagStack removeLastObject];
            }
        else if ([theScanner scanString:@"<" intoString:NULL] == YES)
            {
            [theScanner scanUpToString:@">" intoString:&theTag];
            [theScanner scanString:@">" intoString:NULL];
        
            if (theString.length > 0)
                {
                self.textHandler(theString);
                }
            
            theString = [NSMutableString string]; 
            
            self.openTagHandler(theTag);
            
            [theTagStack addObject:theTag];
            }
        else if ([theScanner scanCharactersFromSet:theNotTagCharacterSet intoString:&theRun])
            {
            [theString appendString:theRun];
            }
        else if ([theScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL])
            {
            [theString appendString:@" "];
            }
        }
    
    if (theString.length > 0)
        {
        self.textHandler(theString);
        }

    return(YES);
    }


@end
