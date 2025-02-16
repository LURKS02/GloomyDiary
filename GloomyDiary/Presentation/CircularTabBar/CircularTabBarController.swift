//
//  CircularTabBarController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/24/24.
//

import UIKit

final class CircularTabBarController: UITabBarController {
    
    private let circularTabBar: CircularTabBar
    
    private var currentIndex: Int {
        didSet {
            guard let viewControllers else { return }
            
            selectedIndex = currentIndex
        }
    }
    
    init(tabBarItems: [CircularTabBarItem], currentIndex: Int = 0) {
        self.currentIndex = currentIndex
        self.circularTabBar = CircularTabBar(items: tabBarItems)
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = tabBarItems.map { $0.viewController }
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        addSubviews()
        setupTabBar()
        setupTapGesture()
    }
    
    private func setup() {
        self.tabBar.isHidden = true
    }
    
    private func addSubviews() {
        view.addSubview(circularTabBar)
    }
    
    private func setupTabBar() {
        view.backgroundColor = .clear
        
        circularTabBar.frame = CGRect(x: view.bounds.width / 2 - circularTabBar.diameter / 2,
                                      y: view.bounds.height - circularTabBar.diameter / 2 + 10,
                                      width: circularTabBar.diameter,
                                      height: circularTabBar.diameter)
        
        highlightCurrentTab()
    }
    
    private func setupTapGesture() {
        circularTabBar.tabBarDelegate = self
    }
    
    private func rotateTabBar(index: Int) {
        let angle: CGFloat = (2 * .pi / CGFloat(circularTabBar.numberOfTabs)) * CGFloat(index)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.circularTabBar.contentView.transform = .identity.rotated(by: -angle)
        })
    }
    
    private func highlightCurrentTab() {
        for (index, icon) in circularTabBar.icons.enumerated() {
            UIView.transition(with: icon, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.circularTabBar.highlightIcon(index: index, isHighlighted: (index == self.currentIndex))
            }, completion: nil)
        }
    }
}

extension CircularTabBarController: CircularTabBarDelegate {
    func tabBarTapped() {
        currentIndex = (currentIndex + 1) % circularTabBar.numberOfTabs
        rotateTabBar(index: currentIndex)
        highlightCurrentTab()
    }
}

extension CircularTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        TabSwitchingTransition()
    }
}

extension CircularTabBarController: CircularTabBarControllable {
    func hideCircularTabBar() {
        circularTabBar.alpha = 0.0
    }
    
    func hideCircularTabBar(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: circularTabBar,
                                              animationCase: .fadeOut,
                                              duration: duration)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }

    func showCircularTabBar(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: circularTabBar,
                                              animationCase: .fadeIn,
                                              duration: duration)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
