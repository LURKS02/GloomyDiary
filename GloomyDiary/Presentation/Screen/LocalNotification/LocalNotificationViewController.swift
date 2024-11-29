//
//  LocalNotificationViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 11/28/24.
//

import UIKit

final class LocalNotificationViewController: BaseViewController<LocalNotificationView> {
    
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

private extension LocalNotificationViewController {
    func bind() {
        contentView.rejectButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                Task { @MainActor in
                    guard let self,
                          let title = self.contentView.rejectButton.title(for: .normal) else { return }
                    await self.contentView.runFadeOutLeftAnimation()
                    await self.contentView.showRejectResult()
                    Logger.send(type: .tapped, title)
                }
            })
            .disposed(by: rx.disposeBag)
        
        contentView.acceptButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                Task {
                    guard let self,
                          let title = self.contentView.acceptButton.title(for: .normal) else { return }
                    let result = await LocalNotification.shared.requestNotificationPermission()
                    await self.contentView.runFadeOutLeftAnimation()
                    if result == true {
                        await self.contentView.showAcceptResult()
                    } else {
                        await self.contentView.showRejectResult()
                    }
                    
                    Logger.send(type: .tapped, title)
                }
            })
            .disposed(by: rx.disposeBag)
        
        contentView.checkButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                Task {
                    guard let self,
                          let title = self.contentView.checkButton.title(for: .normal) else { return }
                    await self.contentView.runDismissAnimation()
                    self.dismiss(animated: false)
                    
                    Logger.send(type: .tapped, title)
                }
            })
            .disposed(by: rx.disposeBag)
    }
}
