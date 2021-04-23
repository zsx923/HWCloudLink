//
//  DeptInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
//#import "tsdk_eaddr_def.h"

@interface DeptInfo : NSObject

@property (copy, nonatomic)NSString *deptId;       // current detartment Id
@property (copy, nonatomic)NSString *parentId;     // parent detartment Id
@property (copy, nonatomic)NSString *deptName;     // current detpment name
@property (assign, nonatomic)BOOL expand;//子节点是否展示
@property (assign, nonatomic)BOOL isSelected;//是否被选中
@property (nonatomic,strong)NSMutableArray *children;

/**
 This method is used to transform TSDK_S_DEPARTMENT_INFO data to  DeptInfo data

 @param deptInfo TSDK_S_DEPARTMENT_INFO
 @return DeptInfo
 */
//+ (DeptInfo *)deptInfoTransformFrom:(TSDK_S_DEPARTMENT_INFO)deptInfo;

@end
