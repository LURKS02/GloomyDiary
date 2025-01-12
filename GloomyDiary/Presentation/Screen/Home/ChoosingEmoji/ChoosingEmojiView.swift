//
//  ChoosingEmojiView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit

final class ChoosingEmojiView: BaseView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let nextButtonTopPadding: CGFloat = .verticalValue(50)
        static let stackViewSpacing: CGFloat = 15
        static let introduceLabelTopPadding: CGFloat = .verticalValue(153)
        static let emojiStackViewTopPadding: CGFloat = .verticalValue(60)
        static let emojiStackViewHorizontalPadding: CGFloat = .horizontalValue(30)
    }
    
    
    // MARK: - Views

    private let gradientView = GradientView(colors: [.background(.darkPurple), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    private let introduceLabel = IntroduceLabel().then {
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
    
    let columnCount: Int = 3
    
    var allEmojiButtons: [EmojiButton] {
        emojiStackView.flattenSubviews.compactMap { $0 as? EmojiButton }
    }
    
    
    // MARK: - Initialize

    init() {
        super.init(frame: .zero)
        
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
    
    override func setup() {
        
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(introduceLabel)
        addSubview(emojiStackView)
        addSubview(nextButton)
    }

    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.introduceLabelTopPadding)
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
                configuration?.background.backgroundColor = .component(.buttonSelectedBlue)
            } else {
                configuration?.background.backgroundColor = .component(.buttonPurple)
            }
            button.configuration = configuration
        }
    }
}


// MARK: - Animations

extension ChoosingEmojiView {
    func hideAllComponents() {
        subviews.filter { $0 != gradientView }
            .forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: introduceLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
            
        await playStackView()
            
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: nextButton,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .serial,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    private func playStackView() async {
        emojiStackView.alpha = 1.0
        
        allEmojiButtons.forEach { button in
            button.alpha = 0.0
            button.transform = .identity.translatedBy(x: 0, y: .verticalValue(20))
        }
        
        await withCheckedContinuation { continuation in
            let totalAnimations = allEmojiButtons.count
            var completedAnimations = 0
            
            allEmojiButtons.enumerated().forEach { index, button in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                    self.playButton(button: button) {
                        completedAnimations += 1
                        
                        if completedAnimations ==  totalAnimations { continuation.resume() }
                    }
                }
            }
        }
    }
    
    private func playButton(button: EmojiButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            button.alpha = 1.0
            button.transform = .identity
        }) { _ in
            completion()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: subviews.filter { $0 != gradientView }.map { Animation(view: $0, animationCase: .fadeOut, duration: 0.5)},
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
