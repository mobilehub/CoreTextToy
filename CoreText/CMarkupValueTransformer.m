//
//  CMarkupValueTransformer.m
//  CoreText
//
//  Created by Jonathan Wight on 07/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CMarkupValueTransformer.h"

#import <CoreText/CoreText.h>

#import "UIFont_CoreTextExtensions.h"

@interface CMarkupValueTransformer ()
@property (readwrite, nonatomic, retain) UIFont *standardFont;
@property (readwrite, nonatomic, retain) NSSet *supportedTags;
@property (readwrite, nonatomic, retain) NSMutableDictionary *attributesForTagSets;
@end

#pragma mark -

@implementation CMarkupValueTransformer

@synthesize standardFont;
@synthesize supportedTags;
@synthesize attributesForTagSets;

+ (Class)transformedValueClass
    {
    return([NSAttributedString class]);
    }
    
+ (BOOL)allowsReverseTransformation
    {
    return(NO);
    }

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        standardFont = [UIFont fontWithName:@"Helvetica" size:16.0];
        
        supportedTags = [NSSet setWithObjects:@"b", @"i", NULL];
        
        attributesForTagSets = [NSMutableDictionary dictionary];
        
        NSDictionary *theAttributes = NULL;

        theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)self.standardFont.CTFont, (__bridge NSString *)kCTFontAttributeName,
            NULL];
        [attributesForTagSets setObject:theAttributes forKey:[NSSet set]];

        theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)[self.standardFont boldItalicFont].CTFont, (__bridge NSString *)kCTFontAttributeName,
            NULL];
        [attributesForTagSets setObject:theAttributes forKey:[NSSet setWithObjects:@"b", @"i", NULL]];

        theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)[self.standardFont boldFont].CTFont, (__bridge NSString *)kCTFontAttributeName,
            NULL];
        [attributesForTagSets setObject:theAttributes forKey:[NSSet setWithObjects:@"b", NULL]];

        theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)[self.standardFont italicFont].CTFont, (__bridge NSString *)kCTFontAttributeName,
            NULL];
        [attributesForTagSets setObject:theAttributes forKey:[NSSet setWithObjects:@"i", NULL]];
        
        // TODO generate supported tags from attributesForTagSets keys.
		}
	return(self);
	}

- (id)transformedValue:(id)value
    {
    NSString *theMarkup = value;

    UIFont *theFont = self.standardFont;

    NSMutableAttributedString *theAttributedString = [[NSMutableAttributedString alloc] init];
    [theAttributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge_transfer id)theFont.CTFont range:(NSRange){ .length = 0 }];
  
    NSCharacterSet *theNotTagCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"< "] invertedSet];
    
    NSScanner *theScanner = [[NSScanner alloc] initWithString:theMarkup];
    theScanner.charactersToBeSkipped = NULL;

    NSMutableArray *theStyleStack = [NSMutableArray array];

    __block NSMutableString *theString = [NSMutableString string]; 

    void (^ApplyStyleBlock)(void) = ^(void) {
        NSMutableDictionary *theAttributes = [NSMutableDictionary dictionary];
        NSSet *theActiveTagSet = [NSSet setWithArray:theStyleStack];
        
        NSDictionary *theAttributesForActiveTagSet = [self.attributesForTagSets objectForKey:theActiveTagSet];
        [theAttributes addEntriesFromDictionary:theAttributesForActiveTagSet];
        [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:theString attributes:theAttributes]];
        };

    while ([theScanner isAtEnd] == NO)
        {
        NSString *theRun = NULL;
        
        for (NSString *theTag in self.supportedTags)
            {
            NSString *theOpenTag = [NSString stringWithFormat:@"<%@>", theTag];
            NSString *theCloseTag = [NSString stringWithFormat:@"</%@>", theTag];

            if ([theScanner scanString:theOpenTag intoString:NULL])
                {
                ApplyStyleBlock();
                theString = [NSMutableString string]; 
                
                [theStyleStack addObject:theTag];
                
                continue;
                }
            else if ([theScanner scanString:theCloseTag intoString:NULL])
                {
                ApplyStyleBlock();
                theString = [NSMutableString string]; 

                NSAssert([[theStyleStack lastObject] isEqualToString:theTag], @"Tag mismatch");
                [theStyleStack removeLastObject];

                continue;
                }
            }

        
        if ([theScanner scanCharactersFromSet:theNotTagCharacterSet intoString:&theRun])
            {
            [theString appendString:theRun];
            }
        else if ([theScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL])
            {
            [theString appendString:@" "];
            }
        }
    
    ApplyStyleBlock();
    
    return([theAttributedString copy]);
    }

@end

#pragma mark -

@implementation NSAttributedString (NSAttributedString_MarkupExtensions)

+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)inMarkup
    {
    CMarkupValueTransformer *theTransformer = [[CMarkupValueTransformer alloc] init];
    return([theTransformer transformedValue:inMarkup]);
    }

@end