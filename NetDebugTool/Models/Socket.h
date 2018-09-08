//
//  Socket.h
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#import "termios.h"
#include <netdb.h>
#include <arpa/inet.h>
#include <stdio.h>
#import "Common.h"

@interface Socket : NSObject
{
    int  socketFD;
}
- (id)init;
- (BOOL)ConnectSocketIP:(NSString *)IP andPort:(NSNumber *)port;
- (BOOL)DisconnectBySocket;
- (NSString *)CommunicationBySocket:(NSString*)cmd
                           withTime:(NSNumber *)tt
                         andPattern:(NSString *)patternStr;
@end
