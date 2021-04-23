//
//  DrapView.swift
//  HWCloudLink
//
//  Created by mac on 2020/5/28.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol ViewTapedForDoubleAble {
    func viewTapedForDouble(to view: DrapView)
}

class DrapView: UIImageView {
    //双击代理
    var delegate : ViewTapedForDoubleAble?
    let self_w : CGFloat = 84
    let self_h : CGFloat = 146
    let space  : CGFloat = 20
    var isDrap : Bool    = false  //是否拖拽过
    let wh = (SCREEN_WIDTH / SCREEN_HEIGHT)
    let hw = (SCREEN_HEIGHT / SCREEN_WIDTH)
    var isNeedChangeWH: Bool = true
    
    //检测横竖屏
       var interfaceOrientationChange: UIInterfaceOrientation = .portrait
       {
           willSet{
            if newValue == .portrait || newValue == .portraitUpsideDown {
                // 计算x,y
                   if !isDrap {

                       x = SCREEN_WIDTH - self_w - space
                       y = SCREEN_HEIGHT - self_w - self_h

                   }else{

                       x = x * wh
                       y = y * hw
                   }

                   if y < 0 {
                       y = 0
                   }

                   if y > (SCREEN_HEIGHT - self_h) {
                       y = SCREEN_HEIGHT - self_h
                   }
                   if x < 0 {
                       x = 0
                   }

                   if x > SCREEN_WIDTH - self_w {
                       x = SCREEN_WIDTH - self_w
                   }



            }else {

                // 计算x,y
                if !isDrap { //没拖拽

                    x = SCREEN_HEIGHT - self_h - space
                    y = SCREEN_WIDTH - self_w - space

                    if interfaceOrientationChange == .landscapeLeft || interfaceOrientationChange == .landscapeRight  {
                        isNeedChangeWH = false

                    }

                }else{ //拖拽过

                    if interfaceOrientationChange == .landscapeLeft || interfaceOrientationChange == .landscapeRight  {
                        isNeedChangeWH = false

                    }else{

                        x = x * hw
                        y = y * wh
                    }
                }

                if y < 0 {
                    y = 0
                }

                if y > (SCREEN_WIDTH - self_w) {
                    y = SCREEN_WIDTH - self_w
                }
                if x < 0 {
                    x = 0
                }

                if x > SCREEN_HEIGHT - self_h {
                    x = SCREEN_HEIGHT - self_h
                }
            }

            isNeedChangeWH ?  (size = CGSize(width: height , height: width)) :  (size = CGSize(width: width , height: height))
            isNeedChangeWH = true
        }
       }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        frame = CGRect(x: SCREEN_WIDTH - self_w - space, y: SCREEN_HEIGHT - self_w - self_h, width: self_w, height: self_h)
        addGesture()
    }
}

///添加拖动手势
extension DrapView {
    
     private func addGesture() {
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragMoving(pan:))))
        //添加双击手势
        let tapGestureForDouble = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
        tapGestureForDouble.numberOfTapsRequired = 2
        tapGestureForDouble.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGestureForDouble)
    }
}

///事件
extension DrapView {
    @objc private func dragMoving(pan: UIPanGestureRecognizer){
    
        let point = pan.translation(in: superview)

        if pan.state == .began {

            isDrap = true

        }

        pan.view?.center = CGPoint(x: pan.view!.center.x + point.x, y: pan.view!.center.y + point.y)

        pan.setTranslation(.zero, in: superview)

        if pan.state == .ended {

            if let v = pan.view{

            // 计算 当前view 距离屏幕上下左右的距离

            let top = v.frame.minY ;

            let left = v.frame.minX ;

            let bottom = (interfaceOrientationChange == .portrait ? SCREEN_HEIGHT :SCREEN_WIDTH) - v.frame.maxY

            let right = (interfaceOrientationChange == .portrait ? SCREEN_WIDTH : SCREEN_HEIGHT) - v.frame.maxX

            // 计算出 view 距离屏幕边缘距离的最小值

            let temp = [top,left,bottom,right].sorted().first

            // 平移动画

            UIView.animate(withDuration: 0.3, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

                            if temp == top{

                                v.transform = v.transform.translatedBy(x: 0, y: -top)

                            }else if temp == left{

                                v.transform = v.transform.translatedBy(x: -left, y: 0)

                            }else if temp == bottom{
                                
                                v.transform = v.transform.translatedBy(x: 0, y: bottom)
                                   
                            }else{

                                v.transform = v.transform.translatedBy(x: right, y: 0)  
                            }
                
                            self.fixPositionError(v: v)

                        }, completion: { (finish) in

                        })

                    }

                }
    }
    
    
    /// 修复View的位置
    /// - Parameter v: <#v description#>
    private func fixPositionError(v : UIView) {
        
       
            if v.y > ((self.interfaceOrientationChange == .portrait) ? SCREEN_HEIGHT - self.self_h : SCREEN_WIDTH - self.self_w) {
                self.y = (self.interfaceOrientationChange == .portrait) ? SCREEN_HEIGHT - self.self_h : SCREEN_WIDTH - self.self_w
            }
            
            if v.y < 0 {
                self.y = 0
            }
            
            if v.x > ((self.interfaceOrientationChange == .portrait) ? (SCREEN_WIDTH + self.self_w) : (SCREEN_HEIGHT + self.self_h)) {
                self.x = (self.interfaceOrientationChange == .portrait) ? SCREEN_WIDTH - self.self_w : SCREEN_HEIGHT - self.self_h
            }
            
            if v.x < 0 {
                self.x = 0
            }
        
    }
    
    @objc private func tap(tap: UITapGestureRecognizer){
        delegate?.viewTapedForDouble(to: self)
    }
}
