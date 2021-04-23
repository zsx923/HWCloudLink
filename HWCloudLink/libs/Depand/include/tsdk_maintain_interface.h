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
*        [cn]��־�ϴ�
*
* @param [in] logPath                        [en]Indicates log path.
*                                                [cn]��־ѹ���ļ�·��
* @retval TSDK_RESULT                            [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                                [cn]�ɹ�����TSDK_SUCCESS��ʧ�ܷ�����Ӧ������
*
* @attention [en] corresponding callback event is TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT.
*            [cn] ��Ӧ�Ļص��¼�Ϊ TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT
* @see TSDK_E_MAINTAIN_EVT_LOG_UPLOAD_RESULT
**/
TSDK_API TSDK_RESULT tsdk_log_upload(IN TSDK_CHAR* logPath);


/**
* @brief [en]This interface is used to show softterminal download info
*        [cn]���ն�������Ϣ��ѯ
*
* @param [in] server_cfg                        [en]Indicates log path.
*                                               [cn]��������Ϣ����ַ�Ͷ˿ڣ�
* @retval TSDK_RESULT                           [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                               [cn]�ɹ�����TSDK_SUCCESS��ʧ�ܷ�����Ӧ������
*
* @attention [en] corresponding callback event is TSDK_E_MAINTAIN_EVT_SOFTTERMINAL_DOWNLOAD_INFO_IND.
*            [cn] ��Ӧ�Ļص��¼�Ϊ TSDK_E_MAINTAIN_EVT_SOFTTERMINAL_DOWNLOAD_INFO_IND
* @see TSDK_E_MAINTAIN_EVT_SOFTTERMINAL_DOWNLOAD_INFO_IND
**/
TSDK_API TSDK_RESULT tsdk_get_softterminal_download_info(IN TSDK_VOID* server_cfg);


#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_MAINTAIN_INTERFACE_H__ */

