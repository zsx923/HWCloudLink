//
// CZFSingalCrash.m
// CloudLink Share
// Notes：
//
// Created by 陈帆 on 2020/12/22.
// Copyright © 2020 zhu dongwei. All rights reserved.
//

#import "CZFSingalCrash.h"

#import <execinfo.h>

/* UNIX系统中常用的信号有以下几种:
SIGABRT--程序中止命令中止信号
SIGBUS--程序内存字节未对齐中止信号
SIGFPE--程序浮点异常信号
SIGILL--程序非法指令信号
SIGSEGV--程序无效内存中止信号
SIGTERM--程序kill中止信号
SIGKILL--程序结束接收中止信号
    
SIGALRM--程序超时信号
SIGHUP--程序终端中止信号
SIGINT--程序键盘中断信号
SIGSTOP--程序键盘中止信号
SIGPIPE--程序Socket发送失败中止信号 */

// 抓取的是以下几种
static int errorSignals[] = {
    SIGQUIT,
    SIGILL ,
    SIGTRAP,
    SIGABRT,
    SIGEMT ,
    SIGFPE ,
    SIGBUS ,
    SIGSEGV,
    SIGSYS ,
    SIGPIPE,
    SIGALRM,
    SIGXCPU,
    SIGXFSZ,
};
static int errorSignalsNum = 0;

typedef void (*SignalHandler)(int signo, siginfo_t *info, void *context);
static SignalHandler previousSignalHandler = NULL;

@implementation CZFSingalCrash

// 监听崩溃信息
+ (void)observerCaughtException {
    errorSignalsNum = sizeof(errorSignals) / sizeof(int);
    installUncaughtExceptionHandler();
}

// 写入崩溃日志
void writeFileHandleWithData(NSString *dataStr) {
    // file path
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *fileDirectory = [documentPath stringByAppendingPathComponent:@"/Crash/"];
    NSString *fileName = getCrashPathName();
    NSString *filePath = [fileDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectoryExit = [fileManager fileExistsAtPath:fileDirectory];
    // 文件夹是否存在
    if (!isDirectoryExit) {
        [fileManager createDirectoryAtPath:fileDirectory withIntermediateDirectories:true attributes:nil error:nil];
    }
    
    BOOL isFileExit = [fileManager fileExistsAtPath:filePath];
    // 文件是否存在
    if (!isFileExit) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    NSData *writeData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//    ISLogError(@"写入崩溃日志--- 请在查看%@", filePath);
    [fileHandle writeData:writeData];
    [fileHandle closeFile];
}

// 获取crash文件名称
NSString *getCrashPathName() {
    NSDate *datenow = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    NSString *currentTimeString = [formatter stringFromDate:datenow];

    return [NSString stringWithFormat:@"IdeaShare_crash_%@.log", currentTimeString];
}

// Singal崩溃安装
static void installUncaughtExceptionHandler() {
//    ISLog(@"监测OC崩溃");
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    struct sigaction old_action;
    sigaction(SIGABRT, NULL, &old_action);
    if (old_action.sa_flags & SA_SIGINFO) {
        previousSignalHandler = old_action.sa_sigaction;
    }
    
//    ISLog(@"监测Signal崩溃 -- %d", errorSignalsNum);
    for (int i = 0; i <errorSignalsNum; i++) {
        CZFSignalRegister(errorSignals[i]);
    }
}

// 注册signal
static void CZFSignalRegister(int signal) {
    struct sigaction action;
    action.sa_sigaction = CZFSignalHandler;
    action.sa_flags = SA_NODEFER | SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    sigaction(signal, &action, 0);
}

// OC崩溃监测记录
static void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    NSString *writeStr = [NSString stringWithFormat:@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr];
    //ISLogError(@"%@", writeStr);
    
    writeFileHandleWithData(writeStr);
}

// 抓取信号的处理函数回调
static void CZFSignalHandler(int sig, siginfo_t* info, void* context) {
    void* callstack[128];
    NSString* name ;
    int i, frames = backtrace(callstack, 128);
    for (i = 0; i < errorSignalsNum; i++) {
        if (errorSignals[i] == sig) {
            name = [NSString stringWithFormat:@"SINGAL: %d", sig];
            break;
        }
    }
    char** strs = backtrace_symbols(callstack, frames);
    NSMutableString* exceptionStr = [[NSMutableString alloc]initWithFormat:@"异常名称:\n%@\n\n出错堆栈内容:\n",name];
    for (i =0; i <frames; i++) {
        [exceptionStr appendFormat:@"%s\n",strs[i]];
    }
//    ISLogError(@"%@", exceptionStr);
    writeFileHandleWithData(exceptionStr);
    free(strs);
    
    //LDAPMClearSignalRigister();
    // 处理前者注册的 handler
//    if (previousSignalHandler) {
//        previousSignalHandler(sig, info, context);
//    }
    
    // 在应用崩溃后，保持运行状态而不退出，让响应更加友好
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    for (NSString *mode in (__bridge NSArray *)allModes) {
        CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
    }
    CFRelease(allModes);
}


@end
