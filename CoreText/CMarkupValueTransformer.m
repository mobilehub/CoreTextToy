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
@property (readwrite, nonatomic, retain) NSMutableDictionary *attributesForTagSets;
@end

#pragma mark -

@implementation CMarkupValueTransformer

@synthesize standardFont;
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
        
        
        attributesForTagSets = [NSMutableDictionary dictionary];
        
        
        NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
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
        NSSet *theAttributeSet = [NSSet setWithArray:theStyleStack];
        [theAttributes setObject:(__bridge_transfer id)theFont.CTFont forKey:(__bridge NSString *)kCTFontAttributeName];
        if ([theAttributeSet containsObject:@"<b>"] && [theAttributeSet containsObject:@"<i>"])
            {
            [theAttributes setObject:(__bridge_transfer id)[theFont boldItalicFont].CTFont forKey:(__bridge NSString *)kCTFontAttributeName];
            }
        else if ([theAttributeSet containsObject:@"<b>"])
            {
            [theAttributes setObject:(__bridge_transfer id)[theFont boldFont].CTFont forKey:(__bridge NSString *)kCTFontAttributeName];
            }
        else if ([theAttributeSet containsObject:@"<i>"])
            {
            [theAttributes setObject:(__bridge_transfer id)[theFont italicFont].CTFont forKey:(__bridge NSString *)kCTFontAttributeName];
            }

        [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:theString attributes:theAttributes]];
        };

    while ([theScanner isAtEnd] == NO)
        {
        NSString *theRun = NULL;
        
        if ([theScanner scanString:@"<b>" intoString:NULL])
            {
            ApplyStyleBlock();
            theString = [NSMutableString string]; 
            
            [theStyleStack addObject:@"<b>"];
            }
        else if ([theScanner scanString:@"</b>" intoString:NULL])
            {
            ApplyStyleBlock();
            theString = [NSMutableString string]; 

            NSAssert([[theStyleStack lastObject] isEqualToString:@"<b>"], @"Tag mismatch");
            [theStyleStack removeLastObject];
            }
        else if ([theScanner scanString:@"<i>" intoString:NULL])
            {
            ApplyStyleBlock();
            theString = [NSMutableString string]; 
            
            [theStyleStack addObject:@"<i>"];
            }
        else if ([theScanner scanString:@"</i>" intoString:NULL])
            {
            ApplyStyleBlock();
            theString = [NSMutableString string]; 

            NSAssert([[theStyleStack lastObject] isEqualToString:@"<i>"], @"Tag mismatch");
            [theStyleStack removeLastObject];
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