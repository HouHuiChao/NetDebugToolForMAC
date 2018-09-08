//
//  CmdList.h
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Common.h"

@interface CmdList : NSWindowController
{
    IBOutlet NSWindow *SelectWindow;
    __weak IBOutlet NSTextField *filePath;
    __weak IBOutlet NSButton *selectBtn;
    __weak IBOutlet NSButton *okBtn;
    NSArray *cmdArr;
}
-(NSWindow *)getwindow;

@end
