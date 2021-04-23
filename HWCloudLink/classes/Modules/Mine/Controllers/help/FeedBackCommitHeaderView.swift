//
//  FeedBackCommitCustomView.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/11/20.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

private let imageWH: CGFloat = 47

class FeedBackCommitHeaderView: BaseCustomView ,UITextViewDelegate {
    @IBOutlet weak var feedbackTitleLabel: UILabel!
    @IBOutlet weak var contentNumLabel: UILabel!
//    @IBOutlet weak var topTextView: UITextView!
//    @IBOutlet weak var textViewHightConstant: NSLayoutConstraint!
    @IBOutlet weak var topViewHightConstant: NSLayoutConstraint!
    @IBOutlet weak var imageTipsLabel: UILabel!
    @IBOutlet weak var imageCountNumLable: UILabel!
    @IBOutlet weak var addImageView: UIView!
    @IBOutlet weak var logTipsLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    
    var tempImageViewArray:[UIImage] = []
    
    var topTextView: UITextView = {
       let view = UITextView()
        
        return view
    }()
    var placeHolderLabel: UILabel = {//textView占位符
       let label = UILabel()
        return label
    }()
    //添加图片的回调
    var passAddImageViewBlock: (()->Void)?
    // 是否显示本地日志记录，yes 显示 no 不显示
    var passIsDisplayLocalLogsBlock :((_ isYES: Bool)->Void)?
    //点击图片，预览大图 ，回调方法
    var passDisplayImageBlock: ((_ index: Int)->Void)?
    //输入文字高度变更回调
    var passUpDateTextViewHightBlock :((_ hight : Int,_ isAdd: Bool)->Void)?
    var passContentValueBlokc : ((_ content: String) -> Void)?
    var tempHight : CGFloat = 31.0

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        //创建顶部的textview 输入框
        topTextView.frame = CGRect(x: 16, y: 35 , width: SCREEN_WIDTH - 80, height: 31)
        topTextView.delegate = self
        topTextView.font = UIFont.systemFont(ofSize: 13)
        topTextView.returnKeyType = .done
        //内容缩进，去除左右边距
        topTextView.textContainer.lineFragmentPadding = 0
        //文本边距，去除上下边距
        topTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) // .zero
        topTextView.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#f0f0f0")
        topTextView.layer.cornerRadius = 4
        topTextView.layer.masksToBounds = true
        topView.addSubview(topTextView)
        //创建textview 上UILabel 的站位控件
        placeHolderLabel = UILabel.init()
        placeHolderLabel.frame = CGRect(x: 16, y: 42, width: 350, height: 15)
        placeHolderLabel.textAlignment = NSTextAlignment.left
        placeHolderLabel.text = tr("若有任何不满意的地方，请在这里吐槽吧")
        placeHolderLabel.font = font13
        placeHolderLabel.textColor = UIColor.colorWithSystem(lightColor: "#cccccc", darkColor: "#666666")
        topView.addSubview(placeHolderLabel)
        
        self.feedbackTitleLabel.text = tr("反馈")
        self.imageTipsLabel.text = tr("图片（选填，请提供问题截图）")
        self.logTipsLabel.text = tr("同步上传日志")
        
        self.addDefaultImageView()
        
        
    }
    public func getContentStr()->String{
       return   topTextView.text
    }
    static func creatFeedBackCommitHeaderView() -> FeedBackCommitHeaderView{
        return loadNibView(nibName: "FeedBackCommitHeaderView") as! FeedBackCommitHeaderView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    //MARK: 是否显示日志
    @IBAction func isDisplayLogs(_ sender: UISwitch) {
        var status = sender.isOn
        if false == sender.isOn {
            status = false
        }else{
            status = true
        }
        if passIsDisplayLocalLogsBlock != nil {
            passIsDisplayLocalLogsBlock!(status)
        }
    }
    
}

