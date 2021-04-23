//
//  SearchParam.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface SearchParam : NSObject

// 搜索关键字
@property (nonatomic, copy) NSString *keywords;
// 当前分组
@property (nonatomic, copy) NSString *curentBaseDn;
// 排序属性
@property (nonatomic, copy) NSString *sortAttribute;
// 是否搜索特定分组下的地址: 如果是则需调用 SetCurrentBaseDN() 函数设置带ou字段的DN, 否则默认搜索所有分组层级下的地址本
@property (nonatomic, assign) int searchSingleLevel;
// 是否分页, 分页每页联系人条数, 若不支持分页,下面两个参数全部传递0
@property (nonatomic, assign) int pageSize;
// 若分页，0标识首页查询；其他情况，标识page_cookie的长度
@property (nonatomic, assign) int cookieLength;
// 非文本，需要memcpy_s，上次分页查询由服务器返回
@property (nonatomic, copy) NSData * pageCookie;

@end
