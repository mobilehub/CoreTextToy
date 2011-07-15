//
//  CoreTextViewController.m
//  CoreText
//
//  Created by Jonathan Wight on 07/12/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CoreTextViewController.h"

#import "CMarkupValueTransformer.h"
#import "CCoreTextLabel.h"

@interface CoreTextViewController () <UITextViewDelegate>
@end

#pragma mark -

@implementation CoreTextViewController

@synthesize editView;
@synthesize previewView;

- (void)awakeFromNib
    {
    self.previewView.text = [NSAttributedString attributedStringWithMarkup:self.editView.text];
    }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
    {
    return YES;
    }

- (void)textViewDidChange:(UITextView *)textView;
    {
    self.previewView.text = [NSAttributedString attributedStringWithMarkup:self.editView.text];
    }

@end
