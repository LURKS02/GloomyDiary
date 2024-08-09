//
//  then.swift
//  GloomyDiary
//
//  Created by 디해 on 8/7/24.
//

import UIKit

protocol Then { }

extension Then where Self: NSObject {
    func then(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then { }
