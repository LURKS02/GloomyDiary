//
//  HistoryDetailView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class HistoryDetailView: BaseView {
    
    // MARK: - Metric

    private struct Metric {
        static let textPadding: CGFloat = 25
        static let viewPadding: CGFloat = 17
    }
    
    
    // MARK: - Views

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let titleLabel = IntroduceLabel().then {
        $0.font = .온글잎_의연체.heading
        $0.textAlignment = .left
    }
    
    private let dateLabel = IntroduceLabel().then {
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .left
    }
    
    private let stateLabel = IntroduceLabel().then {
        $0.font = .온글잎_의연체.body
        $0.textColor = .text(.fogHighlight)
        $0.textAlignment = .left
    }
    
    let imageScrollView = HistoryDetailImageView()
    
    private let contentLabel = IntroduceLabel().then {
        $0.textColor = .text(.subHighlight)
        $0.textAlignment = .left
    }
    
    private let letterImageView = ImageView().then {
        $0.setImage("letter")
        $0.setSize(45)
    }
    
    private let responseLetterView = ResponseHistoryLetterView()
    
    private lazy var gradientBackgroundView = GradientView(colors: [.component(.buttonPurple).withAlphaComponent(0.0), .component(.buttonPurple)],
                                                           locations: [0.0, 0.5, 1.0])
    
    var isAnimated: Bool = false
    
    
    // MARK: - View Life Cycle

    override func setup() {
        backgroundColor = .component(.buttonPurple)
    }
    
    override func addSubviews() {
        addSubview(scrollView)
        addSubview(gradientBackgroundView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(stateLabel)
        contentView.addSubview(imageScrollView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(responseLetterView)
    }
    
    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        gradientBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(CGFloat.verticalValue(70))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(Metric.textPadding)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(Metric.textPadding)
        }
        
        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(Metric.textPadding)
        }
        
        imageScrollView.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(Metric.viewPadding)
            make.height.equalTo(UIView.screenWidth - Metric.viewPadding * 2)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(imageScrollView.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(Metric.textPadding)
        }
        
        responseLetterView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(Metric.viewPadding)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
}

extension HistoryDetailView {
    func configure(with session: CounselingSessionDTO) {
        titleLabel.text = session.title
        dateLabel.text = session.createdAt.normalDescription
        stateLabel.text = "날씨 \(session.weather.name), \(session.emoji.description)"
        contentLabel.text = session.query
        responseLetterView.configure(with: session.counselor, response: session.response)
        gradientBackgroundView.alpha = 0.0
        
        if session.urls.isEmpty {
            contentLabel.snp.remakeConstraints { make in
                make.top.equalTo(stateLabel.snp.bottom).offset(40)
                make.horizontalEdges.equalToSuperview().inset(Metric.textPadding)
            }
            
            imageScrollView.removeFromSuperview()
        } else {
            imageScrollView.configure(with: session.urls)
        }
    }
    
    func makeScrollViewOffsetConstraints(offset: CGFloat) {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(offset)
        }
        layoutIfNeeded()
    }
}

extension HistoryDetailView {
    func hideAllComponents() {
        scrollView.alpha = 0.0
    }
    
    @MainActor
    func playFadeInAllComponents() async {
        contentView.subviews.forEach { $0.alpha = 0.0 }
        contentView.subviews.forEach { $0.transform = .identity.translatedBy(x: 0, y: 40) }
        
        async let subviewsAnimation: () = await playFadeInSubviews()
        async let gradientViewAnimation: () = await playFadeInGradientView()
        
        let _ = await (subviewsAnimation, gradientViewAnimation)
    }
    
    @MainActor
    func playFadeInGradientView() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: gradientBackgroundView,
                                              animationCase: .fadeIn,
                                              duration: 0.4)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeInSubviews() async {
        await withCheckedContinuation { continuation in
            contentView.subviews.enumerated().forEach { index, _ in
                let isLast = (index == contentView.subviews.count - 1)
                animateSubview(at: index) {
                    if isLast { continuation.resume() }
                }
            }
        }
    }
    
    private func animateSubview(at index: Int, completion: @escaping () -> Void = {}) {
        guard index < contentView.subviews.count else { return completion() }
        
        let view = contentView.subviews[index]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
            AnimationGroup(animations: [.init(view: view,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: view,
                                              animationCase: .transform(transform: .identity),
                                              duration: 0.5)],
                           mode: .parallel,
                           loop: .once(completion: completion))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: scrollView,
                                              animationCase: .fadeOut,
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
