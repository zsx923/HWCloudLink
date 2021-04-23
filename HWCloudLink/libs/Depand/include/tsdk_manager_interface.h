/**
 * @file tsdk_manager_interface.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK initialization and service config management.
 */

#ifndef __TSDK_MANAGER_INTERFACE_H__
#define __TSDK_MANAGER_INTERFACE_H__

#include "tsdk_manager_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */


/**
 * @brief [en] This interface is used to set service parameters
 *        [cn] 设置业务参数
 *
 * @param [in] config_id                        [en] Indicates config ID
 *                                              [cn] 参数配置ID,
 * @param [in] param                            [en] Indicates data type corresponding to the configured parameter.
 *                                              [cn] 参数值，根据配置的ID确定数据类型
 *
 * @retval TSDK_RESULT                          [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                              [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] NA.
 *            [cn] 暂无
 **/
TSDK_API TSDK_RESULT tsdk_set_config_param(IN TSDK_E_CONFIG_ID config_id, IN TSDK_VOID *param);


/**
 * @brief [en] This interface is used to init terminal sdk component
 *        [cn] 初始化终端SDK组件
 *
 * @param [in] app_info                         [en] Indicates application program info param
 *                                              [cn] 应用程序信息参数
 * @param [in] notify                           [en] Indicates definition of callback functions for events.
 *                                              [cn] 事件通知回调函数地址
 *
 * @retval TSDK_RESULT                          [en] If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                              [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] NA.
 *            [cn] 暂无
 * @see tsdk_uninit
 * @see tsdk_set_config_param
 **/
TSDK_API TSDK_RESULT tsdk_init(IN TSDK_S_APP_INFO_PARAM *app_info, IN TSDK_FN_CALLBACK_PTR notify);


/**
 * @brief [en] This interface is used to uninit the terminal sdk component
 *        [cn] 去初始化终端SDK组件
 *
 * @retval TSDK_RESULT                          [en] If it's success return TSDK_SUCCESS, otherwise, return the corresponding error code.
 *                                              [cn] 成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention [en] This interface is invoked before program exit, stop related service before it's invoked
 *            [cn] 程序退出前调用，调用前停止相关业务
 * @see tsdk_init
 **/
TSDK_API TSDK_RESULT tsdk_uninit(TSDK_VOID);

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_MANAGER_INTERFACE_H__ */

