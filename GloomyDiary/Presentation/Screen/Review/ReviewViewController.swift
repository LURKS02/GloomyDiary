//
//  ReviewViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/27/24.
//

import UIKit
import StoreKit
import ComposableArchitecture

final class ReviewViewController: BaseViewController<ReviewView> {
    
    let store: StoreOf<Review>
    
    init(store: StoreOf<Review>) {
        self.store = store
        let contentView = ReviewView(character: CounselingCharacter.getRandomElement())
        super.init(contentView, logID: "Review")
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { @MainActor in
            await contentView.runAppearanceAnimation()
        }
    }
}

private extension ReviewViewController {
    func bind() {
        contentView.blurView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    self.store.send(.didDeclineReview)
                    await self.contentView.runDismissAnimation()
                    self.dismiss(animated: false)
                    Logger.send(type: .tapped, "블러 뷰(리뷰 거절)")
                }
            })
            .disposed(by: rx.disposeBag)
        
        contentView.rejectButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                Task { @MainActor in
                    guard let self,
                          let title = self.contentView.rejectButton.title(for: .normal) else { return }
                    self.store.send(.didDeclineReview)
                    await self.contentView.runDismissAnimation()
                    self.dismiss(animated: false)
                    Logger.send(type: .tapped, title)
                }
            })
            .disposed(by: rx.disposeBag)
        
        contentView.acceptButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                Task {
                    guard let self,
                          let title = self.contentView.acceptButton.title(for: .normal),
                          let windowScene = self.view.window?.windowScene else { return }
                    self.store.send(.didAcceptReview)
                    AppStore.requestReview(in: windowScene)
                    await self.contentView.runDismissAnimation()
                    self.dismiss(animated: false)
                    Logger.send(type: .tapped, title)
                }
            })
            .disposed(by: rx.disposeBag)
    }
}
