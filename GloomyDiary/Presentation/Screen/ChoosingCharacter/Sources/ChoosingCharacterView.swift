//
//  ChoosingCharacterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import Combine
import Lottie
import UIKit

final class ChoosingCharacterView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let NormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(100)
        static let scrollViewTopPadding: CGFloat = .deviceAdjustedHeight(53)
        static let nextButtonTopPadding: CGFloat = .deviceAdjustedHeight(40)
        static let buttonWidth: CGFloat = .deviceAdjustedHeight(240)
        static let buttonHeight: CGFloat = .deviceAdjustedHeight(240)
        static let scrollPadding: CGFloat = .deviceAdjustedHeight(20)
        static let detailLabelTopPadding: CGFloat = .deviceAdjustedHeight(34)
    }
    
    
    // MARK: - Views
    
    private let gradientView = GradientView(
        colors: [
            AppColor.Background.sub.color,
            AppColor.Background.main.color
        ],
        locations: [0.0, 0.5, 1.0]
    )
    
    private let introduceLabel = NormalLabel().then {
        $0.text = """
        "울다"에는
        여러분들의 이야기를 들어줄
        세 마리의 친구들이 있어요.
        """
    }
    
    private var scrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private var contentView = UIView()
    
    let detailInformationLabel = NormalLabel().then {
        $0.font = UIView.screenHeight <= 700 ? .온글잎_의연체.body : .온글잎_의연체.title
    }
    
    let nextButton = NormalHorizontalButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    
    // MARK: - Properties
    
    var allCharacterButtons: [CharacterButton] = []
    
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
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - View Life Cycle
    
    private func setup() {
        backgroundColor = AppColor.Background.main.color
    }
    
    private func addSubviews() {
        addSubview(gradientView)
        addSubview(introduceLabel)
        addSubview(scrollView)
        addSubview(detailInformationLabel)
        addSubview(nextButton)
        
        scrollView.addSubview(contentView)
    }
    
    private func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.NormalLabelTopPadding)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp.bottom).offset(Metric.scrollViewTopPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Metric.buttonHeight)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        detailInformationLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(Metric.detailLabelTopPadding)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(detailInformationLabel.snp.bottom).offset(Metric.nextButtonTopPadding)
        }
    }
    
    func spotlight(to identifier: String?) {
        guard let identifier else { return }
        deselectAllButtons()
        allCharacterButtons.forEach { button in
            if button.identifier == identifier {
                button.isSelected = true
            }
        }
    }
    
    func changeThemeIfNeeded() {
        backgroundColor = AppColor.Background.main.color
        gradientView.updateColors([
            AppColor.Background.sub.color,
            AppColor.Background.main.color
        ])
        introduceLabel.changeThemeIfNeeded()
        detailInformationLabel.changeThemeIfNeeded()
        nextButton.changeThemeIfNeeded()
        
        allCharacterButtons.forEach { $0.changeThemeIfNeeded() }
    }
    
    private func deselectAllButtons() {
        self.allCharacterButtons
            .forEach { $0.isSelected = false }
    }
    
    private func setupScrollView() {
        CounselingCharacter.allCases.enumerated().forEach { index, character in
            let button = CharacterButton(character: character)
            allCharacterButtons.append(button)
            
            contentView.addSubview(button)
            button.snp.makeConstraints { make in
                if index == 0 {
                    make.leading.equalTo(contentView.snp.leading)
                } else {
                    make.leading.equalTo(allCharacterButtons[index-1].snp.trailing).offset(Metric.scrollPadding)
                }
                make.width.equalTo(Metric.buttonWidth)
                make.height.equalTo(Metric.buttonHeight)
                make.top.bottom.equalToSuperview()
            }
        }
        
        if let lastButton = allCharacterButtons.last {
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


// MARK: - Animations

extension ChoosingCharacterView {
    func hideAllComponents() {
        subviews.filter { $0 != gradientView }
            .forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: subviews.exclude(gradientView).map {
                    Animation(view: $0,
                              animationCase: .fadeIn,
                              duration: 0.5)
                },
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: subviews.map {
                    Animation(view: $0,
                              animationCase: .fadeOut,
                              duration: 0.5)
                },
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}


// MARK: - Scroll Delegate

extension ChoosingCharacterView: UIScrollViewDelegate {
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
            currentPage = min(currentPage + 1, allCharacterButtons.count - 1)
        }
        switchToPage(currentPage)
    }
    
    func switchToPage(_ page: Int) {
        let pageWidth = Metric.buttonWidth + Metric.scrollPadding
        let inset = scrollView.contentInset.left
        
        pageSubject.send(page)
        
        scrollView.setContentOffset(
            CGPoint(x: CGFloat(page) * pageWidth - inset, y: 0),
            animated: true
        )
    }
}


// MARK: - Gesture

extension ChoosingCharacterView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
