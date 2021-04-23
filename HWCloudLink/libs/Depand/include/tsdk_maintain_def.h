/**
* @file tsdk_maintain_def.h
*
* Copyright(C), 2012-2020, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
*
* @brief Terminal SDK maintain enum and struct define.
*/

#ifndef __TSDK_MAINTAIN_DEF_H__
#define __TSDK_MAINTAIN_DEF_H__

#include "tsdk_def.h"
#include "tsdk_manager_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif /* __cplusplus */

typedef struct tagMAINTAIN_SERVER_CFG_S
{
    TSDK_CHAR acServerAddr[TSDK_D_MAX_URL_LENGTH];        /**< [en]Indicates server address, ip address string or domain address.
                                                                [cn]��������ַ��IP��ַ�ִ���������ַ */
    TSDK_UINT32 ulServerPort;                              /**< [en]Indicates server port, now have no parser port.
                                                                [cn]�������˿ڣ�����δ�����˿ڣ���ʱ���� */
} MAINTAIN_SERVER_CFG_S;

#define TSDK_SOFTTERMINAL_VERSION_NUM_MAX_LEN      64

#define TSDK_SOFTTERMINAL_VERSION_LINK_MAX_LEN    256

typedef struct tagTSDK_SMC_S_SOFTTERMINAL_DOWNLOAD_INFO
{
    TSDK_UINT8 ucPcVersionNum[TSDK_SOFTTERMINAL_VERSION_NUM_MAX_LEN];
    TSDK_UINT8 uciOSVersionNum[TSDK_SOFTTERMINAL_VERSION_NUM_MAX_LEN];
    TSDK_UINT8 ucAndroidVersionNum[TSDK_SOFTTERMINAL_VERSION_NUM_MAX_LEN];
    TSDK_UINT8 ucPcLink[TSDK_SOFTTERMINAL_VERSION_LINK_MAX_LEN];
    TSDK_UINT8 uciOSLink[TSDK_SOFTTERMINAL_VERSION_LINK_MAX_LEN];
    TSDK_UINT8 ucAndroidLink[TSDK_SOFTTERMINAL_VERSION_LINK_MAX_LEN];
} TSDK_SMC_S_SOFTTERMINAL_DOWNLOAD_INFO;

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_LOGIN_DEF_H__ */
