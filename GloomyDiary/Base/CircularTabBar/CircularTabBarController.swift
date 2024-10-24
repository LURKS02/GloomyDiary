//
//  CircularTabBarController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/24/24.
//

import UIKit

final class CircularTabBarController: UIViewController {
    
    private let circularTabBar: CircularTabBar
    
    private var currentIndex: Int
    
    var currentAngle: CGFloat = 0
    
    init(tabBarItems: [CircularTabBarItem], currentIndex: Int = 0) {
        self.currentIndex = currentIndex
        self.circularTabBar = CircularTabBar(items: tabBarItems)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupTabBar()
        setupTapGesture()
    }
    
    private func addSubviews() {
        view.addSubview(circularTabBar)
    }
    
    private func setupTabBar() {
        view.backgroundColor = .white
        
        circularTabBar.frame = CGRect(x: view.bounds.width / 2 - circularTabBar.diameter / 2,
                                      y: view.bounds.height / 2,
                                      width: circularTabBar.diameter,
                                      height: circularTabBar.diameter)
        circularTabBar.layer.cornerRadius = circularTabBar.diameter / 2
        
        highlightCurrentTab()
    }
    
    private func setupTapGesture() {
        circularTabBar.tabBarTappedRelay
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.tabTapped()
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func tabTapped() {
        currentIndex = (currentIndex + 1) % circularTabBar.numberOfTabs
        rotateTabBar()
        highlightCurrentTab()
    }
    
    private func rotateTabBar() {
        let angle: CGFloat = (2 * .pi / CGFloat(circularTabBar.numberOfTabs)) // 각 인덱스당 회전 각도

        // 현재 각도에 새 각도를 더하여 최종 회전 각도 계산
        currentAngle -= angle
        print(currentAngle)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            // 항상 시계방향으로 회전
//            self.circularTabBar.transform = CGAffineTransform(rotationAngle: angle)
            self.circularTabBar.transform = self.circularTabBar.transform.rotated(by: self.currentAngle)
            
        })
//        self.circularTabBar.transform = CGAffineTransform(rotationAngle: currentAngle)
    }

    // 호출 시 현재 인덱스를 갱신하는 메서드
    private func updateIndex() {
        // 인덱스를 1 증가시켜서 0에서 numberOfTabs - 1까지 순환
        currentIndex = (currentIndex + 1) % circularTabBar.numberOfTabs
        rotateTabBar() // 회전 메서드 호출
    }
//    private func rotateTabBar(to index: Int) {
//        
//        let angle: CGFloat = (2 * .pi / CGFloat(circularTabBar.numberOfTabs)) // 각 인덱스당 회전 각도
//            
//            // 현재 각도에 새 각도를 더하여 최종 회전 각도 계산
//            currentAngle -= angle
//
//            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//                // 최종 회전 각도만큼 회전
//                self.circularTabBar.transform = CGAffineTransform(rotationAngle: self.currentAngle)
//            })
//        
////        var angle: CGFloat = (2 * .pi / CGFloat(circularTabBar.numberOfTabs)) * CGFloat(index)
////        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
////            self.circularTabBar.transform = .init(rotationAngle: -angle)
////        }, completion: nil)
//        
////        var angle: CGFloat = (2 * .pi / CGFloat(circularTabBar.numberOfTabs)) * CGFloat(index)
////        
////        AnimationGroup(animations: [.init(view: self.circularTabBar,
////                                          animationCase: .transform(transform: CGAffineTransform(rotationAngle: -angle)),
////                                          duration: 0.5)],
////                       mode: .parallel,
////                       loop: .once(completion: { }))
////        .run()
//    }
    
    private func highlightCurrentTab() {
        for (index, icon) in circularTabBar.icons.enumerated() {
            UIView.transition(with: icon, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.circularTabBar.highlightIcon(index: index, isHighlighted: (index == self.currentIndex))
            }, completion: nil)
        }
    }
}
