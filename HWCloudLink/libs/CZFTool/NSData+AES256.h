//
// NSData+AES256.h
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/5/25.
// Copyright © 2020 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData(AES256)
- (NSData *)aes256_encrypt:(NSString *)key;
- (NSData *)aes256_decrypt:(NSString *)key;
@end
