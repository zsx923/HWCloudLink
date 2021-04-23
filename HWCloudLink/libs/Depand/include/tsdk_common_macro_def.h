#ifndef __TSDK_COMMON_MACRO_DEF_H__
#define __TSDK_COMMON_MACRO_DEF_H__


#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */


#define TSDK_D_MAX_PATH_LEN                            (2047)      /**< [en]Indicates the maximum length of the path.
                                                                        [cn]最大路径长度 */
#define TSDK_D_MAX_ACCOUNT_LEN                         (127)       /**< [en]Indicates the maximum length of the account.
                                                                        [cn]最大帐号长度 */
#define TSDK_D_MAX_V3_ACCOUNT_LEN                      (256)       /**< [en]Indicates the maximum length of the account.
                                                                        [cn]smc3.0最大帐号长度 */
#define TSDK_D_MAX_PASSWORD_LENGTH                     (127)       /**< [en]Indicates the maximum length of the password.
                                                                        [cn]最大密码长度 */
#define TSDK_D_MAX_SOFTWARE_VER_LEN                    (127)       /**< [en]Indicates the maximum length of the software version.
                                                                        [cn]最大软件版本长度 */
#define TSDK_D_MAX_URL_LENGTH                          (255)       /**< [en]Indicates the maximum length of the common URL.
                                                                        [cn]最大URL长度 */
#define TSDK_D_MAX_PRODUCT_NAME_LEN                    (63)       /**< [en]Indicates the maximum length of the product name.
                                                                        [cn]最大产品信息长度 */
#define TSDK_D_MAX_DEVICE_SN_LEN                       (127)       /**< [en]Indicates the maximum length of the device SN.
                                                                        [cn]最大设备SN长度 */
#define TSDK_D_MAX_REASON_DESCRPTION_LEN               (1023)      /**< [en]Indicates the maximum length of the reason descrption.
                                                                        [cn]最大原因描述长度 */
#define TSDK_D_MAX_NUMBER_LEN                          (127)       /**< [en]Indicates the maximum length of the number
                                                                        [cn]最大号码长度  */
#define TSDK_D_MAX_TIME_FORMATE_LEN                    (31)        /**< [en]Indicates the maximum length of format time
                                                                        [cn]最大时间格式长度  */
#define TSDK_D_MAX_GROUP_URI_LEN                       (127)       /**< [en]Indicates the maximum length of uri
                                                                        [cn]最大群组URI长度  */
#define TSDK_D_MAX_EMAIL_LEN                           (265)       /**< [en]Indicates the maximum length of email
                                                                        [cn]最大email长度  */
#define TSDK_D_MAX_ZIPCODE_LEN                         (31)        /**< [en]Indicates the maximum length of zipcode
                                                                        [cn]最大邮编长度  */
#define TSDK_D_MAX_ANONYMOUS_DISPLAY_NAME_LEN          (64)        /**< [en]Indicates the maximum length of anonymous dispaly name
                                                                        [cn]链接入会最大显示名称长度 */
#define TSDK_D_MAX_DISPLAY_NAME_LEN                    (192)       /**< [en]Indicates the maximum length of dispaly name
                                                                        [cn]最大显示名称长度  */
#define TSDK_D_MAX_V3_DISPLAY_NAME_LEN                 (192)       /**< [en]Indicates the maximum length of dispaly name
                                                                        [cn]SMC3.0最大显示名称长度  */
#define TSDK_D_MAX_TOKEN_LEN                           (127)       /**< [en]Indicates the maximum length of token
                                                                        [cn]最大token长度  */
#define TSDK_D_MAX_PARTICIPANTID_LEN                   (127)       /**< [en]Indicates the maximum length of participant id
                                                                        [cn]最大成员标识长度  */
#define TSDK_D_MAX_SUBJECT_LEN                         (192)       /**< [en]Indicates the maximum length of conf subject
                                                                        [cn]最大会议主题长度  */
#define TSDK_D_MAX_CONF_PASSWORD_LEN                   (191)       /**< [en]Indicates the maximum length of conf password
                                                                        [cn]最大会议密码长度  */
