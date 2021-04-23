//
//  LocalContactModel.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/23.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class LocalContactModel: BaseModel {
    
    let sqlTabelName = "cl_local_contact"
    
    var searchWord : String?
    
    var localContactId : Int?
    
    var name : String?
    
    var firstCharactor : String?
    
    var number : String?
    
    var mobile : String?
    
    var fax : String?
    
    var campany : String?
    
    var depart : String?
    
    var post : String?
    
    var eMail : String?
    
    var address : String?
    
    var remark : String?
    
    var type : Int?
    
    var createTime : String?
    
    var page = 0
    
    var limit = 10
    
    var isSelected = false  // 当前是否选中
    
    var isSelf = false // 是否不可被点击
    
    func getFirstCharactor(name:String) -> String {
        //获取首字母
        let firstCharactor = changeFirstCharactor(name: name)
        print("firstCharactor:::\(firstCharactor)")
        
        if self.judgeNumber(str: firstCharactor){
            return firstCharactor
        }else  {
            if (firstCharactor < "A" || firstCharactor > "Z") && (firstCharactor < "a" || firstCharactor > "z")  {
                return "#"
            }else {
                return firstCharactor
            }
        }
        
        
        
//        if (firstCharactor < "A" || firstCharactor > "Z") && (firstCharactor < "a" || firstCharactor > "z") {
        /*
        if (firstCharactor > "A" || firstCharactor < "Z") && (firstCharactor > "a" || firstCharactor < "z") {
           return firstCharactor
        } else if (0 <= Int(firstCharactor)! || Int(firstCharactor)! <= 9 ){
            return firstCharactor
        }else {
            return "#"
        }
        */
//        return firstCharactor
    }
    
    func judgeNumber(str: String) -> Bool{
        let reg = "^[0-9]+$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        if pre.evaluate(with: str) {
            return true
        }else{
            return false
        }
        
       
        
    }
    
    func changeFirstCharactor(name:String) -> String {
        let str = CFStringCreateMutableCopy(nil,0,name as CFString)
        CFStringTransform(str, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)
        return (str as! NSString).substring(to: 1).uppercased()
    }

    
}
