//
//  ISLogFileManager.m
//  CloudLink Share
//
//  Created by mac on 2020/5/10.
//  Copyright © 2020 zhu dongwei. All rights reserved.
//

#import "ISLogFileManager.h"
#import <SSZipArchive/SSZipArchive.h>
#import "ManagerService.h"

@implementation ISLogFileManager

+ (NSData *)getISLog {
    
    NSString *logPath = [self getLogPath];
    if (!logPath) {return nil;}
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:logPath error:nil];
    if (files.count == 0) {return nil;}
    NSMutableArray *allLogpaths = [NSMutableArray array];
    //压缩所有的文件
    for (NSString *filePath in files) {
        NSString *oneFullFilePath  = [logPath stringByAppendingPathComponent:filePath];
        [allLogpaths addObject:oneFullFilePath];
    }
    NSString *zipPath = [self getZipPath] ;
    if (![self zipFromPaths:allLogpaths zipPath:zipPath]) {
        return nil;
    }
    NSData * data = [NSData dataWithContentsOfFile:[self getZipPath]];
    return data;
}
//2.0
+ (NSData *)getISLogWithDateArray:(NSArray *)dateArray images:(NSArray<UIImage *> *)images sdkLogPathArray:(NSArray *)pathArray{
    NSMutableArray *allLogpaths = [NSMutableArray arrayWithArray:pathArray];
    
    NSString *logPath = [self getLogPath];
    if (!logPath) {return nil;}
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:logPath error:nil];
    if (files.count == 0) {return nil;}
    //把本地文件全部放进数组中
    for (int i = 0 ; i < files.count; i ++ ) {
        NSString *innerFilePath = files[i];
        NSString *shortDate = [innerFilePath componentsSeparatedByString:@" "][1];
        NSString *time = [shortDate substringToIndex:10];
        for (int j = 0 ; j < dateArray.count; j ++ ) {
            NSString *dateTime = dateArray[j];
            if  ([time isEqualToString:dateTime]) {
                NSString *allPath = [logPath stringByAppendingPathComponent:innerFilePath];
                [allLogpaths addObject:allPath];
            }
        }
    }
    
    // 存图片到本地
    NSString *imagePath = [ISLogFileManager getTxtPath];
    for (NSInteger i = 0; i<images.count; i++) {
        NSString *logImagePath = [NSString stringWithFormat:@"%@/image_%zd.png", imagePath, i];
        UIImage *image = images[i];
        NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
        [imgData writeToFile:logImagePath atomically:YES];
        
        [allLogpaths addObject:logImagePath];
    }
 
    NSString *zipPath = [self getZipPath] ;
    if (![self zipFromPaths:allLogpaths zipPath:zipPath]) {
        return nil;
    }
    return [NSData dataWithContentsOfFile:zipPath]; //[self getZipPath]
}
//3.0
+ (NSString *)getLogPathThreeVersionWithDateArray:(NSArray *)dateArray images:(NSArray<UIImage *> *)images sdkLogPathArray:(NSArray *)pathArray{
    NSMutableArray *allLogpaths = [NSMutableArray arrayWithArray:pathArray];
    NSString *logPath = [self getLogPath];
    if (!logPath) {return nil;}
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:logPath error:nil];
    if (files.count == 0) {return nil;}
    //把本地文件全部放进数组中
    for (int i = 0 ; i < files.count; i ++ ) {
        NSString *innerFilePath = files[i];
        NSString *shortDate = [innerFilePath componentsSeparatedByString:@" "][1];
        NSString *time = [shortDate substringToIndex:10];
        for (int j = 0 ; j < dateArray.count; j ++ ) {
            NSString *dateTime = dateArray[j];
            if  ([time isEqualToString:dateTime]) {
                NSString *allPath = [logPath stringByAppendingPathComponent:innerFilePath];
                [allLogpaths addObject:allPath];
            }
        }
    }
    
    
    //在3。0 状态下，需要加入txt文件的路径，在提交的时候已经写入到本地了，在此处只取路径即可
    NSString *txtPath = [self getTxtPath];
    if (!txtPath) {return nil;}
    NSArray *txtFiles = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:txtPath error:nil];
    if (txtFiles.count == 0) {return nil;}
    for (int i = 0 ; i < txtFiles.count; i ++ ) {
        NSString *txtName = txtFiles[i];
        if ([[txtName pathExtension] isEqualToString:@"txt"]) {
            NSString *allPath = [txtPath stringByAppendingPathComponent:txtName];
            [allLogpaths addObject:allPath];
        }
    }
    
    // 存图片到本地
    for (NSInteger i = 0; i<images.count; i++) {
        NSString *logImagePath = [NSString stringWithFormat:@"%@/image_%zd.png", txtPath, i];
        UIImage *image = images[i];
        NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
        [imgData writeToFile:logImagePath atomically:YES];
        [allLogpaths addObject:logImagePath];
    }
     
 
    NSString *zipPath = [self getZipPath] ;
    if (![self zipFromPaths:allLogpaths zipPath:zipPath]) {
        return nil;
    }
    return zipPath ;
}
// 压缩文件
+ (BOOL)zipFromPaths:(NSArray *)paths zipPath:(NSString *)zipPath {
    BOOL isYES = [SSZipArchive createZipFileAtPath: zipPath withFilesAtPaths:paths];
    return  isYES ;
}
 
