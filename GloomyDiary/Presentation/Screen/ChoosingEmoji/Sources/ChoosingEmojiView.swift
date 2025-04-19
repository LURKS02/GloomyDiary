//
//  ChoosingEmojiView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class ChoosingEmojiView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let nextButtonTopPadding: CGFloat = .deviceAdjustedHeight(50)
        static let stackViewSpacing: CGFloat = 15
        static let NormalLabelTopPadding: CGFloat = .deviceAdjustedHeight(153)
        static let emojiStackViewTopPadding: CGFloat = .deviceAdjustedHeight(60)
        static let emojiStackViewHorizontalPadding: CGFloat = .deviceAdjustedWidth(30)
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
        $0.text = "기분은 어때요?"
    }
    
    private lazy var emojiStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = Metric.stackViewSpacing
        $0.distribution = .fillEqually
    }
    
    let nextButton = HorizontalButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    
    // MARK: - Properties
    
    var allEmojiButtons: [EmojiButton] {
        emojiStackView.flattenSubviews.compactMap { $0 as? EmojiButton }
    }
    
    let columnCount: Int = 3
    
    
    // MARK: - Initialize

    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
        
        var rowStackView: UIStackView?
        Emoji.allCases.enumerated().forEach { index, emoji in
            if index % columnCount == 0 {
                rowStackView = UIStackView().then {
                    $0.axis = .horizontal
                    $0.spacing = Metric.stackViewSpacing
                }
                
                guard let rowStackView else { return }
                emojiStackView.addArrangedSubview(rowStackView)
            }
            
            let emojiButton = EmojiButton(emoji: emoji)
            rowStackView?.addArrangedSubview(emojiButton)
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func addSubviews() {
        addSubview(gradientView)
        addSubview(introduceLabel)
        addSubview(emojiStackView)
        addSubview(nextButton)
    }

    private func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.NormalLabelTopPadding)
        }
        
        emojiStackView.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp.bottom).offset(Metric.emojiStackViewTopPadding)
            make.leading.equalToSuperview().inset(Metric.emojiStackViewHorizontalPadding)
            make.trailing.equalToSuperview().inset(Metric.emojiStackViewHorizontalPadding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emojiStackView.snp.bottom).offset(Metric.nextButtonTopPadding)
        }
    }
    
    func spotlight(to identifier: String?) {
        allEmojiButtons.forEach { button in
            var configuration = button.configuration
            if button.identifier == identifier {
                configuration?.background.backgroundColor = AppColor.Component.selectedSelectionButton.color
            } else {
                configuration?.background.backgroundColor = AppColor.Component.disabledSelectionButton.color
            }
            button.configuration = configuration
        }
    }
}


// MARK: - Animations

extension ChoosingEmojiView {
    func hideAllComponents() {
        subviews.exclude(gradientView).forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents(duration: TimeInterval) async {
        let percentages: [CGFloat] = [25, 50, 25]
        let calculatedDurations = percentages.map { duration * $0 / 100 }
        
        await playShowingLabel(duration: calculatedDurations[0])
        await playStackView(duration: calculatedDurations[1])
        await playShowingNextButton(duration: calculatedDurations[2])
    }
    
    @MainActor
    func playShowingLabel(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: introduceLabel,
                              animationCase: .fadeIn,
                              duration: duration)
                ],
                mode: .serial,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    private func playStackView(duration: TimeInterval) async {
        let buttonDuration: TimeInterval = 0.5
        emojiStackView.alpha = 1.0
        
        allEmojiButtons.forEach { button in
            button.alpha = 0.0
            button.transform = .identity.translatedBy(x: 0, y: .deviceAdjustedHeight(20))
        }
        
        await withCheckedContinuation { continuation in
            let totalAnimations = allEmojiButtons.count
            var completedAnimations = 0
            
            let reciprocal = (duration - buttonDuration) / Double(allEmojiButtons.count)
            
            allEmojiButtons.enumerated().forEach { index, button in
                DispatchQueue.main.asyncAfter(deadline: .now() + reciprocal * Double(index)) {
                    self.playButton(button: button, duration: buttonDuration) {
                        completedAnimations += 1
                        
                        if completedAnimations ==  totalAnimations { continuation.resume() }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func playShowingNextButton(duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: nextButton,
                              animationCase: .fadeIn,
                              duration: duration)
                ],
                mode: .serial,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    private func playButton(
        button: EmojiButton,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        UIView.animate(withDuration: duration, animations: {
            button.alpha = 1.0
            button.transform = .identity
        }) { _ in
            completion()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: subviews.exclude(gradientView).map {
                    Animation(
                        view: $0,
                        animationCase: .fadeOut,
                        duration: 0.5
                    )
                },
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
