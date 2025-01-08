//
//  HistoryDetailViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit
import ComposableArchitecture
import RxSwift

final class HistoryDetailViewController: BaseViewController<HistoryDetailView> {
    
    let store: StoreOf<HistoryDetail>
    
    private weak var weakNavigationController: UINavigationController?
    
    private var menuViewController: HistoryMenuViewController?
    
    var deletionRelay = PublishRelay<Void>()
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<HistoryDetail>) {
        self.store = store
        super.init(logID: "HistoryDetail")
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var windowTopInset: CGFloat? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow) else { return nil }
        
        return keyWindow.safeAreaInsets.top
    }
    
    private var navigationControllerHeight: CGFloat? {
        guard let navigationBar = self.navigationController?.navigationBar else { return nil }
        return navigationBar.frame.height
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        setupNavigationBar()
        
        navigationController?.delegate = self
        self.weakNavigationController = navigationController
        Task { @MainActor in
            guard let tabBarController = tabBarController as? CircularTabBarControllable else { return }
            await tabBarController.hideCircularTabBar(duration: 0.3)
        }
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.alpha = 0.0
        
        guard let windowTopInset,
              let navigationControllerHeight else { return }
        contentView.makeScrollViewOffsetConstraints(offset: windowTopInset + navigationControllerHeight)
        
        guard let navigationController = navigationController as? NavigationController else { return }
        navigationController.backgroundColor = .component(.buttonPurple)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !contentView.isAnimated {
            Task { @MainActor in
                await contentView.playFadeInAllComponents()
                contentView.isAnimated = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

private extension HistoryDetailViewController {
    func bind() {
        contentView.imageScrollView.tapRelay
            .subscribe(onNext: { [weak self] url in
                guard let self,
                      let url else { return }
                openImageViewer(with: url)
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            contentView.configure(with: store.session)
        }
    }
}

private extension HistoryDetailViewController {
    func openImageViewer(with url: URL) {
        let imageViewer = ImageDetailViewController(url: url)
        imageViewer.modalPresentationStyle = .pageSheet
        present(imageViewer, animated: true)
    }
    
    func setupNavigationBar() {
        guard let image = UIImage(named: "letter") else { return }
        let size: CGFloat = 40
        let titleImage = image.resized(width: size, height: size)
        let imageView = UIImageView(image: titleImage)
        self.navigationItem.titleView = imageView
        
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(showMenu))
        moreButton.tintColor = .white
        navigationItem.rightBarButtonItem = moreButton
    }
    
    @objc func showMenu() {
        guard let navigationControllerHeight else { return }
        let menuViewController = HistoryMenuViewController(navigationControllerHeight: navigationControllerHeight)
        menuViewController.modalPresentationStyle = .overFullScreen
        menuViewController.buttonTappedRelay
            .subscribe(onNext: { [weak self] identifier in
                guard let self,
                      let menuItem = MenuItem(identifier: identifier) else { return }
                switch menuItem {
                case .delete:
                    didTapdeleteMenu()
                case .share:
                    didTapShareMenu()
                }
            })
            .disposed(by: rx.disposeBag)
        self.menuViewController = menuViewController
        
        present(menuViewController, animated: false)
    }
    
    func didTapdeleteMenu() {
        Logger.send(type: .tapped, "상세 - 삭제하기")
        Task {
            guard let menuViewController else { return }
            await menuViewController.close()
            let deleteViewController = DeleteViewController(session: store.session)
            deleteViewController.modalPresentationStyle = .overFullScreen
            deleteViewController.deletionRelay
                .subscribe(onNext: { [weak self] in
                    guard let self else { return }
                    deletionRelay.accept(())
                    navigationController?.popViewController(animated: true)
                })
                .disposed(by: rx.disposeBag)
            present(deleteViewController, animated: false)
        }
    }
    
    func didTapShareMenu() {
        Logger.send(type: .tapped, "상세 - 공유하기")
        guard let menuViewController else { return }
        ShareService.share(character: store.session.counselor,
                           request: store.session.query,
                           response: store.session.response,
                           in: menuViewController,
                           completion: { Task { await menuViewController.close() }})
    }
}

extension HistoryDetailViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        HistoryDetailTransition()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { context in
                if context.isCancelled {
                    Task { @MainActor in
                        guard let tabBarController = navigationController.tabBarController as? CircularTabBarControllable else { return }
                        await tabBarController.hideCircularTabBar(duration: 0.2)
                    }
                }
            }
        }
    }
}


extension HistoryDetailViewController {
    @MainActor
    func playFadeInNavigationBar() async {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: navigationBar,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutNavigationBar() async {
        await withCheckedContinuation { continuation in
            guard let navigationBar = self.weakNavigationController?.navigationBar else { return continuation.resume() }
            AnimationGroup(animations: [.init(view: navigationBar,
                                              animationCase: .fadeOut,
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
