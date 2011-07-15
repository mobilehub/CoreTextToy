//
//  CSimpleHTMLParser.h
//  CoreText
//
//  Created by Jonathan Wight on 07/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSimpleHTMLParser : NSObject

@property (readwrite, nonatomic, copy) void (^openTagHandler)(NSString *tag, NSArray *tagStack);
@property (readwrite, nonatomic, copy) void (^closeTagHandler)(NSString *tag, NSArray *tagStack);
@property (readwrite, nonatomic, copy) void (^textHandler)(NSString *text, NSArray *tagStack);

- (BOOL)parseString:(NSString *)inString error:(NSError **)outError;

@end
