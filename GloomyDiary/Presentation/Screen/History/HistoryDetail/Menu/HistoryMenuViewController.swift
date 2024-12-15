//
//  HistoryMenuViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 12/15/24.
//

import UIKit
import RxRelay

final class HistoryMenuViewController: BaseViewController<HistoryDetailMenuView> {
    
    let buttonTappedRelay = PublishRelay<String>()
    
    
    // MARK: - Initialize
    
    init(navigationControllerHeight: CGFloat) {
        let contentView = HistoryDetailMenuView(navigationControllerHeight: navigationControllerHeight)
        super.init(contentView, logID: "HistoryDetailMenuView")
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.configure(with: [.share, .delete])
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await contentView.playFadeInAnimation()
        }
    }
}


// MARK: - bind

private extension HistoryMenuViewController {
    func bind() {
        for button in contentView.menuButtons {
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.buttonTappedRelay.accept(button.identifier)
                })
                .disposed(by: rx.disposeBag)
        }
        
        contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                Task {
                    await self?.close()
                }
            })
            .disposed(by: rx.disposeBag)
    }
}

extension HistoryMenuViewController {
    @MainActor
    func close() async {
        await contentView.playFadeOutAnimation()
        self.dismiss(animated: false)
    }
}
