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
#import "CMarkupValueTransformer.h"
#import "CSimpleHTMLParser.h"

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
    return([self transformedValue:value error:NULL]);
    }

- (id)transformedValue:(id)value error:(NSError **)outError
    {
    NSString *theMarkup = value;

    NSMutableAttributedString *theAttributedString = [[NSMutableAttributedString alloc] init];
  
    __block NSMutableDictionary *theAttributes = NULL;  
  
    NSMutableArray *theStyleStack = [NSMutableArray array];

    CSimpleHTMLParser *theParser = [[CSimpleHTMLParser alloc] init];
    
    theParser.openTagHandler = ^(NSString *inTag, NSArray *tagStack) {
        if ([inTag isEqualToString:@"br"])
            {
            [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:theAttributes]];
            }
        else if ([self.supportedTags containsObject:inTag])
            {
            [theStyleStack addObject:inTag];
            }
        };

    theParser.closeTagHandler = ^(NSString *inTag, NSArray *tagStack) {
        if ([self.supportedTags containsObject:inTag])
            {
            [theStyleStack removeLastObject];
            }
        };
    

    theParser.textHandler = ^(NSString *inString, NSArray *tagStack) {
        theAttributes = [NSMutableDictionary dictionary];
        NSSet *theActiveTagSet = [NSSet setWithArray:theStyleStack];
        
        NSDictionary *theAttributesForActiveTagSet = [self.attributesForTagSets objectForKey:theActiveTagSet];
        [theAttributes addEntriesFromDictionary:theAttributesForActiveTagSet];
        
        [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:inString attributes:theAttributes]];
        };
    
    
    if ([theParser parseString:theMarkup error:outError] == NO)
        {
        return(NULL);
        }

    return([theAttributedString copy]);
    }

@end

#pragma mark -

@implementation NSAttributedString (NSAttributedString_MarkupExtensions)

+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)inMarkup error:(NSError **)outError
    {
    CMarkupValueTransformer *theTransformer = [[CMarkupValueTransformer alloc] init];

    NSAttributedString *theAttributedString = [theTransformer transformedValue:inMarkup error:outError];

    return(theAttributedString);
    }

@end