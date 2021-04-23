//
//  PreviewImageViewController.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/11/21.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class PreviewImageViewController: BaseViewController ,UIScrollViewDelegate{

    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topBgView: UIView!
    
    var index : Int = 0  //需要展示的图片的下标
    var imageArray:[UIImage] = [] //展示的数组
    
    override func viewDidAppear(_ animated:Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.creatImageView()
        self.bottomScrollView.delegate = self
        bottomScrollView.isPagingEnabled = true
        self.view.backgroundColor = UIColor.black
        self.topBgView.backgroundColor = UIColor.black
    }
    
    //MARK: 创建图片
    private func creatImageView (){
        bottomScrollView.subviews.forEach({$0.removeFromSuperview()})
        
        for (i,item) in imageArray.enumerated() {
            let imageView = UIImageView.init()
            imageView.frame = CGRect(x: CGFloat(i) * SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - AppNaviHeight )
            imageView.image = item
            imageView.contentMode = .scaleAspectFit
            bottomScrollView.addSubview(imageView)
        }
        let size = CGSize(width: Int(SCREEN_WIDTH * CGFloat(imageArray.count)), height: 0)
        bottomScrollView.contentSize = size
        //设置scrolleview 的偏移量
        let point = CGPoint(x: Int(SCREEN_WIDTH * CGFloat(index)), y: 0)
        self.bottomScrollView.setContentOffset(point, animated: true)
        //设置表头
        self.titleLabel.text = "\(String(describing: index+1))/\(imageArray.count)"
    }
    //MARK: 删除图片
    @IBAction func deleteImageBtn(_ sender: Any) {
        let num = Int(bottomScrollView.contentOffset.x/SCREEN_WIDTH)
        //删除当前显示的图片
        for (index,_) in imageArray.enumerated(){
            if index == num {
                imageArray.remove(at: index)
            }
            
        }
        let  dict = ["index": num]
        NotificationCenter.default.post(name: NSNotification.Name(mine_set_deleteImageView), object: nil, userInfo: dict)
        
        if imageArray.count ==  0 { //此时没有图片了， 需要返回到上一个页面
            self.navigationController?.popViewController(animated: true)
        }else{
            if 0 == num { //删除的是第一个页面
                index = 0
            }else{ //删除的不是第一个页面
                index = imageArray.count - 1
            }
        }
        self.creatImageView()
    }
    
     
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         let num = Int(bottomScrollView.contentOffset.x/SCREEN_WIDTH)
         
        self.titleLabel.text = "\(num+1)/\(self.imageArray.count)"
    }
    
    
    @IBAction func returnBack(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
}
