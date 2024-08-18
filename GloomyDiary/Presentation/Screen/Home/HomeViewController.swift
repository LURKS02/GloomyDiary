//
//  HomeViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import ComposableArchitecture
import RxSwift
import RxRelay
import RxCocoa
import RxGesture

final class HomeViewController: BaseViewController<HomeView> {
    private var loopAnimated: Bool = false
    
    let store: StoreOf<Home>
    
    init(store: StoreOf<Home>) {
        self.store = store
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !loopAnimated {
            defer { loopAnimated = true }
            AnimationManager.shared.moveUpAndDown(contentView.ghostImageView, value: 5)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.store.send(.ghostTapped)
            })
            .disposed(by: disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            
            self.contentView.talkingView.update(text: store.talkingType.description)
        }
    }
}
