//
//  ReviewView.swift
//  GloomyDiary
//
//  Created by 디해 on 11/27/24.
//

import UIKit

final class ReviewView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let sheetHeight: CGFloat = .deviceAdjustedHeight(450)
        static let cornerRadius: CGFloat = .deviceAdjustedHeight(30)
        static let characterSize: CGFloat = .deviceAdjustedHeight(80)
        static let characterImageTopPadding: CGFloat = .deviceAdjustedHeight(40)
        static let reviewLabelTopPadding: CGFloat = .deviceAdjustedHeight(25)
        static let buttonStackViewTopPadding: CGFloat = .deviceAdjustedHeight(45)
        static let buttonStackViewHorizontalPadding: CGFloat = .deviceAdjustedWidth(40)
    }

    
    // MARK: - Views
    
    let blurView = UIVisualEffectView()
    
    let sheetBackgroundView = UIView().then {
        $0.backgroundColor = .background(.mainPurple)
        $0.layer.cornerRadius = Metric.cornerRadius
    }
    
    let characterImageView = UIImageView()
    
    let reviewLabel = NormalLabel()
    
    let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.distribution = .fillEqually
    }
    
    let acceptButton = HorizontalButton().then {
        $0.setTitle("별점 주기", for: .normal)
    }
    
    let rejectButton = HorizontalButton().then {
        $0.setTitle("거절하기", for: .normal)
        $0.setTitleColor(.text(.buttonSubHighlight), for: .normal)
        $0.backgroundColor = .component(.buttonDisabledPurple)
    }
    
    
    // MARK: - Initialize
    
    init(character: CounselingCharacter) {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
        
        configure(with: character)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with character: CounselingCharacter) {
        characterImageView.image = UIImage(named: character.imageName)
        reviewLabel.text = character.reviewRequiringMessage
    }
    
    
    // MARK: - View Life Cycle
    
    private func addSubviews() {
        addSubview(blurView)
        addSubview(sheetBackgroundView)
        sheetBackgroundView.addSubview(characterImageView)
        sheetBackgroundView.addSubview(reviewLabel)
        sheetBackgroundView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(rejectButton)
        buttonStackView.addArrangedSubview(acceptButton)
    }

    private func setupConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sheetBackgroundView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(Metric.sheetHeight)
            make.height.equalTo(Metric.sheetHeight)
        }
        
        characterImageView.snp.makeConstraints { make in
            make.width.equalTo(Metric.characterSize)
            make.height.equalTo(Metric.characterSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.characterImageTopPadding)
        }
        
        reviewLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(characterImageView.snp.bottom).offset(Metric.reviewLabelTopPadding)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(reviewLabel.snp.bottom).offset(Metric.buttonStackViewTopPadding)
            make.horizontalEdges.equalToSuperview().inset(Metric.buttonStackViewHorizontalPadding)
        }
    }
}

extension ReviewView {
    @MainActor
    func runAppearanceAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: blurView,
                                              animationCase: .custom(closure: { view in
                guard let view = view as? UIVisualEffectView else { return }
                view.effect = UIBlurEffect(style: .dark)
            }),
                                              duration: 0.3),
                                        .init(view: sheetBackgroundView,
                                              animationCase: .transform( .identity.translatedBy(x: 0, y: -Metric.sheetHeight)),
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func runDismissAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: blurView,
                                              animationCase: .custom(closure: { view in
                guard let view = view as? UIVisualEffectView else { return }
                view.effect = nil
            }), duration: 0.3),
                                        .init(view: sheetBackgroundView,
                                              animationCase: .transform( .identity),
                                              duration: 0.2)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
