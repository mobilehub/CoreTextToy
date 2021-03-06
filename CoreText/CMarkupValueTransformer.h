//
//  CMarkupValueTransformer.h
//  CoreText
//
//  Created by Jonathan Wight on 07/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMarkupValueTransformer : NSValueTransformer

- (id)transformedValue:(id)value error:(NSError **)outError;

@end

#pragma mark -

@interface NSAttributedString (NSAttributedString_MarkupExtensions)

+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)inMarkup error:(NSError **)outError;

@end