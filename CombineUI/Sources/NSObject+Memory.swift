//
//  NSObject+Memory.swift
//  Fantastique
//
//  Created by pranjal on 2/29/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import Foundation

extension NSObject {
    func retain(_ value: AnyObject) {
        var id = UUID()
        objc_setAssociatedObject(self, &id, value, .OBJC_ASSOCIATION_RETAIN)
    }
}