#define TSDK_D_MAX_CONF_ID_LEN                         (191)        /**< [en]Indicates the maximum length of conference id
                                                                        [cn]最大会议ID长度  */
#define TSDK_D_MAX_CONF_ACCESS_LEN                     (63)        /**< [en]Indicates the maximum length of conference access code
                                                                        [cn]最大会议接入码长度*/
#define TSDK_D_MAX_KEYWORD_LEN                         (127)       /**< [en]Indicates the maximum length of the keyword
                                                                        [cn]最大关键字长度*/
#define TSDK_D_MAX_DEPARTMENT_ID_LEN                   (15)        /**< [en]Indicates the maximum length of the department id
                                                                        [cn]最大部门ID长度 */
#define TSDK_D_MAX_DEPARTMENT_NAME_LEN                 (511)       /**< [en]Indicates the maximum length of the department name.
                                                                        [cn]最大部门名称长度 */
#define TSDK_D_MAX_TITLE_LEN                           (127)       /**< [en]Indicates the maximum length of the keyword
                                                                        [cn]最大职务长度*/
#define TSDK_D_MAX_GENDER_LEN                          (7)         /**< [en]Indicates the maximum length of the contact gender
                                                                        [cn]最大性别长度 */
#define TSDK_D_MAX_SIGNATURE_LEN                       (255)       /**< [en]Indicates the maximum length of the contact signature
                                                                        [cn]最大签名长度 */
#define TSDK_D_MAX_SPEAKER_NUM                         (5)         /**< [en]Indicates the maximum number of speaker
                                                                        [cn]最大发言方数  */
#define TSDK_D_MAX_SHORT_NAME_LEN                      (63)        /**< [en]Indicates the maximum length of short name
                                                                        [cn]短名称最大长度  */
#define TSDK_D_MAX_CODEC_NAME_LEN                      (255)       /**< [en]Indicates the maximum length of codec name
                                                                        [cn]编解码名最大长度  */
#define TSDK_D_MAX_CA_PATH_LEN                         (511)       /**< [en]Indicates the maximum length of the CA path.
                                                                        [cn]CA证书路径最大长度 */
#if defined OS_WIN32 || defined WIN32
#define TSDK_D_MAX_LOG_PATH_LEN                        (255)       /**< [en]Indicates the maximum length of the log path.
                                                                        [cn]日志路径最大长度 */
#else
#define TSDK_D_MAX_LOG_PATH_LEN                        (255)       /**< [en]Indicates the maxi length of the log path.
                                                                        [cn]IOS 安卓日志路径最大长度 */
#endif
#define TSDK_D_MAX_MS_NUM                              (8)         /**< [en]Indicates the maximum number of the MS server.
                                                                        [cn]MS服务器最大数量 */
#define TSDK_D_MAX_CONF_TYPE_LEN                       (15)        /**< [en]Indicates the maximum length of conference type
                                                                        [cn]最大会议类型长度  */
#define TSDK_MAX_CONF_TIME_TYPE_LENGTH                 (30)        /**< [en]Indicates the maximum length conf time type
                                                                        [cn]会议时间类型的最大长度 */
#define TSDK_MAX_CONF_JOIN_LINK_LENGTH                 (255)       /**< [en]Indicates the maximum length conf join link
                                                                        [cn]入会链接的最大长度 */
#define TSDK_MAX_CONF_ATTENDEES_NAME_LENGTH            (321)       /**< [en]Maximum length of a participant
                                                                        [cn]SMC3.0 与会人最大长度*/
#define TSDK_MAX_CONF_CONFNAME_LENGTH                  (192)       /**< [en]Indicates the maximum length conf name
                                                                        [cn]SMC3.0 会议名称的最大长度*/
#define TSDK_MAX_CONF_NAME_CONFURI_LENGTH              (128)       /**< [en]Indicates the maximum length conf uri
                                                                        [cn]SMC3.0 uri的最大长度*/

