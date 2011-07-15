//
//  UIFont_CoreTextExtensions.m
//  CoreText
//
//  Created by Jonathan Wight on 07/12/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "UIFont_CoreTextExtensions.h"

@implementation UIFont (UIFont_CoreTextExtensions)

+ (NSSet *)featuresForFontName:(NSString *)inFontName
    {
    NSScanner *theScanner = [[NSScanner alloc] initWithString:inFontName];
    
    if ([theScanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:NULL] == NO)
        {
        NSLog(@"Could not scan font name");
        return(NULL);
        }
    
    [theScanner scanString:@"-" intoString:NULL];
    
    NSMutableSet *theFeatures = [NSMutableSet set];
    
    while([theScanner isAtEnd] == NO)
        {
        NSString *theLetter;
        [theScanner scanUpToCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet] intoString:&theLetter];

        NSString *theRemainder;
        [theScanner scanUpToCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet] intoString:&theRemainder];
        
        [theFeatures addObject:[theLetter stringByAppendingString:theRemainder]];
        }

    return(theFeatures);
    }


- (CTFontRef)CTFont
    {
    CTFontRef theFont = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.pointSize, NULL);
    
    NSAssert1(theFont != NULL, @"Could not convert font %@ to CTFont", self.fontName);
        
    return(theFont);
    }

- (UIFont *)boldFont
    {
    for (NSString *theFontName in [UIFont fontNamesForFamilyName:self.familyName])
        {
        NSSet *theFeatures = [UIFont featuresForFontName:theFontName];
        if (theFeatures.count == 1 && [theFeatures containsObject:@"Bold"])
            {
            return([UIFont fontWithName:theFontName size:self.pointSize]);
            }
        }

    NSLog(@"No bold font found in %@", [UIFont fontNamesForFamilyName:self.familyName]);

    return(NULL);
    }
    
- (UIFont *)italicFont
    {
    for (NSString *theFontName in [UIFont fontNamesForFamilyName:self.familyName])
        {
        NSSet *theFeatures = [UIFont featuresForFontName:theFontName];
        if (theFeatures.count == 1 && [theFeatures containsObject:@"Italic"])
            {
            return([UIFont fontWithName:theFontName size:self.pointSize]);
            }
        }
        
    return([self obliqueFont]);
    }
    
- (UIFont *)boldItalicFont
    {
    for (NSString *theFontName in [UIFont fontNamesForFamilyName:self.familyName])
        {
        NSSet *theFeatures = [UIFont featuresForFontName:theFontName];
        if (theFeatures.count == 2 && [theFeatures containsObject:@"Bold"] && [theFeatures containsObject:@"Italic"])
            {
            return([UIFont fontWithName:theFontName size:self.pointSize]);
            }
        }

    return([self boldObliqueFont]);
    }
    
- (UIFont *)obliqueFont
    {
    for (NSString *theFontName in [UIFont fontNamesForFamilyName:self.familyName])
        {
        NSSet *theFeatures = [UIFont featuresForFontName:theFontName];
        if (theFeatures.count == 1 && [theFeatures containsObject:@"Oblique"])
            {
            return([UIFont fontWithName:theFontName size:self.pointSize]);
            }
        }
    
    NSLog(@"No Oblique font found in %@", [UIFont fontNamesForFamilyName:self.familyName]);
    
    return(NULL);
    }
    
- (UIFont *)boldObliqueFont
    {
    for (NSString *theFontName in [UIFont fontNamesForFamilyName:self.familyName])
        {
        NSSet *theFeatures = [UIFont featuresForFontName:theFontName];
        if (theFeatures.count == 2 && [theFeatures containsObject:@"Bold"] && [theFeatures containsObject:@"Oblique"])
            {
            return([UIFont fontWithName:theFontName size:self.pointSize]);
            }
        }

    NSLog(@"No bold/oblique font found in %@", [UIFont fontNamesForFamilyName:self.familyName]);

    return(NULL);
    }
    


@end
