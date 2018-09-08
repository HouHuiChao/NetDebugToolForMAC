//
//  Common.h
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject
{

}
+(NSString *)getExpectStringWithStr:(NSString *)str
                        andPatttern:(NSString *)pattern;
+ (NSArray *)loadArrFromFile:(NSString *)path;
@end
