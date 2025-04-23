//
//  SettingView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import Combine
import UIKit

final class SettingView: UIView {
    
    private let menuHeight: CGFloat = 50
    
    private let containerView = UIView().then {
        $0.backgroundColor = AppColor.Background.letter.color
        $0.layer.cornerRadius = 20
    }
    
    private let menuView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private var menuViews: [SettingMenuView] = []
    
    let menuPublisher = PassthroughSubject<SettingCase, Never>()
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = AppColor.Background.main.color
    }
    
    private func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(menuView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        menuView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(17)
            make.horizontalEdges.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().inset(17)
        }
    }
    
    func configure(with items: [SettingMenuItem]) {
        menuView.subviews.forEach { $0.removeFromSuperview() }
        
        let menuViews = items.map { SettingMenuView(item: $0) }
        self.menuViews = menuViews
        
        menuViews.enumerated().forEach { (index, view) in
            menuView.addSubview(view)
            
            if items[index].isNavigatable {
                let tapGesture = UITapGestureRecognizer()
                view.addGestureRecognizer(tapGesture)
                tapGesture.tapPublisher
                    .sink { [weak self] _ in
                        guard let self else { return }
                        self.menuPublisher.send(items[index].settingCase)
                    }
                    .store(in: &cancellables)
            }
            
            if index == 0 {
                view.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.height.equalTo(menuHeight)
                }
            } else if index == menuViews.count - 1 {
                view.snp.makeConstraints { make in
                    make.top.equalTo(menuViews[index-1].snp.bottom)
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.height.equalTo(menuHeight)
                    make.bottom.equalToSuperview()
                }
            } else {
                view.snp.makeConstraints { make in
                    make.top.equalTo(menuViews[index-1].snp.bottom)
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.height.equalTo(menuHeight)
                }
            }
        }
    }
}

extension SettingView {
    func changeTheme(with theme: AppearanceMode) {
        self.backgroundColor = AppColor.Background.main.color(for: theme)
        containerView.backgroundColor = AppColor.Background.letter.color(for: theme)
        menuViews.map { $0.changeTheme(with: theme) }
    }
    
    func hideAllComponents() {
        subviews.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playAppearing(direction: TabBarDirection) async {
        switch direction {
        case .left:
            self.subviews
                .forEach { $0.transform = .identity.translatedBy(x: 10, y: 0) }
        case .right:
            self.subviews
                .forEach { $0.transform = .identity.translatedBy(x: -10, y: 0) }
        }
        
        let transformAnimation = subviews.map {
            Animation(
                view: $0,
                animationCase: .transform(.identity),
                duration: 0.2
            )
        }
        
        let fadeInAnimation = subviews.map {
            Animation(
                view: $0,
                animationCase: .fadeIn,
                duration: 0.2
            )
        }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: transformAnimation + fadeInAnimation,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            )
            .run()
        }
    }
    
    @MainActor
    func playDisappearing(direction: TabBarDirection) async {
        var translationX = 0.0
        
        switch direction {
        case .left:
            translationX = -10
        case .right:
            translationX = 10
        }
        
        let transformAnimation = subviews.map {
            Animation(
                view: $0,
                animationCase: .transform(.init(translationX: translationX, y: 0)),
                duration: 0.2
            )
        }
        
        let fadeOutAnimation = subviews.map {
            Animation(
                view: $0,
                animationCase: .fadeOut,
                duration: 0.2
            )
        }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: transformAnimation + fadeOutAnimation,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            )
            .run()
        }
    }
}