#define TSDK_D_MAX_STATUS_DESC_LEN                     (47)        /**< [en]Indicates the maximum length of the status describtion
                                                                        [cn]最大状态描述长度 */
#define TSDK_D_MAX_TIMESTAMP_LEN                       (15)        /**< [en]Indicates the maximum length of the timestamp
                                                                        [cn]最大时间戳长度 */
#define TSDK_D_MAX_GROUP_NAME_LEN                      (511)       /**< [en]Indicates the maximum length of the name
                                                                        [cn]最大姓名长度 */
#define TSDK_D_MAX_GROUP_MANIFESTO_LEN                 (599)       /**< [en]Indicates the maximum length of group manifesto
                                                                        [cn]最大群公告长度 */
#define TSDK_D_MAX_GROUP_DESC_LEN                      (599)       /**< [en]Indicates the maximum length of group describe
                                                                        [cn]最大群描述长度 */
#define TSDK_D_MAX_WEB_SITE_LEN                        (1023)      /**< [en]Indicates the maximum length of the web site
                                                                        [cn]最大Web site长度 */
#define TSDK_D_MAX_AGE_LEN                             (7)         /**< [en]Indicates the maximum length of the age
                                                                        [cn]最大年龄长度  */
#define TSDK_D_MAX_DESCRPTION_LEN                      (1023)      /**< [en]Indicates the maximum length of the descrption.
                                                                        [cn]最大描述长度 */
#define TSDK_D_MAX_MESSAGE_CONTENT_LEN                 (1024*10)   /**< [en]Indicates the maximum length of message content
                                                                        [cn]最大消息内容长度 */
#define TSDK_D_MAX_LOGIN_TERMINAL_NUM                  (4)         /**< [en]Indicates the maximum number of login terminal
                                                                        [cn]最大登录终端数 */
#define TSDK_D_MAX_RANDOM_LEN                          (64)        /**< [en]Indicates the maximum length of random
                                                                        [cn]随机数最大长度  */
#define TSDK_D_MAX_DOMAIN_LENGTH                       (255)       /**< [en]Indicates the maximum length of the domain.
                                                                        [cn]最大域名长度 */
#define TSDK_D_MAX_AUDIO_CODEC_LEN                     (64)        /**< [en]Indicates the maximum length of audio codec
                                                                        [cn]音频编解码名称最大长度*/
#define TSDK_D_MAX_SVC_LABLE_NUM                       (7)         /**< [en]Maximum number of svc label number
                                                                        [cn]多流最多窗口个数 */
#define TSDK_D_MAX_SVC_WATCH_CONF_NUM                  (24)        /**< [en]Maximum number of svc watch conf number
                                                                        [cn]多流选看最多窗口个数 */
#define TSDK_D_MAX_REM_SITE_NUM                        (400)       /**< [en]Indicates the maximum length of the domain.
                                                                        [cn]远端会场的最大个数  */
#define TSDK_D_VMR_MAX_NAME_LEN                        (384)       /**< [en]Indicates the maximum length of vmr name
                                                                        <br>[cn]VMR名称最大长度  */
#define TSDK_D_MAX_ACCESS_NUM_LEN                      (128)       /**< [en]Indicates the maximum length of access number
                                                                        <br>[cn]VMR最大会议接码长度  */
#define TSDK_D_MAX_VMR_CONF_ID_LEN                     (32)        /**< [en]Indicates the maximum length of VMR conf id
                                                                        <br>[cn]VMR会议ID最大长度  */
#define TSDK_D_MAX_PASSWORD_LEN                        (192)       /**< [en]Indicates the maximum length of password
                                                                        <br>[cn]VMR密码最大长度  */
#define TSDK_D_MAX_URL_LEN                             (256)       /**< [en]Indicates the maximum length of url
                                                                        <br>[cn]VMR URL最大长度  */
#define TSDK_D_MAX_DESCRIPTION_LEN                     (766)       /**< [en]Indicates the maximum length of description
                                                                        <br>[cn]VMR描述的最大长度  */
