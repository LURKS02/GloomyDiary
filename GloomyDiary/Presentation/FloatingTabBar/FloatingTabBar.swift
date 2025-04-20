//
//  FloatingTabBar.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import SnapKit
import UIKit

final class FloatingTabBar: UIView {
    
    private let contentView = UIView()
    
    private let highlightCircleView = UIView().then {
        $0.backgroundColor = AppColor.Component.tabBarSelectedButton.color
    }
    
    private let tabBarItems: [FloatingTabBarItem]
    
    private let contentPadding: CGFloat = 15
    
    private let innerPadding: CGFloat = 45
    
    private let radius: CGFloat = 50
    
    var tabBarButtons: [FloatingTabBarItemButton] = []
    
    init(items: [FloatingTabBarItem]) {
        self.tabBarItems = items
        
        super.init(frame: .zero)
        
        self.tabBarButtons = items.map { FloatingTabBarItemButton(item: $0, radius: radius) }
        setup()
        setupIcons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(highlightCircleView)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentPadding)
        }
        backgroundColor = AppColor.Component.mainPoint.color
    }
    
    private func setupIcons() {
        tabBarButtons.indices.forEach { index in
            let button = tabBarButtons[index]
            contentView.addSubview(button)
            
            if index == 0 {
                button.snp.makeConstraints { make in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                }
            } else if index == tabBarItems.count - 1 {
                button.snp.makeConstraints { make in
                    make.trailing.equalToSuperview()
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.leading.equalTo(tabBarButtons[index-1].snp.trailing).offset(innerPadding)
                }
            } else {
                button.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.leading.equalTo(tabBarButtons[index-1].snp.trailing).offset(innerPadding)
                }
            }
        }
        
        highlightCircleView.frame = .init(
            x: contentPadding,
            y: contentPadding,
            width: radius,
            height: radius
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCircularShape()
        highlightCircleView.applyCircularShape()
    }
    
    func highlightIcon(index: Int, isHighlighted: Bool) {
        tabBarButtons[index].setButtonImage(isHighlighted: isHighlighted)
        
        if isHighlighted {
            AnimationGroup(
                animations: [
                    Animation(
                        view: self.highlightCircleView,
                        animationCase: .frame(
                            .init(
                                x: self.contentPadding + CGFloat(index) * (self.innerPadding + self.radius),
                                y: self.contentPadding,
                                width: self.radius,
                                height: self.radius
                            )
                        ),
                    duration: 0.2
                )],
                mode: .parallel,
                loop: .once(completion: {})
            ).run()
            
            AnimationGroup(
                animations: [
                    Animation(
                        view: self.highlightCircleView,
                        animationCase: .fadeOut,
                        duration: 0.1
                    ),
                    Animation(
                        view: self.highlightCircleView,
                        animationCase: .fadeIn,
                        duration: 0.1
                    )],
                mode: .serial,
                loop: .once(completion: {})
            )
            .run()
        }
    }
}
