//
//  HistoryDetailViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import ComposableArchitecture
import RxSwift
import RxRelay
import UIKit

final class HistoryDetailViewController: BaseViewController<HistoryDetailView> {
    
    @Dependency(\.logger) var logger
    
    let store: StoreOf<HistoryDetail>
    
    // MARK: - Properties
    
    private weak var weakNavigationController: UINavigationController?
    
    private var menuViewController: HistoryMenuViewController?
    
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
    
    var deletionRelay = PublishRelay<Void>()
    
    
    // MARK: - Initialize
    
    init(store: StoreOf<HistoryDetail>) {
        self.store = store
        super.init()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let windowTopInset,
              let navigationControllerHeight else { return }
        contentView.makeScrollViewOffsetConstraints(offset: windowTopInset + navigationControllerHeight)
        
//        guard let navigationController = navigationController else { return }
//        let appearance = navigationController.navigationBar.standardAppearance
//        appearance.backgroundColor = .component(.buttonPurple)
//        navigationController.backgroundColor = .component(.buttonPurple)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !contentView.isAnimated {
            Task { @MainActor in
                await contentView.playFadeInAllComponents()
                contentView.isAnimated = true
            }
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}


// MARK: - bind

private extension HistoryDetailViewController {
    func bind() {
        contentView.imageScrollView.tapRelay
            .subscribe(onNext: { [weak self] id in
                guard let self,
                      let id else { return }
                openImageViewer(with: id)
            })
            .disposed(by: rx.disposeBag)
        
        observe { [weak self] in
            guard let self else { return }
            contentView.configure(with: store.session)
        }
    }
}


// MARK: - Navigation

private extension HistoryDetailViewController {
    func openImageViewer(with imageID: UUID) {
        let imageViewer = ImageDetailViewController(imageID: imageID)
        imageViewer.modalPresentationStyle = .pageSheet
        present(imageViewer, animated: true)
    }
    
    func setupNavigationBar() {
        guard let image = UIImage(named: "letter") else { return }
        let size: CGFloat = 40
        let titleImage = image.resized(width: size, height: size)
        let imageView = UIImageView(image: titleImage)
        imageView.contentMode = .center
        self.navigationItem.titleView = imageView
        
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(showMenu)
        )
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        moreButton.tintColor = .white
        backButton.tintColor = .white
        navigationItem.rightBarButtonItem = moreButton
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
        self.logger.send(.tapped, "상세 - 삭제하기", nil)
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
        self.logger.send(.tapped, "상세 - 공유하기", nil)
        guard let menuViewController else { return }
        ShareService.share(character: store.session.counselor,
                           request: store.session.query,
                           response: store.session.response,
                           in: menuViewController,
                           completion: { Task { await menuViewController.close() }})
    }
}


// MARK: - Transition

extension HistoryDetailViewController: FromTransitionable {
    var fromTransitionComponent: UIView? {
        nil
    }
    
    func prepareTransition(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 100,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        await playDetailViewAnimation(
            contentView,
            frame: targetFrame,
            duration: duration,
            showing: false
        )
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}


extension HistoryDetailViewController: ToTransitionable {
    var toTransitionComponent: UIView? {
        nil
    }
    
    func completeTransition(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 100,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        contentView.alpha = 0.0
        contentView.frame = targetFrame
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        await playDetailViewAnimation(
            contentView,
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIView.screenWidth,
                height: UIView.screenHeight
            ),
            duration: duration,
            showing: true
        )
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @MainActor
    private func playDetailViewAnimation(
        _ view: UIView,
        frame: CGRect,
        duration: TimeInterval,
        showing: Bool
    ) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [Animation(view: view,
                                       animationCase: showing ? .fadeIn : .fadeOut,
                                       duration: duration),
                             Animation(view: view,
                                       animationCase: .frame(frame),
                                       duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}


extension HistoryDetailViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AnimatedTransition(
            fromDuration: 0.3,
            toDuration: 0.0,
            timing: .parallel,
            transitionContentType: .switchedHierarchyTransition
        )
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
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
