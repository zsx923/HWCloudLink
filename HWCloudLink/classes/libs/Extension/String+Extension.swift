//
//  String+Extension.swift
//  HWCloudLink
//
//  Created by mac on 2020/8/13.
//  Copyright © 2020 陈帆. All rights reserved.
//


extension String {
    
    /// 判断是否都是数字
    var isNumber: Bool {
        return isMatch("^[0-9]*$")
    }
    
    func isMatch(_ rules: String ) -> Bool {
        let rules = NSPredicate(format: "SELF MATCHES %@", rules)
        let isMatch: Bool = rules.evaluate(with: self)
        return isMatch
    }
    
    static func string2Date(_ string: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: string)
        return date ?? Date()
    }
    
    func addBlank(per characters: Int = 3) -> String {
        
        if self == "" {
            return ""
        }
        
        let a = Int(self.count / characters)
        let b = Int(self.count % characters)
        let c = b > 0 ? a + 1 : a
        
        var string = ""
        
        for i in 0 ..< c {
            
            var str = ""
            
            if i == c - 1 {
                b > 0 ? (str = (self as NSString).substring(with: NSRange(location: characters*(c-1), length: b))) : (str = (self as NSString).substring(with: NSRange(location: characters * i, length: characters)))
                if b > 0 {
                    
                }
            }else {
                
                str = (self as NSString).substring(with: NSRange(location: characters * i, length: characters))
            }
            
            string = "\(string) \(str)"
        }
        return string
    }
    
    func dealMeetingIdWithIDString() -> String {
        if self.count < 5 {
            return self
        }
        var newStr = self
        for i in 1..<((newStr.count / 3)) {
            newStr.insert(" ", at: self.index(self.startIndex, offsetBy: i*4-1))
        }
        if self.count % 3 != 1 && self.count % 3 != 0 {
            newStr.insert(" ", at: self.index(newStr.endIndex, offsetBy: -(self.count % 3)))
        }
        return newStr
    }
}
