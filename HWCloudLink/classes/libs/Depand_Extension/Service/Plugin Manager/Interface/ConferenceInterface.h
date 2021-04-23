//
//  ConferenceInterface.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#ifndef ConferenceInterface_h
#define ConferenceInterface_h

#import "Defines.h"
@class ChatMsg;
@class ConfBaseInfo;
@class TimezoneModel;
@class ConfAttendeeInConf;

extern NSString *const CONFERENCE_END_NOTIFY;
extern NSString *const CONFERENCE_CONNECT_NOTIFY;

@class TupCallNotifications,ConfMember,TUPConferenceNotifications;
@protocol ConferenceServiceDelegate <NSObject>
@required


/**
 * This method is used to deel Conference event callback
 * 会议事件回调
 *@param ecConfEvent           Indicates EC_CONF_E_TYPE enum value
 *                             会议事件类型
 *@param resultDictionary      result value
 *                             回调信息集
 */
-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary;

@end

@protocol DataConferenceChatMessageDelegate <NSObject>

/**
 * This method is used to deel with receiving chat message
 * 收到聊天信息，进行处理
 */
- (void)didReceiveChatMessage:(ChatMsg *)chatMessage;

@end

@protocol ConferenceInterface <NSObject>

/**
 *Indicates conference service delegate
 *会议业务代理
 */
@property (nonatomic ,weak)id<ConferenceServiceDelegate> delegate;

/**
 *Indicates data conference chat service delegate
 *数据会议中文字聊天业务代理
 */
@property (nonatomic, weak) id<DataConferenceChatMessageDelegate> chatDelegate;

/**
 *Indicates whether have joined data conf
 *判断是否加入数据会议
 */
@property (nonatomic, assign) BOOL isJoinDataConf;


/**
 *辅流数据
 */
@property (nonatomic, strong) NSDictionary* auxData;

@property (nonatomic,strong) NSData *lastConfSharedData; //数据会议共享数据

/**
 *Indicates whether have Auxiliary stream
 *判断会议中是否有辅流数据
 */
@property (nonatomic, assign) BOOL isHaveAux;

/**
 *Indicates whether have Auxiliary stream
 *判断会议中是否正在接收辅流
 */
@property (nonatomic, assign) BOOL isRecvingAux;

/**
 *Indicates whether have Chair
 *判断会议中是否有主席
 */
@property (nonatomic, assign) BOOL isHaveChair;

/**
 *Indicates whether have Auxiliary stream
 *判断会议中是否正在发送辅流
 */
@property (nonatomic, assign) BOOL isSendAux;

/**
 *Indicates whether have video in conference
 *判断是否会议中带视频能力
 */
@property (nonatomic,assign) BOOL isVideoConfInvited;

/**
 *Indicates whether have joined attendee array
 *与会者列表数组
 */
@property (nonatomic, strong) NSMutableArray<ConfAttendeeInConf *> *haveJoinAttendeeArray;     //current conference'attendees

/**
 *Indicates message array
 *会议消息数组
 */
@property (nonatomic, strong) NSMutableArray *messageArray;

/**
 *Indicates current base confInfo
 *当前会议信息
 */
@property (nonatomic, strong) ConfBaseInfo *currentConfBaseInfo;
/**
 *Indicates vmr confInfo
 *vmr信息
 */
@property (nonatomic, strong) ConfBaseInfo *vmrBaseInfo;

/**
 *Indicates conf type enum
 *会议类型枚举
 */
@property (nonatomic, assign) EC_CONF_TOPOLOGY_TYPE uPortalConfType;

/**
 *Indicates self join conf number
 *自己加入会议的号码
 */
@property (nonatomic, copy) NSString *selfJoinNumber;                    //self join Number in current conference

/**
 * This method is used to dealloc conference params
 * 销毁会议参数信息
 */
-(void)restoreConfParamsInitialValue;


/**
 * This method is used to create conference
 * 创建会议，预约会议
 * @param attendeeArray one or more attendees
 * @param mediaType EC_CONF_MEDIATYPE value
 * @param subject 主题
 * @param startTime 会议开始时间
 * @param confLen 会议时长
 * @param chairmanPassword 主席密码
 * @param guestPassword 来宾密码
 * @param timezoneModel 时区
 * @param personalConfId vmr会议ID
 * @return YES or NO
 */
-(BOOL)createConferenceWithAttendee:(NSArray *)attendeeArray
                          mediaType:(EC_CONF_MEDIATYPE)mediaType
                            subject:(NSString *)subject
                          startTime:(NSDate *)startTime
                            confLen:(int)confLen
                           chairmanPassword:(NSString *)chairmanPassword
                   guestPassword:(NSString *)guestPassword
                      timezoneModel:(TimezoneModel *)timezoneModel
                    personalConfId:(NSString *)personalConfId;

