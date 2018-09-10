//
//  Socket.m
//  NetDebugTool
//
//  Created by HHC-MAC on 18/9/7.
//  Copyright © 2018年 HHC-MAC. All rights reserved.
//

#import "Socket.h"


@implementation Socket

- (id)init{
    
    if (self=[super init]) {
        
        self->socketFD = -1;
    }
    return self;
}

- (BOOL)ConnectSocketIP:(NSString *)IP andPort:(NSNumber *)port{
    struct protoent *ppe;
    ppe=getprotobyname("tcp");
    self->socketFD=socket(AF_INET,SOCK_STREAM,ppe->p_proto);
    //----obtain  the socket handle .
    
    NSLog(@"Ethernet socket socketFD=%d",socketFD);
    if (socketFD==-1) //---obtain socket handle fail
    {
        NSLog(@"Fail, obtain socket handle fail, socketFD=%d",socketFD);
        return NO;
    }
    
    int iPortID =[port intValue];
    NSString *sysCmd = [NSString stringWithFormat:@"ping %@ -t 1",IP];
    const char * cmdStr = [IP cStringUsingEncoding:NSUTF8StringEncoding];
    system(cmdStr);
    
    struct sockaddr_in daddr;
    memset((void *)&daddr,0,sizeof(daddr));
    daddr.sin_family=AF_INET;
    daddr.sin_port=htons(iPortID);   ////convert port
    daddr.sin_addr.s_addr=inet_addr([IP cStringUsingEncoding:NSASCIIStringEncoding]) ; ///connect address
    
    // here wait too long
    int err ;
    err = connect(socketFD,(struct sockaddr *)&daddr,sizeof(daddr)) ;
    NSLog(@"Ethernet connect err=%d",err);
    if (err!=0) ///connected fail .
    {
        return NO;
    }
    else
    {
        
        struct timeval timeout={2,0};
        int ret = setsockopt(socketFD,SOL_SOCKET,SO_RCVTIMEO,(const char*)&timeout,sizeof(timeout)) ;
        if (ret != 0) {
            NSLog(@"set Rcv timeout fail");
            return NO;
        }
        ret = setsockopt(socketFD,SOL_SOCKET,SO_SNDTIMEO,(const char*)&timeout,sizeof(timeout)) ;
        if (ret != 0) {
            NSLog(@"set SND timeout fail");
            return NO;
        }
        int iAddr = 1 ;
        setsockopt(socketFD,SOL_SOCKET,SO_REUSEADDR,(char*)&iAddr,sizeof(int)) ;
    }
    
    return YES;
}

- (BOOL)DisconnectBySocket{
    if (socketFD < 0) {
        return NO;
    }
    shutdown(socketFD,0) ;////wait end the data sended.
    close(socketFD);
    socketFD = -1;
    return YES;
}

- (NSString *)CommunicationBySocket:(NSString*)cmd
                           withTime:(NSString *)tt
                         andPattern:(NSString *)patternStr{
    if (self->socketFD < 0) {
        return nil;
    }
    NSString *receive = nil;
    if ([self writeCMD:cmd]) {
        if (tt) {
            double timeout = tt.doubleValue;
            receive = [self readWithTime:timeout];
        }
        else
            receive = [self readLineFromSocket];
        if (receive != nil) {
            if (patternStr) {
                receive = [Common getExpectStringWithStr:receive andPatttern:patternStr];
            }
            return receive;
        }
    }
    return nil;
}

- (BOOL) writeCMD:(NSString *) cmd{
    const char *cmdStr = [cmd cStringUsingEncoding:NSUTF8StringEncoding];
    if (cmdStr == NULL || socketFD < 0) {
        return NO;
    }
    long byteSend = send(socketFD, cmdStr, strlen(cmdStr), 0);
    if (byteSend > 0 ) {
        return YES;
    }
    return NO;
}

- (NSString *)readLineFromSocket{
    if (socketFD < 0) {
        return nil;
    }
    NSMutableString *bufferString = [[NSMutableString alloc]init];
    long readLenth = 0;
    char tempbuffer[512];
    //阻塞的读
    do{
        memset(tempbuffer,0, 512*sizeof(char));
        readLenth = recv(socketFD, tempbuffer, 512*sizeof(char), 0);
        if (readLenth > 0) {
            [bufferString appendString:[NSString stringWithUTF8String:tempbuffer]];
        }
    }while(![bufferString containsString:@"\r\n"] || bufferString == nil);

    NSString *linerecv = [NSString stringWithString:bufferString];
    return linerecv;

}

- (NSString *)readWithTime:(double) tt{
    if (socketFD < 0) {
        return nil;
    }
    NSTimeInterval timeStart = [[NSDate date] timeIntervalSince1970];
    NSMutableString *bufferString = [[NSMutableString alloc]init];
    long readLenth = 0;
    char tempbuffer[512];
    do{
        memset(tempbuffer,0, 512*sizeof(char));
        readLenth = recv(socketFD, tempbuffer, 512*sizeof(char), 0);
        if (readLenth > 0) {
            [bufferString appendString:[NSString stringWithUTF8String:tempbuffer]];
        }
    }while(![bufferString containsString:@"\r\n"] && ([[NSDate date]timeIntervalSince1970] - timeStart) < tt);
    if (bufferString != nil) {
        NSString *linerecv = [NSString stringWithString:bufferString];
        return linerecv;
    }
    else
        return nil;
}
@end