extension FeedBackCommitHeaderView{
    //MARK: 添加图片的方法(供外部调用)
    public func addNewImageView(imageArray:[UIImage]){
        tempImageViewArray.removeAll()
        tempImageViewArray += imageArray
        self.displaySelectedImage()
    }
}
//MARK: 添加图片的方法
extension FeedBackCommitHeaderView {
    //MARK: 添加默认图
    private func addDefaultImageView(){
        let margin: CGFloat = 16
        
        let imageView = UIImageView.init(frame: CGRect(x: CGFloat(tempImageViewArray.count) * ( imageWH + margin) , y: 0, width: imageWH, height: imageWH))
        imageView.image = UIImage.init(named: "feedbackAddImage")
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.colorWithSystem(lightColor: "E9E9E9", darkColor: "666666")
        addImageView.addSubview(imageView)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTapDefaultImageView))
        imageView.addGestureRecognizer(tap)
    }
    //MARK: 默认图片的点击方法
    @objc func handleTapDefaultImageView(){
        if passAddImageViewBlock != nil{
            passAddImageViewBlock!()
        }
    }
    //MARK: 添加已经选择的图片（内部调用）
    private func displaySelectedImage(){
        addImageView.subviews.forEach({$0.removeFromSuperview()})
        let margin: CGFloat = 16
        for (i, image) in tempImageViewArray.enumerated() {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i) * (margin + imageWH), y: 0, width: imageWH, height: imageWH))
            imageView.isUserInteractionEnabled = true
            imageView.image = image
            addImageView.addSubview(imageView)
 
            imageView.tag = 20000 + i
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTapSelectedImage(tap:)))
            imageView.addGestureRecognizer(tap)
             
        }
 
        self.imageCountNumLable.text = "\(tempImageViewArray.count)/3"
        
        if tempImageViewArray.count < 3 {
            self.addDefaultImageView()
        }
    }
    //MARK: 选中的图片的点击方法
    @objc private func handleTapSelectedImage(tap:UITapGestureRecognizer){
        let index = tap.view!.tag - 20000
        if passDisplayImageBlock != nil {
            passDisplayImageBlock!(index)
        }
        
    }
}
//MARK: 删除图片方法
extension FeedBackCommitHeaderView{
    func deleteImageViewWithIndex(index: Int){
        tempImageViewArray.remove(at: index)
        self.displaySelectedImage()
    }
}
//MARK: 代理方法的扩展
extension FeedBackCommitHeaderView{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            placeHolderLabel.text = ""
        }else{
            placeHolderLabel.text = tr("若有任何不满意的地方，请在这里吐槽吧")
        }
        if textView.text.count > 200 {
            textView.text = textView.text.subString(from: 0, to: 199)
        }
        contentNumLabel.text = "\(String(textView.text.count))" +  "/200"
        
        if passContentValueBlokc != nil {
            passContentValueBlokc!(textView.text)
        }
    }
     
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.endEditing(false)
            textView.resignFirstResponder()
             return false
        }
        
        let  frame = textView.frame;
        let str = NSString(string: topTextView.text!)
        let resultStr = str.replacingCharacters(in: range, with: text)
        let  hight =  NSString.getStrHight(resultStr as String, maxWidth: SCREEN_WIDTH - 80, fontSize: 13)
        var  height = CGFloat(hight + 15)
        if height <= 31 {
            height = 31
        } else {
        }
        
        if tempHight != CGFloat(hight) {
            topViewHightConstant.constant = 49 + height

            textView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height);
            if passUpDateTextViewHightBlock != nil {
                if tempHight > height {
                    passUpDateTextViewHightBlock!( Int(height - 0),false)
                } else{
                    passUpDateTextViewHightBlock!( Int(height - 0),true)
                }
                tempHight = CGFloat(hight)
                
            }
        }
        
        return true
        
        /*
        if  height > CGFloat(tempHight) {
            if passUpDateTextViewHightBlock != nil {
                passUpDateTextViewHightBlock!(  Int(height) - 16 ,true)
            }
            tempHight  = height ;
            topViewHightConstant.constant += CGFloat(16)
 
            textView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height);
            return true
        }else{
            if height < CGFloat(tempHight) {
                tempHight =  CGFloat(height) ;
                 if passUpDateTextViewHightBlock != nil {
                     passUpDateTextViewHightBlock!(  Int(height) - 16 ,false)
                 }
                topViewHightConstant.constant -= CGFloat(16)
 
                textView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height);
                return true
            }
        }
        */
//        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if passContentValueBlokc != nil {
            passContentValueBlokc!(textView.text)
        }
    }
}
