//
//  Extension+Reactive.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit
import RxSwift

private var disposeBagKey: UInt8 = 0

extension Reactive where Base: AnyObject {
    var disposeBag: DisposeBag {
        get {
            if let disposeBag = objc_getAssociatedObject(base, &disposeBagKey) as? DisposeBag {
                return disposeBag
            }
            let disposeBag = DisposeBag()
            objc_setAssociatedObject(base, &disposeBagKey, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return disposeBag
        }
        set {
            objc_setAssociatedObject(base, &disposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
