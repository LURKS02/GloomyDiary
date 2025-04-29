//
//  ThemeView.swift
//  GloomyDiary
//
//  Created by 디해 on 4/21/25.
//

import Combine
import UIKit

final class ThemeView: UIView {
    private enum Metric {
        static let scrollPadding: CGFloat = .deviceAdjustedHeight(20)
        static let buttonWidth: CGFloat = .deviceAdjustedWidth(282)
        static let buttonHeight: CGFloat = .deviceAdjustedHeight(397)
    }
    
    let titleLabel = NormalLabel().then {
        $0.text = "테마 바꾸기"
    }
    
    var scrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    let nameLabel = NormalLabel()
    
    let informationLabel = NormalLabel().then {
        $0.textColor = AppColor.Text.fogHighlight.color
    }
    
    private var containerView = UIView()
    
    let selectButton = SubHorizontalButton().then {
        $0.setTitle("변경하기", for: .normal)
    }
    
    
    // MARK: - Properties

    var allModeButtons: [ThemeButton] = []
    
    var pageSubject = PassthroughSubject<Int, Never>()
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
        setupScrollView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        scrollView.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        backgroundColor = AppColor.Background.letter.color
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(nameLabel)
        addSubview(informationLabel)
        addSubview(selectButton)
        
        scrollView.addSubview(containerView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(45)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Metric.buttonHeight)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
        }
        
        informationLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        selectButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(informationLabel.snp.bottom).offset(40)
        }
    }
    
    private func setupScrollView() {
        AppearanceMode.allCases.enumerated().forEach { index, mode in
            let button = ThemeButton(theme: mode, identifier: index)
            allModeButtons.append(button)
            
            containerView.addSubview(button)
            
            button.snp.makeConstraints { make in
                if index == 0 {
                    make.leading.equalTo(containerView.snp.leading)
                } else {
                    make.leading.equalTo(allModeButtons[index-1].snp.trailing).offset(Metric.scrollPadding)
                }
                make.width.equalTo(Metric.buttonWidth)
                make.height.equalTo(Metric.buttonHeight)
                make.top.bottom.equalToSuperview()
            }
        }
        
        if let lastButton = allModeButtons.last {
            lastButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: (self.bounds.width - Metric.buttonWidth) / 2,
            bottom: 0,
            right: (self.bounds.width - Metric.buttonWidth) / 2
        )
    }
}

extension ThemeView {
    func changeThemeIfNeeded(with theme: AppearanceMode) {
        backgroundColor = AppColor.Background.letter.color(for: theme)
        titleLabel.textColor = AppColor.Text.main.color(for: theme)
        nameLabel.textColor = AppColor.Text.main.color(for: theme)
        informationLabel.textColor = AppColor.Text.fogHighlight.color(for: theme)
        selectButton.changeThemeIfNeeded(with: theme)
    }
}

extension ThemeView {
    @MainActor
    func playAppearingAnimation(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 0,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(
                        view: self,
                        animationCase: .fadeIn,
                        duration: duration
                    ),
                    Animation(
                        view: self,
                        animationCase: .frame(targetFrame),
                        duration: duration
                    )
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            ).run()
        }
    }
    
    @MainActor
    func playDisappearingAnimation(duration: TimeInterval) async {
        let targetFrame = CGRect(
            x: 100,
            y: 0,
            width: UIView.screenWidth,
            height: UIView.screenHeight
        )
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(
                        view: self,
                        animationCase: .fadeOut,
                        duration: duration
                    ),
                    Animation(
                        view: self,
                        animationCase: .frame(targetFrame),
                        duration: duration
                    )
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            ).run()
        }
    }
}

extension ThemeView: UIScrollViewDelegate {
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: scrollView)
        let velocity = gesture.velocity(in: scrollView)
        
        let newOffsetX = scrollView.contentOffset.x - translation.x
        scrollView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: false)
        gesture.setTranslation(.zero, in: scrollView)
        
        if gesture.state == .ended {
            adjustScrollViewContentOffset(for: velocity)
        }
    }
    
    private func adjustScrollViewContentOffset(for velocity: CGPoint) {
        let pageWidth = Metric.buttonWidth + Metric.scrollPadding
        var currentOffset = scrollView.contentOffset.x
        let inset = scrollView.contentInset.left
        currentOffset = max(0, min(currentOffset, scrollView.contentSize.width - scrollView.bounds.width))
        var currentPage = Int((currentOffset + inset) / pageWidth)
        
        if velocity.x < 0 {
            currentPage = min(currentPage + 1, allModeButtons.count - 1)
        }
        switchToPage(currentPage, animated: true)
        pageSubject.send(currentPage)
    }
    
    func switchToPage(_ page: Int, animated: Bool) {
        let pageWidth = Metric.buttonWidth + Metric.scrollPadding
        let inset = scrollView.contentInset.left
        
        scrollView.setContentOffset(
            CGPoint(x: CGFloat(page) * pageWidth - inset, y: 0),
            animated: animated
        )
    }
}

extension ThemeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
