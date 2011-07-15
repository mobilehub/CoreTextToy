//
//  CoreTextViewController.h
//  CoreText
//
//  Created by Jonathan Wight on 07/12/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCoreTextLabel;

@interface CoreTextViewController : UIViewController

@property (readwrite, nonatomic, retain) IBOutlet UITextView *editView;
@property (readwrite, nonatomic, retain) IBOutlet CCoreTextLabel *previewView;

@end
