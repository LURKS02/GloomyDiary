//
//  Extension+Reactive.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import Combine
import ObjectiveC

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

class CancellableHolder: NSObject {
    var cb = Set<AnyCancellable>()
}

private var cancellablesKey: UInt8 = 0

extension NSObject {
    var cancellables: Set<AnyCancellable> {
        get {
            if let holder = objc_getAssociatedObject(self, &cancellablesKey) as? CancellableHolder {
                return holder.cb
            }
            let holder = CancellableHolder()
            objc_setAssociatedObject(self, &cancellablesKey, holder, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return holder.cb
        }
        set {
            if let holder = objc_getAssociatedObject(self, &cancellablesKey) as? CancellableHolder {
                holder.cancellables = newValue
            } else {
                let holder = CancellableHolder()
                holder.cb = newValue
                objc_setAssociatedObject(self, &cancellablesKey, holder, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
