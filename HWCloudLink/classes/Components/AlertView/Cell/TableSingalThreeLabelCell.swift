//
//  TableSingalThreeLabelCell.swift
//  HWCloudLink
//
//  Created by Jabien on 2020/7/27.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableSingalThreeLabelCell: UITableViewCell {

    static let CELL_ID = "TableSingalThreeLabelCell"
    static let CELL_HEIGHT: CGFloat = 32.0
    
    @IBOutlet weak var FirstLabel: UILabel!
    @IBOutlet weak var SecondLabel: UILabel!
    @IBOutlet weak var ThirdView: UILabel!
    
    func setCellData(indexPath: IndexPath , dataSource: [Any]) {
        if dataSource[indexPath.section] is VoiceStream { // 音频
            if indexPath.row == 0 { // 标题
                FirstLabel.text = ""
                SecondLabel.text = tr("本地发送")
                ThirdView.text = tr("本地接收")
            }else {
                let voiceInfo:VoiceStream = dataSource[indexPath.section] as! VoiceStream
                if indexPath.row == 1 {
                    FirstLabel.text = tr("协议类型")
                    SecondLabel.text = voiceInfo.encodeProtocol
                    ThirdView.text = voiceInfo.decodeProtocol
                }else if indexPath.row == 2 {
                    FirstLabel.text = tr("码率(kbps)")
                    SecondLabel.text = "\(voiceInfo.sendBitRate)"
                    ThirdView.text = "\(voiceInfo.recvBitRate)"
                }else if indexPath.row == 3 {
                    FirstLabel.text = tr("丟包率(%)")
                    SecondLabel.text = "\(voiceInfo.sendLossFraction)"
                    ThirdView.text = "\(voiceInfo.recvLossFraction)"
                }else if indexPath.row == 4 {
                    FirstLabel.text = tr("延时(ms)")
                    SecondLabel.text = "\(voiceInfo.sendDelay)"
                    ThirdView.text = "\(voiceInfo.recvDelay)"
                }else if indexPath.row == 5 {
                    FirstLabel.text = tr("抖动(ms)")
                    SecondLabel.text = "\(voiceInfo.sendJitter)"
                    ThirdView.text = "\(voiceInfo.recvJitter)"
                }
            }
        }
        if dataSource[indexPath.section] is VideoStream { // 视频
            let videoInfo:VideoStream = dataSource[indexPath.section] as! VideoStream
            if indexPath.row == 0 { // 标题
                FirstLabel.text = ""
                SecondLabel.text = tr("本地发送")
                ThirdView.text = videoInfo.decodeAttConfName == "" ? tr("本地发送") : "\(videoInfo.decodeAttConfName)"
            }else {
                if indexPath.row == 1 {
                    FirstLabel.text = tr("协议类型")
                    SecondLabel.text = "\(videoInfo.encodeName)"
                    ThirdView.text = "\(videoInfo.decodeName)"
                }else if indexPath.row == 2 {
                    FirstLabel.text = tr("码率(kbps)")
                    SecondLabel.text = "\(videoInfo.sendBitRate)"
                    ThirdView.text = "\(videoInfo.recvBitRate)"
                }else if indexPath.row == 3 {
                    FirstLabel.text = tr("分辨率")
                    SecondLabel.text = "\(videoInfo.encoderSize)"
                    ThirdView.text = "\(videoInfo.decoderSize)"
                }else if indexPath.row == 4 {
                    FirstLabel.text = tr("帧率(fps)")
                    SecondLabel.text = "\(videoInfo.sendFrameRate)"
                    ThirdView.text = "\(videoInfo.recvFrameRate)"
                }else if indexPath.row == 5 {
                    FirstLabel.text = tr("丟包率(%)")
                    SecondLabel.text = "\(videoInfo.sendLossFraction)"
                    ThirdView.text = "\(videoInfo.recvLossFraction)"
                }else if indexPath.row == 6 {
                    FirstLabel.text = tr("延时(ms)")
                    SecondLabel.text = "\(videoInfo.sendDelay)"
                    ThirdView.text = "\(videoInfo.recvDelay)"
                }else if indexPath.row == 7 {
                    FirstLabel.text = tr("抖动(ms)")
                    SecondLabel.text = "\(videoInfo.sendJitter)"
                    ThirdView.text = "\(videoInfo.recvJitter)"
                }
            }
        }
        if dataSource[indexPath.section] is BfcpVideoStream { // 辅流
            if indexPath.row == 0 { // 标题
                FirstLabel.text = ""
                SecondLabel.text = tr("本地发送")
                ThirdView.text = tr("本地接收")
            }else {
                let bfcpInfo:BfcpVideoStream = dataSource[indexPath.section] as! BfcpVideoStream
                if indexPath.row == 1 {
                    FirstLabel.text = tr("协议类型")
                    SecondLabel.text = "\(bfcpInfo.encodeName)"
                    ThirdView.text = "\(bfcpInfo.decodeName)"
                }else if indexPath.row == 2 {
                    FirstLabel.text = tr("码率(kbps)")
                    SecondLabel.text = "\(bfcpInfo.sendBitRate)"
                    ThirdView.text = "\(bfcpInfo.recvBitRate)"
                }else if indexPath.row == 3 {
                    FirstLabel.text = tr("分辨率")
                    SecondLabel.text = "\(bfcpInfo.encoderSize)"
                    ThirdView.text = "\(bfcpInfo.decoderSize)"
                }else if indexPath.row == 4 {
                    FirstLabel.text = tr("帧率(fps)")
                    SecondLabel.text = "\(bfcpInfo.sendFrameRate)"
                    ThirdView.text = "\(bfcpInfo.recvFrameRate)"
                }else if indexPath.row == 5 {
                    FirstLabel.text = tr("丟包率(%)")
                    SecondLabel.text = "\(bfcpInfo.sendLossFraction)"
                    ThirdView.text = "\(bfcpInfo.recvLossFraction)"
                }else if indexPath.row == 6 {
                    FirstLabel.text = tr("延时(ms)")
                    SecondLabel.text = "\(bfcpInfo.sendDelay)"
                    ThirdView.text = "\(bfcpInfo.recvDelay)"
                }else if indexPath.row == 7 {
                    FirstLabel.text = tr("抖动(ms)")
                    SecondLabel.text = "\(bfcpInfo.sendJitter)"
                    ThirdView.text = "\(bfcpInfo.recvJitter)"
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        CLLog("TableSingalThreeLabelCell deinit")
    }
    
}
