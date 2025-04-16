//
//  HistoryDetailMenuView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/13/24.
//

import UIKit
final class HistoryDetailMenuView: UIView {
    
    // MARK: - Views
    
    var menuButtons: [MenuButton] = [] {
        didSet {
            for subview in buttonStackView.arrangedSubviews {
                subview.removeFromSuperview()
            }
            
            menuButtons.forEach { buttonStackView.addArrangedSubview($0) }
        }
    }
    
    var backgroundView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.alpha = 0.0
    }
    
    var containerView = UIView().then {
        $0.backgroundColor = AppColor.Background.mainPurple.color
        $0.applyCornerRadius(20)
        $0.alpha = 0.0
    }
    
    var buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 17
        $0.distribution = .fillEqually
    }
    
    
    // MARK: - Properties
    
    private var navigationControllerHeight: CGFloat
    
    
    // MARK: - Initialize
    
    init(navigationControllerHeight: CGFloat) {
        self.navigationControllerHeight = navigationControllerHeight
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with items: [MenuItem]) {
        let buttons = items.map { createButton(item: $0) }
        menuButtons = buttons
    }
    
    private func createButton(item: MenuItem) -> MenuButton {
        return MenuButton(item: item)
    }
    
    
    // MARK: - View Life Cycle
    
    private func addSubviews() {
        addSubview(backgroundView)
        addSubview(containerView)
        containerView.addSubview(buttonStackView)
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(navigationControllerHeight)
            make.trailing.equalToSuperview().inset(20)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
}


// MARK: - Animations

extension HistoryDetailMenuView {
    @MainActor
    func playFadeInAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: containerView,
                              animationCase: .fadeIn,
                              duration: 0.2),
                    Animation(view: backgroundView,
                              animationCase: .fadeIn,
                              duration: 0.2)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: containerView,
                              animationCase: .fadeOut,
                              duration: 0.2),
                    Animation(view: backgroundView,
                              animationCase: .fadeOut,
                              duration: 0.2)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
