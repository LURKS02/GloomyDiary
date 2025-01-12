//
//  GuideView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/21/24.
//

import UIKit

final class GuideView: BaseView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let ghostImageSize: CGFloat = .horizontalValue(50)
        static let ghostImageTopPadding: CGFloat = .verticalValue(40)
        static let firstLabelTopPadding: CGFloat = .verticalValue(40)
        static let secondLabelTopPadding: CGFloat = .verticalValue(40)
        static let thirdLabelTopPadding: CGFloat = .verticalValue(40)
        static let lastLabelTopPadding: CGFloat = .verticalValue(40)
    }
    
    let gradientView = GradientView(colors: [.background(.darkPurple), .background(.mainPurple), .background(.mainPurple)])
    
    let ghostImageView: GhostView = GhostView().then {
        $0.setImage("ghost")
        $0.setSize(Metric.ghostImageSize)
    }
    
    let firstIntroduceLabel = IntroduceLabel().then {
        $0.text = """
        안녕?
        만나서 반가워!
        화면을 눌러봐.
        """
    }
    
    let secondIntroduceLabel = IntroduceLabel().then {
        $0.text = """
        "울다"는
        우리가 함께
        만들어가는 다이어리야.
        """
    }
    
    let thirdIntroduceLabel = IntroduceLabel().then {
        $0.text = """
        너의 일상을 적은 편지를
        동물 친구들에게 보낼 수 있어.

        좋은 일이나, 슬픈 일.
        고민이나 걱정거리도 좋아.
        네 이야기가 듣고 싶어!
        """
    }
    
    let lastIntroduceLabel = IntroduceLabel().then {
        $0.text = """
        앗, 친구들이
        기다리고 있나봐!

        첫 번째 편지를
        보내러 가볼까?
        """
    }
    
    
    var labels: [UIView] {
        subviews.filter { $0 != ghostImageView && $0 != gradientView }
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    private var labelAnimations: [Animation] {
        labels.map { Animation(view: $0,
                               animationCase: .fadeIn,
                               duration: 0.5) }
    }
    
    // MARK: - View Life Cycle
    
    override func setup() {
        self.backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(ghostImageView)
        addSubview(firstIntroduceLabel)
        addSubview(secondIntroduceLabel)
        addSubview(thirdIntroduceLabel)
        addSubview(lastIntroduceLabel)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        ghostImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(Metric.ghostImageTopPadding)
        }
        
        firstIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ghostImageView.snp.bottom).offset(Metric.firstLabelTopPadding)
        }
        
        secondIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstIntroduceLabel.snp.bottom).offset(Metric.secondLabelTopPadding)
        }
        
        thirdIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondIntroduceLabel.snp.bottom).offset(Metric.thirdLabelTopPadding)
        }
        
        lastIntroduceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(thirdIntroduceLabel.snp.bottom).offset(Metric.lastLabelTopPadding)
        }
    }
}


// MARK: - Animations

extension GuideView {
    func hideAllLabels() {
        labels.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func runLabelAnimation(index: Int) async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [labelAnimations[index]],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func hideAllComponents() async {
        let animations = subviews.filter { $0 != gradientView }.map { Animation(view: $0,
                                                                                animationCase: .fadeOut,
                                                                                duration: 0.5) }
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: animations,
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}

extension GuideView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        self.isUserInteractionEnabled = false
    }
}
