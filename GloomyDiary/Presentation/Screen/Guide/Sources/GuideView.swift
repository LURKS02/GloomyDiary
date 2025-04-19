//
//  GuideView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/21/24.
//

import UIKit

final class GuideView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let ghostImageSize: CGFloat = .deviceAdjustedWidth(50)
        static let ghostImageTopPadding: CGFloat = .deviceAdjustedHeight(100)
        static let firstLabelTopPadding: CGFloat = .deviceAdjustedHeight(40)
        static let secondLabelTopPadding: CGFloat = .deviceAdjustedHeight(40)
        static let thirdLabelTopPadding: CGFloat = .deviceAdjustedHeight(40)
        static let lastLabelTopPadding: CGFloat = .deviceAdjustedHeight(40)
    }
    
    
    // MARK: - Views
    
    let gradientView = GradientView(
        colors: [
            AppColor.Background.sub.color,
            AppColor.Background.main.color,
            AppColor.Background.main.color
        ]
    )
    
    let ghostView = GhostView()
    
    private let firstNormalLabel = NormalLabel().then {
        $0.text = """
        안녕?
        만나서 반가워!
        화면을 눌러봐.
        """
    }
    
    private let secondNormalLabel = NormalLabel().then {
        $0.text = """
        "울다"는
        우리가 함께
        만들어가는 다이어리야.
        """
    }
    
    private let thirdNormalLabel = NormalLabel().then {
        $0.text = """
        너의 일상을 적은 편지를
        동물 친구들에게 보낼 수 있어.

        좋은 일이나, 슬픈 일.
        고민이나 걱정거리도 좋아.
        네 이야기가 듣고 싶어!
        """
    }
    
    private let lastNormalLabel = NormalLabel().then {
        $0.text = """
        앗, 친구들이
        기다리고 있나봐!

        첫 번째 편지를
        보내러 가볼까?
        """
    }
    
    
    // MARK: - Properties
    
    var labels: [UIView] {
        subviews.exclude(
            ghostView,
            gradientView
        )
    }
    
    private var labelAnimations: [Animation] {
        labels.map {
            Animation(
                view: $0,
                animationCase: .fadeIn,
                duration: 0.5
            )
        }
    }
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
        
        hideAllLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        backgroundColor = AppColor.Background.main.color
    }
    
    private func addSubviews() {
        addSubview(gradientView)
        addSubview(ghostView)
        addSubview(firstNormalLabel)
        addSubview(secondNormalLabel)
        addSubview(thirdNormalLabel)
        addSubview(lastNormalLabel)
    }
    
    private func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        ghostView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.ghostImageTopPadding)
            make.height.equalTo(Metric.ghostImageSize)
            make.width.equalTo(Metric.ghostImageSize)
        }
        
        firstNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ghostView.snp.bottom).offset(Metric.firstLabelTopPadding)
        }
        
        secondNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstNormalLabel.snp.bottom).offset(Metric.secondLabelTopPadding)
        }
        
        thirdNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondNormalLabel.snp.bottom).offset(Metric.thirdLabelTopPadding)
        }
        
        lastNormalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(thirdNormalLabel.snp.bottom).offset(Metric.lastLabelTopPadding)
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
        guard index < labelAnimations.count else { return }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [labelAnimations[index]],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            )
            .run()
        }
    }
    
    @MainActor
    func hideAllComponents(duration: TimeInterval) async {
        let animations = subviews.exclude(gradientView)
            .map {
                Animation(view: $0,
                          animationCase: .fadeOut,
                          duration: duration)
            }
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: animations,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() })
            )
            .run()
        }
    }
}
