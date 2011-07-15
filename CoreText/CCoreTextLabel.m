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

@interface CCoreTextLabel ()
@property (readonly, nonatomic, assign) CTFramesetterRef framesetter;
@end

@implementation CCoreTextLabel

@synthesize text;

@synthesize framesetter;

- (void)dealloc
    {
    if (framesetter)
        {
        CFRelease(framesetter);
        framesetter = NULL;
        }
    }

- (CTFramesetterRef)framesetter
    {
    if (framesetter == NULL)
        {
        if (self.text)
            {
            framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.text);
            }
        }
    return(framesetter);
    }

- (void)setText:(NSAttributedString *)inText
    {
    if (text != inText)
        {
        text = inText;
        
        if (framesetter)
            {
            CFRelease(framesetter);
            framesetter = NULL;
            }

        [self setNeedsDisplay];
        }
    }

- (void)awakeFromNib
    {
    // TODO this is all just test code.
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor redColor].CGColor;
    }

- (void)drawRect:(CGRect)rect
    {
    if (self.framesetter)
        {
        UIBezierPath *thePath = [UIBezierPath bezierPathWithRect:self.bounds];

        CTFrameRef theFrame = CTFramesetterCreateFrame(self.framesetter, (CFRange){ .length = [self.text length] }, thePath.CGPath, NULL);

        CGContextRef theContext = UIGraphicsGetCurrentContext();

        CGContextSaveGState(theContext);

        CGContextScaleCTM(theContext, 1.0, -1.0);
        CGContextTranslateCTM(theContext, 0.0, -self.bounds.size.height);

        CTFrameDraw(theFrame, theContext);

        CGContextRestoreGState(theContext);
        
        CFRelease(theFrame);
        }
    }

@end
