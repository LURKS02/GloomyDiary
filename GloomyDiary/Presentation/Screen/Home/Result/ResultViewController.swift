//
//  ResultViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import UIKit
import ComposableArchitecture

final class ResultViewController: BaseViewController<ResultView> {
    let store: StoreOf<CounselResult>
    
    init(store: StoreOf<CounselResult>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ResultViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        bind()
        
    }
}

private extension ResultViewController {
    func bind() {
        observe { [weak self] in
            guard let self else { return }
            self.contentView.configure(with: store.character)
        }
    }
}
