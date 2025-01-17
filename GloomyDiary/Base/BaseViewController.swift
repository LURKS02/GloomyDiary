//
//  BaseViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import RxSwift

class BaseViewController<T: BaseView>: UIViewController {
    var contentView: T
    
    init(_ contentView: T = T(), logID: String) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
