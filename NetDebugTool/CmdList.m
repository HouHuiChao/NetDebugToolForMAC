//
//  CmdList.m
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import "CmdList.h"

@interface CmdList ()

@end

@implementation CmdList

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)SelectFile:(id)sender {
    [okBtn setEnabled:NO];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    NSArray *arrtypes = @[@"txt",@"TXT"];
    [panel setAllowedFileTypes:arrtypes];
    if ([panel runModal] == NSModalResponseOK) {
        NSString *path = [panel.URLs.firstObject path];
        filePath.stringValue = path;
        [okBtn setEnabled:YES];
    }
}

- (IBAction)endSelectFile:(id)sender {
    if (filePath.stringValue == nil || [filePath.stringValue isEqualToString:@""]) {
         NSRunAlertPanel(@"温馨提示", @"无效的文件路径!!", @"OK", nil, nil);
        [okBtn setEnabled:NO];
        [selectBtn setEnabled:YES];
        return;
    }
    [selectBtn setEnabled:NO];
    NSWindow *selectWindow = [self getwindow];
    cmdArr = [[NSArray alloc]initWithArray:[Common loadArrFromFile:filePath.stringValue]];
    if (cmdArr == nil) {
        [okBtn setEnabled:NO];
        [selectBtn setEnabled:YES];
         NSRunAlertPanel(@"温馨提示", @"加载失败，请重试!!", @"OK", nil, nil);
        return ;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UPDATECOMMAND" object:cmdArr];
    [selectWindow close];
}

-(NSWindow *)getwindow
{
    return SelectWindow;
}

@end
