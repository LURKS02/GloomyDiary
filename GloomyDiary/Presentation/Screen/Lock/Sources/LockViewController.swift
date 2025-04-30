//
//  LockViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/30/25.
//

import ComposableArchitecture
import UIKit

final class LockViewController: BaseViewController<LockView> {
    
    let store: StoreOf<PasswordLock>
    
    private let backgroundTap = UITapGestureRecognizer()
    
    init(store: StoreOf<PasswordLock>) {
        self.store = store
        let contentView = LockView(totalPins: 4)
        
        super.init(contentView)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        store.send(.view(.viewDidLoad))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentView.makeTextFieldFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        store.send(.view(.viewDidAppear))
    }
    
    private func bind() {
        contentView.addGestureRecognizer(backgroundTap)
        
        backgroundTap.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                contentView.makeTextFieldFirstResponder()
            }
            .store(in: &cancellables)
        
        contentView.hiddenTextField.textPublisher
            .sink { [weak self] input in
                guard let input,
                      let self,
                      input.count <= store.totalPins else { return }
                
                store.send(.view(.didEnterPassword(input)))
            }
            .store(in: &cancellables)
        
        contentView.hintButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                contentView.showHint(store.hint)
            }
            .store(in: &cancellables)
        
        observe { [weak self] in
            guard let self else { return }
            
            guard !store.prepareForDismiss else { return self.dismiss(animated: true) }
            
            switch store.checkFlag {
            case .comfirming:
                contentView.highlightStarlights(number: store.password.count)
            case .mismatch:
                contentView.configureForMismatch()
            }
        }
    }
}
