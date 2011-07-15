//
//  UIFont_CoreTextExtensions.h
//  CoreText
//
//  Created by Jonathan Wight on 07/12/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreText/CoreText.h>

@interface UIFont (UIFont_CoreTextExtensions)

- (CTFontRef)CTFont;

- (UIFont *)boldFont;
- (UIFont *)italicFont;
- (UIFont *)boldItalicFont;
- (UIFont *)obliqueFont;
- (UIFont *)boldObliqueFont;

@end
