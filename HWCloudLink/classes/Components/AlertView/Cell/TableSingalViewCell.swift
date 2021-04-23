//
//  TableSingalViewCell.swift
//  HWCloudLink
//
//  Created by mac on 2020/5/23.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableSingalViewCell: UITableViewCell {

    static let CELL_TWO_LABEL_ROW_ID = "CELL_TWO_LABEL_ROW_ID"
    static let CELL_THREE_LABEL_ROW_ID = "CELL_THREE_LABEL_ROW_ID"
    static let CELL_FOUR_LABEL_ROW_ID = "CELL_FOUR_LABEL_ROW_ID"
    static let CELL_FIVE_LABEL_ROW_ID = "CELL_FIVE_LABEL_ROW_ID"
    
    // scrollView 中label行数
    static let LABEL_TWO_ROW = 2
    static let LABEL_THREE_ROW = 3
    static let LABEL_FOUR_ROW = 4
    static let LABEL_FIVE_ROW = 5
    
    static let CELL_HEIGHT: CGFloat = 32.0
    static let LABEL_COLUMN: Int = 8
    
    private var labelCount: Int = 0
    
    static var labelWidth = ((SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH : SCREEN_HEIGHT) - 30 * 2) /
        CGFloat(TableSingalViewCell.LABEL_COLUMN)
    private let DATA_STR_PLACEHOLDER = "-"      // 字符串数据为nil或空串时，显示该占位符
    private let DATA_NUM_PLACEHOLDER = 0        // 数字数据为nil时，显示该占位符
    
    fileprivate var scrollView = UIScrollView.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
        guard let resueIdentifierTemp = reuseIdentifier else {
            CLLog("reuseIdentifier is nil.")
            return
        }
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(scrollView)
        scrollView.bounces = false
        
        // 适配
        scrollView.mas_makeConstraints { [weak self] (make) in
            guard let self = self else { return }
            make?.right.mas_equalTo()(self.contentView)
            make?.left.mas_equalTo()(self.contentView)
            make?.bottom.equalTo()(self.contentView)
            make?.height.mas_equalTo()(self.contentView)
        }
        
        // 计算labelCount
        switch resueIdentifierTemp {
        case TableSingalViewCell.CELL_TWO_LABEL_ROW_ID:
            self.labelCount = TableSingalViewCell.LABEL_TWO_ROW * TableSingalViewCell.LABEL_COLUMN
        case TableSingalViewCell.CELL_THREE_LABEL_ROW_ID:
            self.labelCount = TableSingalViewCell.LABEL_THREE_ROW * TableSingalViewCell.LABEL_COLUMN
        case TableSingalViewCell.CELL_FOUR_LABEL_ROW_ID:
            self.labelCount = TableSingalViewCell.LABEL_FOUR_ROW * TableSingalViewCell.LABEL_COLUMN
        case TableSingalViewCell.CELL_FIVE_LABEL_ROW_ID:
            self.labelCount = TableSingalViewCell.LABEL_FIVE_ROW * TableSingalViewCell.LABEL_COLUMN
        default:
            CLLog("resueIdentifier is undefined.")
        }
        
        for i in 0..<self.labelCount {
            let label = UILabel.init(frame: CGRect.init(x: TableSingalViewCell.labelWidth * CGFloat(i % TableSingalViewCell.LABEL_COLUMN), y: CGFloat(i / TableSingalViewCell.LABEL_COLUMN) * TableSingalViewCell.CELL_HEIGHT, width: TableSingalViewCell.labelWidth, height: TableSingalViewCell.CELL_HEIGHT))
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = font12
            label.numberOfLines = 2
            
            label.tag = i
            self.scrollView.addSubview(label)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.safeAreaInsets.top != 0.0 {
            
            return
        }
    }
    
    func setCellData(indexPath: IndexPath , dataSource: [[Any]]) {
        
        guard let labelsArray = self.scrollView.subviews.filter({ $0 is UILabel}) as? [UILabel] else {
            CLLog("labelsArray UI data type error.")
            return
        }
        guard indexPath.section < dataSource.count else {
            CLLog("dataSource data error.")
            return
        }
        guard dataSource[indexPath.section].count > 0 else {
            return
        }
        
        /************* 音频数据 **************/
        if indexPath.section == 0 {
            let voiceInfo = dataSource[indexPath.section][0] as? VoiceStream
            
            let voiceTitleArray = ["", tr("协议类型"), tr("码率(kbps)"), tr("丟包率(%)"), tr("延时(ms)"), tr("抖动(ms)"), "", ""]
            let voiceSendArray = [tr("本地发送"),
                                  "\(setPlaceHoder(sourceStr: voiceInfo?.encodeProtocol))",
                                  "\(voiceInfo?.sendBitRate ?? UInt32(DATA_NUM_PLACEHOLDER))",
                                  "\(voiceInfo?.sendLossFraction ?? Float(DATA_NUM_PLACEHOLDER))",
                                  "\(voiceInfo?.sendDelay ?? Float(DATA_NUM_PLACEHOLDER))",
                                  "\(voiceInfo?.sendJitter ?? Float(DATA_NUM_PLACEHOLDER))",
                                  "",
                                  ""
            ]
            let voiceRecvArray = [tr("本地接收"),
                                  "\(setPlaceHoder(sourceStr: voiceInfo?.decodeProtocol))",
                                  "\(voiceInfo?.recvBitRate ?? UInt32(DATA_NUM_PLACEHOLDER))",
                                  "\(voiceInfo?.recvLossFraction ?? Float(DATA_NUM_PLACEHOLDER))",
                                  "\(voiceInfo?.recvDelay ?? Float(DATA_NUM_PLACEHOLDER))",
                                  "\(voiceInfo?.recvJitter ?? Float(DATA_NUM_PLACEHOLDER))",
                                  "",
                                  ""
            ]
     
            for i in 0..<self.labelCount {
                let rowIndex = i / TableSingalViewCell.LABEL_COLUMN
                let columnIndex = i % TableSingalViewCell.LABEL_COLUMN
                switch rowIndex {
                case TableSingalViewCell.LABEL_TWO_ROW - 2: // first row
                    labelsArray[i].text = voiceTitleArray[columnIndex]
                case TableSingalViewCell.LABEL_TWO_ROW - 1: // second row
                    labelsArray[i].text = voiceSendArray[columnIndex]
                case TableSingalViewCell.LABEL_THREE_ROW - 1: // third row
                    labelsArray[i].text = voiceRecvArray[columnIndex]
                default:break
                }
            }
            scrollView.contentSize = CGSize.init(width: CGFloat(TableSingalViewCell.LABEL_COLUMN - 2) * TableSingalViewCell.labelWidth, height: STATUS_BAR_HEIGHT)
        }
        
        /************* 视频数据 **************/
        if indexPath.section == 1 {
            guard let videoInfoArray = dataSource[indexPath.section] as? [VideoStream] else {
                return
            }
            let videoTitleArray = ["", tr("协议类型"), tr("码率(kbps)"), tr("分辨率"), tr("帧率(fps)"), tr("丟包率(%)"), tr("延时(ms)"), tr("抖动(ms)")]
            
            var videoSendArray: [[String]] = []
            var videoRecvArray: [[String]] = []
            for videoRecInfo in videoInfoArray {
                // 发送视频信号质量数据
                videoSendArray.append([tr("本地发送"),
                                       "\(setPlaceHoder(sourceStr: videoRecInfo.encodeName))",
                                       "\(videoRecInfo.sendBitRate)",
                                       "\(setPlaceHoder(sourceStr: videoRecInfo.encoderSize))",
                                       "\(videoRecInfo.sendFrameRate)",
                                       "\(videoRecInfo.sendLossFraction)",
                                       "\(videoRecInfo.sendDelay)",
                                       "\(videoRecInfo.sendJitter)"
                 ])
                // 接收视频信号质量数据
                videoRecvArray.append([videoRecInfo.decodeAttConfName == "" ? tr("本地接收") : "\(setPlaceHoder(sourceStr: videoRecInfo.decodeAttConfName))",
                                       "\(setPlaceHoder(sourceStr: videoRecInfo.decodeName))",
                                       "\(videoRecInfo.recvBitRate)",
                                       "\(setPlaceHoder(sourceStr: videoRecInfo.decoderSize))",
                                       "\(videoRecInfo.recvFrameRate)",
                                       "\(videoRecInfo.recvLossFraction)",
                                       "\(videoRecInfo.recvDelay)",
                                       "\(videoRecInfo.recvJitter)"
                ])
            }
     
            for i in 0..<self.labelCount {
                let rowIndex = i / TableSingalViewCell.LABEL_COLUMN
                let columnIndex = i % TableSingalViewCell.LABEL_COLUMN
                switch rowIndex {
                case TableSingalViewCell.LABEL_TWO_ROW - 2: // first row
                    labelsArray[i].text = videoTitleArray[columnIndex]
                case TableSingalViewCell.LABEL_TWO_ROW - 1: // second row
                    labelsArray[i].text = videoSendArray[0][columnIndex]
                case TableSingalViewCell.LABEL_THREE_ROW - 1: // third row
                    labelsArray[i].text = videoRecvArray[0][columnIndex]
                case TableSingalViewCell.LABEL_FOUR_ROW - 1: // fourth row
                    if videoRecvArray.count > 1 {
                        labelsArray[i].text = (SessionManager.shared.bfcpStatus != .noBFCP && SessionManager.shared.currentShowVideoType == .showBFCP) ? "" : videoRecvArray[1][columnIndex]
                    }
                case TableSingalViewCell.LABEL_FIVE_ROW - 1: // fifth row
                    if videoRecvArray.count > 2 {
                        labelsArray[i].text = (SessionManager.shared.bfcpStatus != .noBFCP && SessionManager.shared.currentShowVideoType == .showBFCP) ? "" : videoRecvArray[2][columnIndex]
                    }
                    
                default:break
                }
            }
            scrollView.contentSize = CGSize.init(width: CGFloat(TableSingalViewCell.LABEL_COLUMN) * TableSingalViewCell.labelWidth, height: STATUS_BAR_HEIGHT)
        }
        
        /************* 辅流数据 **************/
        if indexPath.section == 2 {
            let bfcpInfo = dataSource[indexPath.section][0] as? BfcpVideoStream
            let bfcpTitleArray = ["", tr("协议类型"), tr("码率(kbps)"), tr("分辨率"), tr("帧率(fps)"), tr("丟包率(%)"), tr("延时(ms)"), tr("抖动(ms)")]
            let bfcpSendArray = [tr("本地发送"),
                                 "\(setPlaceHoder(sourceStr: bfcpInfo?.encodeName))",
                                 "\(bfcpInfo?.sendBitRate ?? UInt32(DATA_NUM_PLACEHOLDER))",
                                 "\(setPlaceHoder(sourceStr: bfcpInfo?.encoderSize))",
                                 "\(bfcpInfo?.sendFrameRate ?? UInt32(DATA_NUM_PLACEHOLDER))",
                                 "\(bfcpInfo?.sendLossFraction ?? Float(DATA_NUM_PLACEHOLDER))",
                                 "\(bfcpInfo?.sendDelay ?? Float(DATA_NUM_PLACEHOLDER))",
                                 "\(bfcpInfo?.sendJitter ?? Float(DATA_NUM_PLACEHOLDER))"
            ]
            let bfcpRecvArray = [tr("本地接收"),
                                 "\(setPlaceHoder(sourceStr: bfcpInfo?.decodeName))",
                                 "\(bfcpInfo?.recvBitRate ?? UInt32(DATA_NUM_PLACEHOLDER))",
                                 "\(setPlaceHoder(sourceStr: bfcpInfo?.decoderSize))",
                                 "\(bfcpInfo?.recvFrameRate ?? UInt32(DATA_NUM_PLACEHOLDER))",
                                 "\(bfcpInfo?.recvLossFraction ?? Float(DATA_NUM_PLACEHOLDER))",
                                 "\(bfcpInfo?.recvDelay ?? Float(DATA_NUM_PLACEHOLDER))",
                                 "\(bfcpInfo?.recvJitter ?? Float(DATA_NUM_PLACEHOLDER))"
            ]
     
            for i in 0..<self.labelCount {
                let rowIndex = i / TableSingalViewCell.LABEL_COLUMN
                let columnIndex = i % TableSingalViewCell.LABEL_COLUMN
                switch rowIndex {
                case TableSingalViewCell.LABEL_TWO_ROW - 2: // first row
                    labelsArray[i].text = bfcpTitleArray[columnIndex]
                case TableSingalViewCell.LABEL_TWO_ROW - 1: // second row
                    labelsArray[i].text = SessionManager.shared.bfcpStatus == .localSendBFCP ?
                        bfcpSendArray[columnIndex] : (columnIndex == 0 ? bfcpSendArray[0] : DATA_STR_PLACEHOLDER)
                case TableSingalViewCell.LABEL_THREE_ROW - 1: // third row
                    labelsArray[i].text = SessionManager.shared.bfcpStatus == .remoteRecvBFCP ?
                        bfcpRecvArray[columnIndex] : (columnIndex == 0 ? bfcpRecvArray[0] : DATA_STR_PLACEHOLDER)
                default:break
                }
            }
            scrollView.contentSize = CGSize.init(width: CGFloat(TableSingalViewCell.LABEL_COLUMN) * TableSingalViewCell.labelWidth, height: STATUS_BAR_HEIGHT)
        }
    }
    
    // 设置字符串占位符
    func setPlaceHoder(sourceStr: String?) -> String {
        if sourceStr == nil || sourceStr == "" {
            return DATA_STR_PLACEHOLDER
        }
        return sourceStr!
    }
    
    deinit {
        CLLog("TableSingalSevenViewCell deinit")
    }
}
