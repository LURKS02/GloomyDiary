//
//  DeleteView.swift
//  GloomyDiary
//
//  Created by 디해 on 12/15/24.
//

import UIKit

final class DeleteView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let sheetHorizontalPadding: CGFloat = .deviceAdjustedWidth(20)
        static let cornerRadius: CGFloat = .deviceAdjustedHeight(30)
        static let characterSize: CGFloat = .deviceAdjustedHeight(70)
        static let characterTopPadding: CGFloat = .deviceAdjustedHeight(35)
        static let labelTopPadding: CGFloat = .deviceAdjustedHeight(25)
        static let stackViewTopPadding: CGFloat = .deviceAdjustedHeight(25)
        static let stackViewHorizontalPadding: CGFloat = .deviceAdjustedWidth(40)
        static let stackViewBottomPadding: CGFloat = .deviceAdjustedHeight(25)
    }
    
    private var character: CounselingCharacter = .chan
    
    
    // MARK: - Views
    
    let backgroundView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.alpha = 0.0
    }
    
    private let sheetBackgroundView = UIView().then {
        $0.backgroundColor = AppColor.Background.main.color
        $0.layer.cornerRadius = Metric.cornerRadius
        $0.alpha = 0.0
    }
    
    private let characterImageView = UIImageView()
    
    private let notificationLabel = NormalLabel().then {
        $0.text = """
        정말 기록을 삭제할까요?

        삭제한 기록은
        복구할 수 없어요.
        """
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.distribution = .fillEqually
    }
    
    let acceptButton = NormalHorizontalButton().then {
        $0.setTitle("네", for: .normal)
    }
    
    let rejectButton = RejectHorizontalButton().then {
        $0.setTitle("아니오", for: .normal)
    }
    
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupConstraints()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func addSubviews() {
        addSubview(backgroundView)
        addSubview(sheetBackgroundView)
        sheetBackgroundView.addSubview(characterImageView)
        sheetBackgroundView.addSubview(notificationLabel)
        sheetBackgroundView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(acceptButton)
        buttonStackView.addArrangedSubview(rejectButton)
    }

    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sheetBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(Metric.sheetHorizontalPadding)
        }
        
        characterImageView.snp.makeConstraints { make in
            make.width.equalTo(Metric.characterSize)
            make.height.equalTo(Metric.characterSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Metric.characterTopPadding)
        }
        
        notificationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(characterImageView.snp.bottom).offset(Metric.labelTopPadding)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(notificationLabel.snp.bottom).offset(Metric.stackViewTopPadding)
            make.horizontalEdges.equalToSuperview().inset(Metric.stackViewHorizontalPadding)
            make.bottom.equalToSuperview().inset(Metric.stackViewBottomPadding)
        }
    }
}

extension DeleteView {
    func configure(character: CounselingCharacter) {
        self.character = character
        self.characterImageView.image = AppImage.Character.counselor(character, .crying).image
    }
    
    func changeThemeIfNeeded() {
        sheetBackgroundView.backgroundColor = AppColor.Background.main.color
        notificationLabel.changeThemeIfNeeded()
        acceptButton.changeThemeIfNeeded()
        rejectButton.changeThemeIfNeeded()
        characterImageView.image = AppImage.Character.counselor(character, .crying).image
    }
}


// MARK: - Animations

extension DeleteView {
    @MainActor
    func playFadeInAnimation() async {
        sheetBackgroundView.transform = .identity.scaledBy(x: 0.75, y: 0.75)
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: backgroundView,
                              animationCase: .fadeIn,
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .transform( .identity),
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .fadeIn,
                              duration: 0.3)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAnimation() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: backgroundView,
                              animationCase: .fadeOut,
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .transform(.identity.scaledBy(x: 0.75, y: 0.75)),
                              duration: 0.3),
                    Animation(view: sheetBackgroundView,
                              animationCase: .fadeOut,
                              duration: 0.3)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
