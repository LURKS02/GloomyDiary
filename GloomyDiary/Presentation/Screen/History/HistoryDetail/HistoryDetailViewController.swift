//
//  HistoryDetailViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class HistoryDetailViewController: BaseViewController<HistoryDetailView> {
    private weak var weakNavigationController: UINavigationController?
    
    init(session: CounselingSessionDTO) {
        let contentView = HistoryDetailView(session: session)
        super.init(contentView, logID: "HistoryDetail")
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
        
        let titleImage = UIImage(named: "letter")?.resized(width: 40, height: 40)
        let imageView = UIImageView(image: titleImage)
        self.navigationItem.titleView = imageView
        
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