///*
// 3.0 vmr 会议单独处理
// */
//-(BOOL)createVMRConferenceWithAttendee:(NSArray *)attendeeArray
//                          mediaType:(EC_CONF_MEDIATYPE)mediaType
//                            subject:(NSString *)subject
//                          startTime:(NSDate *)startTime
//                            confLen:(int)confLen
//                  isMultiStreamConf:(BOOL)isMultiStreamConf
//                           password:(NSString *)password
//                         timezoneModel:(TimezoneModel *)timezoneModel
//                         confId: (NSString *)confId
//                         chairPwd:(NSString *)chairPwd
//                         generalPwd:(NSString *)generalPwd;
/*
 3.0 创建vmr 会议
 * 3.0 vmr 发起会议
 *@param attendArray 与会者
 *@param mediaType  会议类型
 *@param subject  会议主题
 *@param confId  accessNumber
 *@param chairPwd 主席密码
 *@param generalPwd 来宾密码
 *@return YES or NO
 */
-(BOOL)createVMRConferenceWithAttendee:(NSArray *)attendeeArray
                          mediaType:(EC_CONF_MEDIATYPE)mediaType
                            subject:(NSString *)subject
                         confId: (NSString *)confId
                         chairPwd:(NSString *)chairPwd
                         generalPwd:(NSString *)generalPwd;

/*
 * This method is start a common conference  2.0 and 3.0 
 * 发起会议
 *@param attendArray 与会者
 *@param mediaType  会议类型
 *@param subject  会议主题
 *@param password 来宾密码
 *@return YES or NO
 */
- (BOOL)creatCommonConferenceWithAttendee:(NSArray *)attendArray
                                mediaType:(EC_CONF_MEDIATYPE)mediaType
                                  subject:(NSString *)subject
                                 password:(NSString *)password;
/**
 * This method is used to join conference
 * 加入会议
 *@param confId conference id
 *@param accessNumber access number
 *@param confPassWord conf pass word
 *@param joinNumber join conference number
 *@param isVideoJoin is video join
 *@return YES or NO
 */
-(BOOL)joinConferenceWithConfId:(NSString *)confId AccessNumber:(NSString *)accessNumber confPassWord:(NSString *)confPassWord joinNumber:(NSString*)joinNumber isVideoJoin:(BOOL)isVideoJoin;

/**
 * This method is used to get conference list
 * 获取会议列表
 *@param pageIndex pageIndex default 1
 *@param pageSize pageSize default 10
 *@return YES or NO
 */
-(BOOL)obtainConferenceListWithPageIndex:(int)pageIndex pageSize:(int)pageSize;

/**
* @ingroup ConfCtrl
* @brief [en]This interface is used to Requested VMR list.
*            [cn]请求vmr列表
*
* @retval TSDK_RESULT        [en]If success return TSDK_SUCCESS, otherwise return corresponding error code.
*                                              [cn]成功返回TSDK_SUCCESS，失败返回相应错误码
*
* @attention [en] corresponding callback event is TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT.
*                   [cn] 对应的回调事件为TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT
* @see TSDK_E_CONF_EVT_GET_VMR_LIST_RESULT
**/
-(BOOL)getVmrList;
 


/*
 3.0 更新vmr 数据
 *@param chairStr 主席密码
 *@param generalStr 来宾密码
 *@param confId  会议id
 *@return YES or NO
 */
- (BOOL)updateVmrList:(NSString *)chairStr generalStr:(NSString *)generalStr confId:(NSString *)confId;
/*
//2。0调试，
-(BOOL)getVmrListWithTerminal:(NSString *)terminal;
*/
 
/**
 * This method is used to add attendee to conference
 * 添加与会者到会议中
 @param attendeeArray attendees
 @return YES or NO
 */

-(BOOL)confCtrlAddAttendeeToConfercene:(NSArray *)attendeeArray;

/**
 * This method is used to remove attendee
 * 移除与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRemoveAttendee:(NSString *)attendeeNumber;

/**
 * This method is used to hang up attendee
 * 挂断与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlHangUpAttendee:(NSString *)attendeeNumber;

/**
 * This method is used to recall attendee
 * 重呼与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRecallAttendee:(NSString *)attendeeNumber;

/**
 * This method is used to leave conference
 * 离开会议
 *@return YES or NO
 */
-(BOOL)confCtrlLeaveConference;

/**
 * This method is used to end conference (chairman)
 * 结束会议
 *@return YES or NO
 */
-(BOOL)confCtrlEndConference;

