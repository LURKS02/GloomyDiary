//
//  FloatingTabBarController.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import CombineCocoa
import UIKit

final class FloatingTabBarController: UITabBarController {
    private let floatingTabBar: FloatingTabBar
    
    private var currentIndex: Int {
        didSet {
            selectedIndex = currentIndex
            highlightButtons()
        }
    }
    
    private var previousIndex: Int = 0
    
    init(tabBarItems: [FloatingTabBarItem]) {
        self.currentIndex = 0
        self.floatingTabBar = FloatingTabBar(items: tabBarItems)
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = tabBarItems.map { $0.viewController }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        addSubviews()
        setupTabBar()
        
        bind()
    }
    
    private func setup() {
        self.tabBar.isHidden = true
        self.delegate = self
    }
    
    private func addSubviews() {
        view.addSubview(floatingTabBar)
    }
    
    private func setupTabBar() {
        floatingTabBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(25)
        }
        
        floatingTabBar.tabBarButtons.enumerated().forEach { (index, button) in
            button.tapPublisher
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.currentIndex = index
                }
                .store(in: &cancellables)
        }
        
        highlightButtons()
    }
    
    private func bind() {
        NotificationCenter.default
            .publisher(for: .themeChanged)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.floatingTabBar.changeTheme(with: AppEnvironment.appearanceMode)
            }
            .store(in: &cancellables)
    }
    
    private func highlightButtons() {
        for (index, button) in floatingTabBar.tabBarButtons.enumerated() {
            UIView.transition(with: button, duration: 0.4, options: .transitionCrossDissolve) {
                self.floatingTabBar.highlightIcon(index: index, isHighlighted: (index == self.currentIndex))
            }
        }
    }
}

extension FloatingTabBarController {
    func hideTabBar() {
        floatingTabBar.alpha = 0.0
    }
    
    @MainActor
    func playDisappearingTabBar(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: floatingTabBar,
                                              animationCase: .fadeOut,
                                              duration: duration)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAppearingTabBar(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: floatingTabBar,
                                              animationCase: .fadeIn,
                                              duration: duration)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}

extension FloatingTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        var direction: TabBarDirection = .left
        
        if previousIndex < currentIndex {
            direction = .left
        } else {
            direction = .right
        }
        
        let fromDelegate = fromVC.visibleViewController() as? FloatingTabBarControllerDelegate
        let toDelegate = toVC.visibleViewController() as? FloatingTabBarControllerDelegate
        let tabDidDisappear = fromDelegate?.tabDidDisappear
        let tabWillAppear = toDelegate?.tabWillAppear
        
        previousIndex = currentIndex
        
        return TabSwitchingTransition(
            direction: direction,
            tapDidDisappear: tabDidDisappear,
            tapWillAppear: tabWillAppear
        )
    }
}
