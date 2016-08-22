//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by  Jierism on 16/8/16.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

- (void)addText:(NSString *)text  withSeparator:(NSString *)separator
{
    if (text != nil) {
        if ([self length] > 0) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}

@end
