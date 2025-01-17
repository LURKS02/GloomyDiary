//
//  DeleteViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 12/16/24.
//

import UIKit
import RxRelay
import ComposableArchitecture

final class DeleteViewController: BaseViewController<DeleteView> {
    
    @Dependency(\.counselingSessionRepository) var counselingSessionRepository
    @Dependency(\.logger) var logger
    
    var deletionRelay = PublishRelay<Void>()
    
    private let sessionID: UUID
    
    init(session: Session) {
        self.sessionID = session.id
        let contentView = DeleteView(character: session.counselor)
        super.init(contentView, logID: "Delete")
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

private extension DeleteViewController {
    func bind() {
        contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    await self.contentView.runDismissAnimation()
                    self.dismiss(animated: false)
                    self.logger.send(.tapped, "삭제 - 배경 클릭(아니요)", nil)
                }
            })
            .disposed(by: rx.disposeBag)
        
        contentView.rejectButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    await self.contentView.runDismissAnimation()
                    self.dismiss(animated: false)
                    self.logger.send(.tapped, "삭제 - 아니요", nil)
                }
            })
            .disposed(by: rx.disposeBag)
        
        contentView.acceptButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                Task { guard let self else { return }
                    try await self.counselingSessionRepository.delete(id: self.sessionID)
                    await self.contentView.runDismissAnimation()
                    self.deletionRelay.accept(())
                    self.dismiss(animated: false)
                }
                
                self?.logger.send(.tapped, "삭제 - 예", nil)
            })
            .disposed(by: rx.disposeBag)
    }
}
