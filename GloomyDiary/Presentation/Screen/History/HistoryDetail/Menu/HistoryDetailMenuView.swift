//
//  HistoryDetailMenuView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/13/24.
//

import UIKit
import RxRelay

final class HistoryDetailMenuView: BaseView {
    
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
    }
    
    var containerView = UIView().then {
        $0.backgroundColor = .background(.mainPurple)
        $0.applyCornerRadius(20)
        $0.alpha = 0.0
    }
    
    var buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 17
        $0.distribution = .fillEqually
    }
    
    private var navigationControllerHeight: CGFloat
    
    init(navigationControllerHeight: CGFloat) {
        self.navigationControllerHeight = navigationControllerHeight
        super.init(frame: .zero)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
    }
    
    override func addSubviews() {
        addSubview(backgroundView)
        addSubview(containerView)
        containerView.addSubview(buttonStackView)
    }
    
    override func setupConstraints() {
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

    func configure(with items: [MenuItem]) {
        let buttons = items.map { createButton(item: $0) }
        menuButtons = buttons
    }
}

private extension HistoryDetailMenuView {
    func createButton(item: MenuItem) -> MenuButton {
        return MenuButton(item: item)
    }
}

extension HistoryDetailMenuView {
    @MainActor
    func playFadeInAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: containerView,
                                              animationCase: .fadeIn,
                                              duration: 0.2),
                                        .init(view: backgroundView,
                                              animationCase: .fadeIn,
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: containerView,
                                              animationCase: .fadeOut,
                                              duration: 0.2),
                                        .init(view: backgroundView,
                                              animationCase: .fadeOut,
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
