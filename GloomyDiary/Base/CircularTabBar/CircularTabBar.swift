//
//  CircularTabBar.swift
//  GloomyDiary
//
//  Created by 디해 on 10/25/24.
//

import UIKit
import RxRelay

final class CircularTabBar: UIView {
    
    private let tabBarItems: [CircularTabBarItem]
    
    private let iconSize: CGFloat = 30
    
    private let iconOffset: CGFloat = 40
    
    private var color: UIColor = .black
    
    private var isTouchInside: Bool = false
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    let diameter: CGFloat = 200
    
    var icons: [UIImageView] = []
    
    var numberOfTabs: Int {
        tabBarItems.count
    }
    
    var tabBarTappedRelay = PublishRelay<Void>()
    
    init(items: [CircularTabBarItem]) {
        self.tabBarItems = items
        
        super.init(frame: .zero)
        
        tabBarItems.indices.forEach { index in
            let iconView = createTabBarIcon(with: index)
            icons.append(iconView)
            self.addSubview(iconView)
        }
        
        self.backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTabBarIcon(with index: Int) -> UIImageView {
        let radius = diameter / 2
        let center = CGPoint(x: radius, y: radius)
        
        let angle = 360.0 / CGFloat(tabBarItems.count) * CGFloat(index)
        let radians = CGFloat(angle) * .pi / 180
        
        let x = center.x + CGFloat(sin(radians)) * (radius - iconOffset)
        let y = center.y - CGFloat(cos(radians)) * (radius - iconOffset)
        
        let iconImageView = UIImageView()
        iconImageView.frame = CGRect(x: x - iconSize / 2, y: y - iconSize / 2, width: iconSize, height: iconSize)
        iconImageView.image = tabBarItems[index].normalImage
        iconImageView.transform = CGAffineTransform(rotationAngle: radians)
        return iconImageView
    }
    
    func highlightIcon(index: Int, isHighlighted: Bool) {
        icons[index].image = isHighlighted ? tabBarItems[index].selectedImage : tabBarItems[index].normalImage
    }
}


// MARK: - Touches

extension CircularTabBar {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        isTouchInside = true
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        isTouchInside = self.bounds.contains(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
        
        if isTouchInside {
            tabBarTappedRelay.accept(())
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
}
