/**
 * @file tsdk_login_interface.h
 *
 * Copyright(C), 2012-2018, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
 *
 * @brief Terminal SDK login and logout service module.
 */

#ifndef __TSDK_LOGIN_INTERFACE_H__
#define __TSDK_LOGIN_INTERFACE_H__

#include "tsdk_login_def.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */



/**
 * @brief [en]This interface is used to log in.
 *        [cn]登录
 *
 * @param [in] login_param                      [en]Indicates login server and user account information.
 *                                              [cn]登录服务器和用户帐号信息
 * @retval TSDK_RESULT                          [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                              [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_logout
 **/
TSDK_API TSDK_RESULT tsdk_login(IN TSDK_S_LOGIN_PARAM *login_param);


/**
 * @brief [en]This interface is used to log out of the current account.
 *        [cn]登出
 *
 * @retval TSDK_RESULT                          [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
 *                                              [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
 *
 * @attention NA
 * @see tsdk_login
 **/
TSDK_API TSDK_RESULT tsdk_logout();

/**
* @brief [en]This interface is used to change the password of current account.
*        [cn]修改密码
*
* @retval TSDK_RESULT                          [en]If it's success return TSDK_SUCCESS, otherwise return the corresponding error code.
*                                              [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention NA
* 
**/

TSDK_API TSDK_RESULT tsdk_change_password(TSDK_S_LOGIN_CHANGE_PASSWORD_PARAM *change_password_param);

/**
* @brief [en]This interface is used to change the password of current account.
*        [cn]校验证书
*
* @retval TSDK_RESULT                          [en]If it's success return TSDK_SUCCESS and cert time otherwise return the corresponding error code.
*                                              [cn]成功返回TSDK_SUCCESS和证书过期日期，失败返回相应错误码
*
* @attention NA
* 
**/
TSDK_API TSDK_RESULT tsdk_certificate_verify(IN TSDK_S_CMPT_CHECK_INFO *acCheckInfo, OUT TSDK_S_CMPT_DATETIME *expireTime);

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_LOGIN_INTERFACE_H__ */

