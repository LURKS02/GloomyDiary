//
//  BaseViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit

class BaseViewController<T: UIView>: UIViewController {
    var contentView: T
    
    init(_ contentView: T = T()) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = contentView
    }
}
