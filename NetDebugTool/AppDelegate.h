//
//  AppDelegate.h
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Socket.h"
#import "CmdList.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDelegate,NSTableViewDataSource>
{
    __weak IBOutlet NSTextField *IPAddr;
    __weak IBOutlet NSTextField *IPPort;
    __weak IBOutlet NSTextField *SingleCMD;
    __weak IBOutlet NSButton *ConnectBTN;
    __unsafe_unretained IBOutlet NSTextView *RecvText;
    __weak IBOutlet NSButton *SendBTN;
    __weak IBOutlet NSButton *LoadFileBTN;
    __weak IBOutlet NSTableView *CmdTable;
    __weak IBOutlet NSButton *ReleaseBuffer;
    __weak IBOutlet NSButton *CMDLoadOKBTN;
    
    CmdList *newCmd;
    Socket *mSocket;
    NSMutableArray *cmdArr;
    
}
@property (weak) IBOutlet NSWindow *mainWindow;
- (void)beginTaskWithCallbackBlock:(void (^)(void))callbackBlock;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
@end

