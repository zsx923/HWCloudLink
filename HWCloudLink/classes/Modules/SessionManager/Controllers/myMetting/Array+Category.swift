//
//  Array+Category.swift
//  HWCloudLink
//
//  Created by 严腾飞 on 2021/1/12.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

extension Array {
    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}