+ (NSString *)getZipPath{
    //压缩文件的路径
    NSString *library = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    //获得时间戳
    NSDate *datenow = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    //获取账号
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:SAVE_USER_CONUT];
    NSString *temStr;
    if (userName.length <= 2) {
        temStr =[NSString stringWithFormat:@"%@xxx",userName];
    }else {
        temStr =[NSString stringWithFormat:@"%@xxx%@",[userName substringWithRange:NSMakeRange(0,2)],[userName substringFromIndex:userName.length-2]];
    }
    NSString *random = [ISLogFileManager getRandomNum];
    NSString *result = [library stringByAppendingPathComponent:[NSString stringWithFormat:@"HWCloudLink_%@_%@_%@.zip",temStr,currentTimeString,random]];
    return result ;
}

//获取log文件的路径
+ (NSString *)getLogPath {
    //路径 NSLibraryDirectory
    NSString *library = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    //拼接路径
    NSString *logPath = [library stringByAppendingPathComponent: @"/Log"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        return nil;
    }
    return logPath;
}
 
+ (BOOL)clearISLog{
    NSString *logPath = [self getLogPath];
    if (!logPath) {
        return NO;
    }
    return  [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
}
+ (BOOL)clearZip {
    //压缩文件的路径
    NSString *zipPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
     
    if (!zipPath) {
        return NO;
    }
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:zipPath error:nil];
    if (files.count == 0) {return nil;}
    
    NSMutableArray *pathArray = [NSMutableArray array];
    for (int i = 0 ;  i < files.count ; i ++ ) {
        NSString *path = files[i];
        if ([[path pathExtension] isEqualToString:@"zip"]  || [[path pathExtension] isEqualToString:@"txt"] || [[path pathExtension] isEqualToString:@"png"]) {
            NSString *fullPath = [zipPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",path]];
            [pathArray addObject:fullPath];
        }
    }
    for (int i = 0 ; i < pathArray.count; i ++ ) {
        NSString *fullPath = pathArray[i];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil] ;
    }
    return YES ;
}
 
+ (NSString *)getTxtPath{
    //获取沙盒路径
    NSString *path  = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).lastObject;
    
    return  path ;
}
+ (void)writeToTXTFileWithString:(NSString *)textStr{
    NSString *path = [ISLogFileManager getTxtPath];
    //获取文件路径
    NSString *fullName = [NSString stringWithFormat:@"Feedback_contact.txt"];
    NSString *theFilePath = [path stringByAppendingPathComponent:fullName];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //如果文件不存在 创建文件
    if(![fileManager fileExistsAtPath:theFilePath]){
        [@"" writeToFile:theFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:theFilePath];
    [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
    NSData* stringData  = [[NSString stringWithFormat:@"%@\n",textStr] dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:stringData]; //追加写入数据
    [fileHandle closeFile];
}

+  (NSString *)getRandomNum{
    NSArray *strArr = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil] ;
    NSMutableString *getStr = [[NSMutableString alloc]initWithCapacity:5];
    for(int i = 0; i < 6; i++) //得到六位随机字符,可自己设长度
    {
        int index = arc4random() % ([strArr count]);  //得到数组中随机数的下标
        [getStr appendString:[strArr objectAtIndex:index]];
        
    }
    
    return getStr;
}
@end
