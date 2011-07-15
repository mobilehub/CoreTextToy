//
//  CCoreTextLabel.m
//  CoreText
//
//  Created by Jonathan Wight on 07/12/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CCoreTextLabel.h"

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

#import "UIFont_CoreTextExtensions.h"
#import "CMarkupValueTransformer.h"

@implementation CCoreTextLabel

- (void)awakeFromNib
    {
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor redColor].CGColor;
    }

- (void)drawRect:(CGRect)rect
    {
    NSString *theHTMLString = @"<i>Hello</i> <b>world</b>";
    NSAttributedString *theAttributedString = [NSAttributedString attributedStringWithMarkup:theHTMLString];

     

    CTFramesetterRef theFrameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)theAttributedString);

    UIBezierPath *thePath = [UIBezierPath bezierPathWithRect:self.bounds];

    CTFrameRef theFrame = CTFramesetterCreateFrame(theFrameSetter, (CFRange){ .length = [theAttributedString length] }, thePath.CGPath, NULL);







    CGContextRef theContext = UIGraphicsGetCurrentContext();

    CGContextSaveGState(theContext);

//    CGContextSetTextMatrix(theContext, CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, -1.0), CGAffineTransformMakeTranslation(0.0, -self.bounds.size.height)));

    CGContextScaleCTM(theContext, 1.0, -1.0);
    CGContextTranslateCTM(theContext, 0.0, -self.bounds.size.height);

    CTFrameDraw(theFrame, theContext);

    CGContextRestoreGState(theContext);
    }

@end
