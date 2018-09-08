//
//  Common.m
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import "Common.h"

@implementation Common

+(NSString *)getExpectStringWithStr:(NSString *)str
                     andPatttern:(NSString *)pattern
{
    if (pattern == nil || str == nil || [str isEqualToString:@""] ||[pattern isEqualToString:@""]) {
        return nil;
    }
    NSString *resultStr=nil;
    
    NSRegularExpression *regExp=[NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    @try {
        NSArray *matches = [regExp matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        if (matches == nil || [matches count] == 0) {
            return nil;
        }
        for (NSTextCheckingResult *match in matches) {
            NSRange firstHalfRange = [match rangeAtIndex:1];
            resultStr = [str substringWithRange:firstHalfRange];
            break;
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"<Exception> getStringWithPattern");
    }
    return resultStr;
}

+ (NSArray *)loadArrFromFile:(NSString *)path{
    if (path == nil) {
        return nil;
    }
    NSString *allCMD = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *cmdArr = [allCMD componentsSeparatedByString:@"\n"];
    return cmdArr;
}

@end
