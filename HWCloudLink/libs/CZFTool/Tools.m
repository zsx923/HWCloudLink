//
//  tools.m
//  250
//
//  Created by 周强 on 15/12/24.
//  Copyright © 2015年 com.jointsky.www. All rights reserved.
//

#import "Tools.h"


@interface Tools ()

@end


@implementation Tools

// 将16进制转成10进制
+ (NSString *)hexToDecimal:(NSInteger)hex {
    NSString *hexStr = [NSString stringWithFormat:@"%ld", (long)hex];
    NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([hexStr UTF8String],0,16)];
    NSLog(@"心跳数字 10进制 %@",temp10);
    
    return temp10;
}

// 将十进制转化为十六进制
+ (NSString *)ToHex:(long long int)tmpid {
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}









@end
