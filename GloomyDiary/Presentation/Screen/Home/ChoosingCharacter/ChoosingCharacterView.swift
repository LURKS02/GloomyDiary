//
//  ChoosingCharacterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/28/24.
//

import UIKit
import RxSwift
import RxRelay
import Lottie

final class ChoosingCharacterView: BaseView {
    
    // MARK: - Metric
    
    private struct Metric {
        static let nextButtonBottomPadding: CGFloat = 60
        static let buttonWidth: CGFloat = 240
        static let buttonHeight: CGFloat = 240
        static let scrollPadding: CGFloat = 20
    }
    
    
    // MARK: - Views
    
    private let gradientView = GradientView(colors: [.background(.darkPurple), .background(.mainPurple)], locations: [0.0, 0.5, 1.0])
    
    private let introduceLabel = IntroduceLabel().then {
        $0.text = "\"울다\"에는\n" +
        "여러분들의 이야기를 들어줄\n" +
        "세 마리의 친구들이 있어요."
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private var contentView = UIView()
    
    let detailInformationLabel = IntroduceLabel()
    
    let nextButton = HorizontalButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    var allCharacterButtons: [CharacterButton] = []
    
    var characterIdentifierRelay = PublishRelay<String>()
    
    init() {
        super.init(frame: .zero)
        
        setupScrollView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        scrollView.addGestureRecognizer(panGesture)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        CharacterDTO.allCases.enumerated().forEach { index, character in
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
        
        scrollView.contentInset = .init(top: 0,
                                        left: (self.bounds.width - Metric.buttonWidth) / 2,
                                        bottom: 0,
                                        right: (self.bounds.width - Metric.buttonWidth) / 2)
    }
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(introduceLabel)
        addSubview(scrollView)
        addSubview(detailInformationLabel)
        addSubview(nextButton)
        
        scrollView.addSubview(contentView)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp.bottom).offset(53)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Metric.buttonHeight)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        detailInformationLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(34)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Metric.nextButtonBottomPadding)
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
    
    private func deselectAllButtons() {
        self.allCharacterButtons
            .forEach { $0.isSelected = false }
    }
}

extension ChoosingCharacterView {
    func hideAllComponents() {
        subviews.filter { $0 != gradientView }
            .forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: subviews.filter { $0 != gradientView }.map {Animation(view: $0, animationCase: .fadeIn, duration: 1.0)}, mode: .parallel, loop: .once(completion: { continuation.resume() }))
                .run()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: subviews.map { Animation(view: $0, animationCase: .fadeOut, duration: 1.0)}, mode: .parallel, loop: .once(completion: { continuation.resume() }))
                .run()
        }
    }
}

extension ChoosingCharacterView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

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
        
        characterIdentifierRelay.accept(allCharacterButtons[page].identifier)
        scrollView.setContentOffset(CGPoint(x: CGFloat(page) * pageWidth - inset,
                                            y: 0),
                                    animated: true)
    }
}
