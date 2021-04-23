//
//  YBTimer.h
//  Interview02-GCD定时器
//
//  Created by wang on 2019/3/19.
//  Copyright © 2019 ciderybxu Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YBTimer : NSObject

+ (NSString *)execTask:(void(^)(void))task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async;

+ (NSString *)execTask:(id)target
              selector:(SEL)selector
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async;

+ (void)cancelTask:(NSString *)name;
@end