#define TSDK_D_MAX_NAME_LEN                            (256)       /**< [en]Indicates the maximum length of name
                                                                        <br>[cn]VMR名称最大长度  */
#define TSDK_D_MAX_ACCOUNT_ID_LEN                      (128)       /**< [en]Indicates the maximum number of account id
                                                                        <br>[cn]VMR与会者account id最大长度 */
#define TSDK_D_MAX_VMR_INDEX_LEN                       (36)        /**< [en]Indicates the maximum length of VMR index 
                                                                        <br>[cn]VMR索引最大长度 */
#define TSDK_D_MAX_VMR_NUM                             (5)         /**< [en]Indicates the maximum length of vmr number
                                                                        <br>[cn]一次返回的vmr最大个数 */
#define TSDK_MAX_IPADDR_HEX_LEN                        (46)        /**< [en]Indicates the maximum length of IP address
                                                                        <br>[cn]IP地址最大长度 */
#define TSDK_D_CONF_MAX_PASSWORD_LENGTH                (6)         /**< [en]Indicates the maximum length of the conference password.
                                                                        [cn]最大会议密码长度 */
#define TSDK_D_CHAIRMAN_MAX_PASSWORD_LENGTH            (6)         /**< [en]Indicates the maximum length of the chairman password.
                                                                        [cn]最大主席密码长度 */
#define TSDK_D_LOGIN_MAX_TOKEN_LEN                     (256)       /**< [en]Indicates the maximum token of login param.
                                                                        [cn]最大登录Token长度 */
#define TSDK_D_LOGIN_MAX_USERNAME_LEN                  (128)       /**< [en]Indicates the maximum length of the login username 
                                                                        [cn]登录用户名最大长度*/
#define TSDK_D_LOGIN_MAX_USER_TYPE_LEN                 (128)       /**< [en]Indicates the maximum length of the user type 
                                                                        [cn]登录用户类型最大长度*/
#define TSDK_D_LOGIN_MAX_SERVICE_LEN                   (128)       /**< [en]Indicates the maximum length of the login server address
                                                                        [cn]登录服务器地址最大长度*/
#define TSDK_D_LOGIN_MAX_PASSWORD_LENGTH               (32)        /**< [en]Indicates the maximum length of the login password.
                                                                        [cn]登录密码最大长度 */
#define TSDK_D_MAX_APP_NAME_LEN                        (255)       /**< [en]Indicates the maximum length of the app name.
                                                                        [cn]最大产品信息长度 */
#define TSDK_D_MAX_WND_TITLE_LEN                       (192)       /**< [en]Indicates the maximum length of the window title.
                                                                        [cn]最大窗口标题长度 */
#define TSDK_D_MAX_LANGUAGE_LEN                        (63)        /**< [en]Indicates the maximum length of the language.
                                                                        [cn]最大语言长度 */
#define TSDK_D_MAX_RESOURCES_PATH_LEN                  (511)       /**< [en]Indicates the maximum length of the resources path.
                                                                        [cn]最大资源路径长度 */
#define TSDK_D_MAX_USER_FILES_PATH_LEN                 (511)       /**< [en]Indicates the maximum length of the user files path.
                                                                        [cn]最大用户文件路径长度 */
#define TSDK_D_MAX_TIMEZONEID_LEN                      (32)        /**< [en]Maximum Time Zone
                                                                    <br>[cn]最大时区ID*/
#define TSDK_D_MAX_TIMEZONE_NAME_LEN                   (64)        /**< [en]Maximum Time Zone name
                                                                    <br>[cn]最大时区名称*/
#define TSDK_D_MAX_TIMEZONE_DESC_LEN                   (128)       /**< [en]Maximum Time Zone Description.
                                                                    <br>[cn]最大时区描述*/
#define TSDK_D_MAX_V3_CONFERENCE_ID                    (64)        /**< [en]Maximum name length
                                                                    <br>[cn]最大名称长度 */
#define TSDK_D_MAX_CONFERENCE_ID                       (127)       /**< [en]Maximum name length
                                                                    <br>[cn]通用最大名称长度 127*/
