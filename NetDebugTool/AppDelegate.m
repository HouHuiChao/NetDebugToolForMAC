//
//  AppDelegate.m
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    [IPAddr setBackgroundColor:[NSColor greenColor]];
//    [IPPort setBackgroundColor:[NSColor greenColor]];
    mSocket = [[Socket alloc] init];
    cmdArr = [[NSMutableArray alloc]init];
    
    [disconnectBTN setEnabled:NO];
    [IPAddr becomeFirstResponder];
    [SingleCMD setEnabled:NO];
    [SendBTN setEnabled:NO];
    [LoadFileBTN setEnabled:NO];
    [RecvText setEditable:NO];
    [ReleaseBuffer setEnabled:NO];
    [CMDLoadOKBTN setEnabled:NO];
    [CmdTable setDelegate:self];
    [CmdTable setDataSource:self];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UpdateCMDTable:) name:@"UPDATECOMMAND" object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}
- (IBAction)connectIP:(id)sender {
    if (IPAddr.stringValue == nil || [IPAddr.stringValue isEqualToString:@""] ||[IPPort.stringValue isEqualToString:@""] ||IPPort.stringValue == nil) {
        NSRunAlertPanel(@"温馨提示", @"无效的IP或端口号!!", @"OK", nil, nil);
        return ;
    }
    NSNumber *port = [NSNumber numberWithInt:[IPPort.stringValue intValue]];
    BOOL ret = [mSocket ConnectSocketIP:IPAddr.stringValue andPort:port];
    if (ret == NO) {
        NSRunAlertPanel(@"温馨提示", @"连接失败，请重试!!", @"OK", nil, nil);
        return ;
    }
    [IPAddr setEnabled:NO];
    [IPPort setEnabled:NO];
    [IPAddr setBackgroundColor:[NSColor yellowColor]];
    [IPPort setBackgroundColor:[NSColor yellowColor]];
    [ConnectBTN setEnabled:NO];
    [disconnectBTN setEnabled:YES];
    [LoadFileBTN setEnabled:YES];
    [SingleCMD setEnabled:YES];
    [SendBTN setEnabled:YES];
    [SingleCMD becomeFirstResponder];
    
    return ;
}
- (IBAction)sendCMD:(id)sender {
    BOOL ret = (SingleCMD.stringValue == nil) || ([SingleCMD.stringValue isEqualToString:@""]);
    if (ret && cmdArr.count == 0) {
        return ;
    }
    [SendBTN setEnabled:NO];
    NSString *recv = nil;
    if (cmdArr.count == 0) {
        NSString * tt = @"200";
        NSString *cmd = [NSString stringWithFormat:@"%@\r\n",SingleCMD.stringValue];
        [RecvText.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"SendCommand:\n%@",cmd]]];
        [RecvText scrollRangeToVisible:NSMakeRange(RecvText.string.length, 1)];
        recv = [mSocket CommunicationBySocket:cmd withTime:tt andPattern:nil];
    }
    else{
        for (NSDictionary *cmdDict in cmdArr) {
            NSString *cmdStr = [cmdDict objectForKey:@"Command"];
            NSString *tt = [cmdDict objectForKey:@"Delay"];
             NSString *cmd = [NSString stringWithFormat:@"%@\r\n",cmdStr];
            [RecvText.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"SendCommand:\n%@",cmd]]];
            [RecvText scrollRangeToVisible:NSMakeRange(RecvText.string.length, 1)];
            recv = [mSocket CommunicationBySocket:cmd
                                                   withTime:tt andPattern:nil];
        }
    }
    if (recv != nil) {
        [RecvText.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"RecevieData:\n%@",recv]]];
        [RecvText scrollRangeToVisible:NSMakeRange(RecvText.string.length, 1)];
        [SendBTN setEnabled:YES];
    }
}

- (IBAction)LoadCmdFromFile:(id)sender {
    [SendBTN setEnabled:NO];
    [SingleCMD setStringValue:@""];
    [SingleCMD setEnabled:NO];
    [disconnectBTN setEnabled:NO];
    if(newCmd == nil){
        newCmd = [[CmdList alloc]initWithWindowNibName:@"CmdList"];
    }
    [newCmd showWindow:nil];
}

- (IBAction)resetReceive:(id)sender {
    [RecvText setString:@""];
}

//接收通知，更新TableView
- (void)UpdateCMDTable:(NSNotification*)noti{
    NSArray *bufferArr = [noti object];
//    NSLog(@"bufferArr = %@",bufferArr);
    if (bufferArr != nil) {
        NSArray *keyArr = [NSArray arrayWithObjects:@"Command",@"Delay", nil];
        for (int i = 0 ; i < (bufferArr.count - 1); i++) {
            NSString *cmdStr = [bufferArr objectAtIndex:i];
            NSArray *objArr = [[NSArray alloc]initWithObjects:cmdStr,@"200", nil];
            NSDictionary *bufDict = [[NSDictionary alloc]initWithObjects:objArr forKeys:keyArr];
            [cmdArr addObject:bufDict];
        }
//        NSLog(@"cmdarr = %@",cmdArr);
        CmdTable.delegate = self;
        CmdTable.dataSource = self;
        [CmdTable reloadData];
        
        [SingleCMD setEnabled:YES];
        [SendBTN setEnabled:YES];
        [disconnectBTN setEnabled:YES];
    }
}
//返回表格的行数
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (cmdArr.count == 0) {
        return 20;
    }
    return [cmdArr count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}
//
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    //非空判断
    if (cmdArr.count == 0) {
        return;
    }
    NSDictionary *data = [cmdArr objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
//    NSLog(@"data = %@",data);
    if ([identifier isEqualToString:@"Command"]) {
        NSTextFieldCell *textCell = cell;
        [textCell setTitle:[data objectForKey:@"Command"]];
    }
    else if ([identifier isEqualToString:@"Delay(ms)"])
    {
        NSTextFieldCell *textCell = cell;
        [textCell setTitle:[data objectForKey:@"Delay"]];
    }
}

//设置是否可以进行编辑
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    return YES;
}
//用户编辑TableView
-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary *data = [cmdArr objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"Command"]) {
        if (![object isEqualToString:[data objectForKey:@"Command"]]) {
            NSDictionary *cData = [NSDictionary dictionaryWithObjectsAndKeys:object,@"Command",[data objectForKey:@"Delay"],@"Delay", nil];
            [cmdArr setObject:cData atIndexedSubscript:row];
            [CmdTable reloadData];
        }
    }
    else if ([identifier isEqualToString:@"Delay(ms)"])
    {
        if (![object isEqualTo:[data objectForKey:@"Delay"]]) {
            NSDictionary *cData = [NSDictionary dictionaryWithObjectsAndKeys:object,@"Delay",[data objectForKey:@"Command"],@"Command", nil];
            [cmdArr setObject:cData atIndexedSubscript:row];
            [CmdTable reloadData];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return YES;
}
@end
