/**
* @file tsdk_maintain_interface.h
*
* Copyright(C), 2012-2020, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
*
* @brief Terminal SDK maintain service module.
*/

#ifndef __TSDK_MAINTAIN_INTERFACE_H__
#define __TSDK_MAINTAIN_INTERFACE_H__

#include "tsdk_maintain_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif /* __cplusplus */



/**
* @brief [en]This interface is used to log upload.
*        [cn]日志上传
*
* @param [in] logPath                        [en]Indicates log path.
*                                                [cn]日志压缩文件路径
* @retval TSDK_RESULT                            [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] corresponding callback event is TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT.
*            [cn] 对应的回调事件为 TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT
* @see TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT
**/
TSDK_API TSDK_RESULT tsdk_log_upload(IN TSDK_CHAR* logPath);


/**
* @brief [en]This interface is used to show softterminal download info
*        [cn]软终端下载信息查询
*
* @param [in] server_cfg                        [en]Indicates log path.
*                                               [cn]服务器信息（地址和端口）
* @retval TSDK_RESULT                           [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                               [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] corresponding callback event is TSDK_E_MAINTAIN_EVT_SOFTTERMINAL_DOWNLOAD_INFO_IND.
*            [cn] 对应的回调事件为 TSDK_E_MAINTAIN_EVT_SOFTTERMINAL_DOWNLOAD_INFO_IND
* @see TSDK_E_MAINTAIN_EVT_SOFTTERMINAL_DOWNLOAD_INFO_IND
**/
TSDK_API TSDK_RESULT tsdk_get_softterminal_download_info(IN TSDK_VOID* server_cfg);


#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_MAINTAIN_INTERFACE_H__ */