#define TSDK_D_MAX_V3_MOBILE_LEN                       (40)        /**< [en]Maximum length of a phone number
                                                                    <br>[cn]电话号码最大长度*/

#define TSDK_D_MAX_CODEC_DESCRPTION_LEN                (127)

#define TSDK_D_MAX_CONTENT_ID_LEN                      (127)

#define TSDK_D_MAX_CONTENT_LEN                         (127)

#define TSDK_D_MAX_FONT_NAME_LEN                       (127)

#define TSDK_D_MAX_CAMERA_NUM                          (5)

#define TSDK_D_MAX_MIC_NUM                             (5)

#define TSDK_D_MAX_CHAT_MSG_LEN                        (16*1024)   /**< [en]Indicates the maximum length of the chat message.
                                                                        [cn]数据会议中发送消息的最大长度 */

#define TSDK_D_MAX_PROJECTION_CODE_LEN                 (6)         /**< [en]Indicates the maximum length of the projection code
                                                                        [cn]投影码长度  */

#define TSDK_D_MAX_AS_WINDOW                           (256)       /**< [en]Indicates the maximum of the windows info.
                                                                        [cn]最大应用程序窗口 */

#define TSDK_MAX_TERMINAL_TYPE_NUMBER_LEN              (32)        /**< [en]Indicates the maxinum length of the terminal type. 
                                                                        [cn]终端类型最大长度 */
#define TSDK_MAX_TERMINAL_RATE_STRINGLEN               (13)        /**< [en]Indicates the maximum length of the terminal rate.
                                                                        [cn]会场带宽最大长度 */
//tup_conf_as_senduserdata  msg_id [0-84]
#define TSDK_CONF_INVITE_USER_DATA_SHARING             (3)         /**< [en]Indicates ***
                                                                        [cn]邀请用户进行数据共享和webclient互通消息命令，若修改和webclient同步  */

#define TSDK_CONF_END_INVITE_USER_DATA_SHARING         (4)         /**< [en]Indicates ***
                                                                        [cn]结束邀请用户进行数据共享和webclient互通消息命令，若修改和webclient同步 */

#define TSDK_CONF_TERMINAL_LOCAL_NAME_LEN              (192)       /**< [en]Indicates ***
                                                                        [cn]会议中终端别名的最大长度 */

#define TSDK_AS_REFUSE_USER_INVITE_SHARING             (6)         /**< [en]Indicates ***
                                                                        [cn]通知邀请用户：拒绝邀请和webclient互通消息命令，若修改和webclient同步  */

#define TSDK_AS_AGREE_USER_INVITE_SHARING              (7)         /**< [en]Indicates ***
                                                                        [cn]通知邀请用户：同意邀请和webclient互通消息命令，若修改和webclient同步  */

#define TSDK_AS_NOTICE_ALL_USERS_SHIFT_SHARING_TAB     (19)        /**< [en]Indicates ***
                                                                        [cn]webclient中通知其他与会者切换屏幕或程序共享tab页签
                                                                         和webclient互通消息命令，若修改和webclient同步  */

#define TSDK_AS_NOTICE_ALL_USERS_CLOSE_SHARING_TAB     (20)        /**< [en]Indicates ***
                                                                        [cn]webclient中通知其他与会者关闭屏幕或程序共享tab页签
                                                                         和webclient互通消息命令，若修改和webclient同步  */
#define TSDK_D_MAX_SVC_NUM                             (24)        /**< [en]Indicates the maximum number of svc stream
                                                                        [cn]多流时，流的最大个数 */
#define TSDK_MAX_IP_LEN                                (128)       /**< [en]Indicates the maximum length of IP Address
                                                                        [cn]IP地址的最大长度 */
#define TSDK_LOGIN_D_MAX_PASSWORD_LEN                  (256)       /**< [en]Indicates the maximum length of the login password
                                                                        [cn]IVR密码最大长度*/
#define TSDK_LOGIN_D_MAX_MEDIATYPE_LEN                 (256)       /**< [en]Indicates the MediaType type length.
                                                                        [cn]MediaType类型长度 */
