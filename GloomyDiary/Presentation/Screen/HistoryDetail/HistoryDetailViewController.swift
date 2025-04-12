//
//  HistoryDetailViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import ComposableArchitecture
import UIKit

final class HistoryDetailViewController: BaseViewController<HistoryDetailView> {
    
    @UIBindable var store: StoreOf<HistoryDetail>
    
    // MARK: - Properties
    
    private weak var weakNavigationController: UINavigationController?
    
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
    
    private var menuViewController: UIViewController?
    
    private var deleteViewController: UIViewController?
    
    
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
        
        store.send(.view(.viewDidLoad))
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
        contentView.imageScrollView.imageTapSubject
            .sink(receiveValue: { [weak self] id in
                guard let self else { return }
                openImageViewer(with: id)
            })
            .store(in: &cancellables)
        
        present(item: $store.scope(state: \.destination?.activity, action: \.scope.destination.activity)) { [weak self] _ in
            guard let self else { return UIViewController() }
            
            let textToShare = Sharing.makeBody(from: self.store.session)
            let itemsToShare: [Any] = [textToShare]
            let vc = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            return vc
        }
        
        observe { [weak self] in
            guard let self else { return }
            contentView.configure(with: store.session)
            
            if let store = store.scope(state: \.destination?.menu, action: \.scope.destination.menu) {
                guard self.menuViewController == nil else { return }
                
                let vc = HistoryMenuViewController(
                    store: store,
                    navigationControllerHeight: self.navigationControllerHeight ?? 0
                )
                vc.modalPresentationStyle = .overFullScreen
                self.menuViewController = vc
                present(vc, animated: false)
            } else {
                if let menuViewController = self.menuViewController {
                    menuViewController.dismiss(animated: false)
                    self.menuViewController = nil
                }
            }
            
            if let store = store.scope(state: \.destination?.delete, action: \.scope.destination.delete) {
                guard self.deleteViewController == nil else { return }
                
                let vc = DeleteViewController(store: store)
                vc.modalPresentationStyle = .overFullScreen
                self.deleteViewController = vc
                present(vc, animated: false)
            } else {
                if let deleteViewController = self.deleteViewController {
                    deleteViewController.dismiss(animated: false)
                    self.deleteViewController = nil
                }
            }
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
            action: #selector(menuButtonTapped)
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
        store.send(.view(.didTapBackButton))
    }
    
    @objc func menuButtonTapped() {
        store.send(.view(.didTapMenuButton))
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
                animations: [
                    Animation(view: view,
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