/**
 * This method is used to mute conference (chairman)
 * 主席闭音会场
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteConference:(BOOL)isMute;

/**
 * This method is used to mute attendee (chairman)
 * 主席闭音与会者
 *@param attendeeNumber attendee number
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteAttendee:(NSString *)attendeeNumber isMute:(BOOL)isMute;

/**
 * This method is used to raise hand (Attendee)
 * 与会者举手
 *@param raise YES raise hand, NO cancel raise
 *@param attendeeNumber join conference number
 *@return YES or NO
 */
- (BOOL)confCtrlRaiseHand:(BOOL)raise attendeeNumber:(NSString *)attendeeNumber;

/**
 * This method is used to release chairman right (chairman)
 * 释放主席权限
 *@param chairNumber chairman number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlReleaseChairman:(NSString *)chairNumber;

/**
 * This method is used to request chairman right (Attendee)
 * 申请主席权限
 *@param chairPwd chairman password
 *@param newChairNumber attendee's number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlRequestChairman:(NSString *)chairPwd number:(NSString *)newChairNumber;



/**
 * This interface is used to postpone conference.
 * 延长会议
 *@param time Indicates postpone time, the unit is minute.
 *@return YES or NO
 **/
-(BOOL)PostponeConferenceTime:(NSString *)time;

/**
 * This method is used to judge whether is uportal mediax conf
 * 判断是否为mediax下的会议
 */
- (BOOL)isUportalMediaXConf;

/**
 * This method is used to judge whether is uportal smc conf
 * 判断是否为smc下的会议
 */
- (BOOL)isUportalSMCConf;

/**
 * This method is used to watch attendee
 * 屏幕共享中加入某一个通道
 */
-(void)appShareAttach:(id)bfView;

/**
 * This method is used to watch attendee
 * 屏幕共享中加入某一个通道
 */
-(void)appShareDetach;

/**
 * This method is used to boardcast attendee
 * 广播与会者
 */
- (void)broadcastAttendee:(NSString *)attendeeNumber isBoardcast:(BOOL)isBoardcast;

/**
 * This method is used to boardcast attendee
 * 选看与会者
 */
-(void)watchAttendeeNumber:(NSString *)attendeeNumber;

/**
 * This method is used to watch attendee
 * SVC选看与会者
 * Block(接口调用是否成功，哪一个接口回调 0:选看，1:选看结果，错误信息，选看哪一个数组的与会者)
 */
-(void)svcWatchAttendeeArray:(NSArray *)attendeeArray isBigPicture:(BOOL)isBigPicture bandWidth:(UInt32)bandWidth isH265SVC:(BOOL)isH265Svc watchComplete:(void(^)(BOOL, NSString*, NSArray<ConfAttendeeInConf*>*))watchBlock complete:(void(^)(BOOL, NSString*, NSArray<ConfAttendeeInConf*>*, NSDictionary*))block;

/**
 * This interface is used to join a conference anonymously.
 * 通过匿名方式加入会议
 *@param disPlayName Indicates display name.
 *@param confID Indicates conference id.
 *@param passWord Indicates conference password.
 *@param serverAdd Indicates the server address.
 *@param random xxxxxxxxxxx
 *@param serverPort Indicates the server port.
 *@param authType Indicates the conference auth type.
 *@return YES or NO
 */
- (BOOL)joinConferenceWithDisPlayName:(NSString *)disPlayName ConfId:(NSString *)confID PassWord:(NSString *)passWord ServerAdd:(NSString *)serverAdd Random:(NSString *)random ServerPort:(int)serverPort AuthType:(int)authType;

/**
 * This interface is invoked by the chairman in a conference to set or cancel a common participant speak，dose not support roll call chairman self.
 *  [cn]点名发言或取消点名接口
 不支持点名主席，因为点名主席后，取消点名是广播主席，闭音被点名的与会者，这样主席
 会被闭音，而主席取消点名会闭音主席自己，不符合使用场景，所以在点名接口中限制点名主席
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRollCallAttendee:(NSString *)attendeeNumber;

/**
*  会场切换单双向
*@param isOneWay 是否单向
*@return YES or NO
*/
-(BOOL)confCtrlSwitchAuditSitesDir:(BOOL)isOneWay;

-(BOOL)confctrlGetTimeZoneList;
/**
*  取消预约会议
*@param confId 会议号3.0
*@param completionBlock  result call back
*/
-(void)cancelConferenceConfId:(NSString *)confId
                   completion:(void (^)(BOOL isSuccess, NSError *error))completionBlock;
/**
*  日志上传---本地日志和sdk日志一起
*@param logPath .zip 日志的绝对路径
*@return  YES  成功
*/
- (BOOL)upLoadLogWithPath:(NSString*)logPath;
@end

#endif /* ConferenceInterface_h */