#define TSDK_LOGIN_D_MAX_URL_LENGTH                    (256)       /**< [en]Indicates the maximum length of IP Address
                                                                        [cn]IP地址的最大长度 */
#define TSDK_LOGIN_MAX_RECORD_VERSION_LEN              (64)        /**< [en]Indicates the maximum num of record version.
                                                                        [cn]软终端版本号最大长度 */
#define TSDK_S_MAX_ISSUER_NAME                         (256)       /**< [en]Indicates cert issuer max length
                                                                        [cn]证书颁发者最大长度 */
#define TSDK_S_MAX_ROOT_CERT_NUMBER                    (20)        /**< [en]Indicates root cert max mumber
                                                                        [cn]根证书最多个数 */
#define TSDK_MAX_ORGANIZATION_NAME_LEN                 (256)       /**< [en]Maximum length of the organization name.
                                                                        [cn]组织名称的最大长度 */
#define TSDK_D_MAX_TIME_LEN                            (32)        /**< [en]Chairperson password/Guest password (a string of 6 digits and a number ranging from 0 to 9)
                                                                        [cn]主席密码/来宾密码(长度为6位,0~9 之间的数字)*/
#define TSDK_D_MAX_TYPE_LEN                            (32)        /**< [en]Length of the terminal type
                                                                        [cn]终端类型长度*/
#define TSDK_MAX_CONFERENCE_ID_LEN                     (36)        /**< [en]Maximum length of the conference ID.
                                                                        [cn]会议ID的最大长度 */
#define TSDK_D_MAX_DEVICE_NUM                          (10)        /**< [en]Indicates max video device
                                                                        [cn]视频设备变更最大数 */
#define TSDK_CALL_D_MAX_LENGTH_NUM                     (256)       /**< [en]Indicates the maximum length of universal string
                                                                        [cn]通用字符串最大长度*/
#define TSDK_D_MAX_SERVER_ADDR_LEN                     (256)       /**< [en]Indicates the maximum length of server port
                                                                        [cn]通用服务器ip最大长度*/
#define TSDK_D_MAX_VMR_NUMBER_LEN                      (128)       /**< [en]Indicates the maximum length of vmr number
                                                                        [cn]VMR号码长度*/
#define TSDK_D_MAX_SMC3_USER_INFO_STRING_LEN           (128)       /**< [en]Indicates string with the maximum length 128.
                                                                        [cn]SMC3.0用户信息中部分字符串最大长度为128 */
#define TSDK_D_MAX_MODEL_NAME_LEN                      (64)        /**< [en]Indicates the maximum length of model.
                                                                        [cn]最大模块名称长度 */
#define TSDK_D_MAX_EXTRA_PARAMETER_NUM                 (256)       /**< [en]Indicates the maximum number of extra parameter name.
                                                                        [cn]额外参数最大个数*/
#define TSDK_LOGIN_D_MAX_NUM                           (48)        /**< [en]Indicates the maximum length of the scAdress array.
                                                                        [cn]SMC返回24对接入地址 24个IPV4地址 24个IPV6地址 */
#define TSDK_D_RESTORE_ID_MAX_LENGTH                   (64)        /**< [en]Indicates the Restore_id field delivered by 
                                                                            the MCU in the SC two-node cluster switchover scenario.
                                                                        [cn]SC双机倒换场景MCU下发的restore_id字段*/
#define TSDK_D_RESTORE_CONFID_MAX_LENGTH               (256)       /**< [en]Indicates the conf_id field delivered by 
                                                                            the MCU in the SC two-node cluster switchover scenario.
                                                                        [cn]SC双机倒换场景MCU下发的conf_id字段*/
#define TSDK_D_SC_SWITCH_MAX_DURATION                  (300)       /**< [en]Indicates the Maximum duration
                                                                            of active/standby switchover.
                                                                        [cn]SC双机倒换最大时长*/
#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#endif /* __TSDK_COMMON_MACRO_DEF_H__ */

