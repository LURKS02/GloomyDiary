//
//  CounselingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import UIKit

final class CounselingView: UIView {
    
    // MARK: - Metric
    
    private enum Metric {
        static let characterSize: CGFloat = .deviceAdjustedHeight(61)
        static let characterImageTopPadding: CGFloat = .deviceAdjustedHeight(90)
        static let characterImageLeadingPadding: CGFloat = .deviceAdjustedWidth(25)
        static let characterImageTrailingPadding: CGFloat = .deviceAdjustedWidth(20)
        static let greetingLabelTrailingPadding: CGFloat = .deviceAdjustedWidth(25)
        static let photoCollectionViewTopPadding: CGFloat = .deviceAdjustedHeight(60)
        static let photoCollectionViewHorizontalPadding: CGFloat = .deviceAdjustedWidth(21)
        static let photoCollectionViewHeight: CGFloat = 78
        static let sendingLetterTopPadding: CGFloat = .deviceAdjustedHeight(20)
        static let sendingLetterHorizontalPadding: CGFloat = .deviceAdjustedWidth(17)
        static let sendingLetterBottomPadding: CGFloat = .deviceAdjustedHeight(250)
        static let sendingButtonTopPadding: CGFloat = .deviceAdjustedHeight(25)
    }

    
    // MARK: - Views

    let containerView = UIView()
    
    let characterImageView = UIImageView()
    
    let characterGreetingLabel = NormalLabel().then {
        $0.textAlignment = .left
    }
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 5
        $0.itemSize = .init(width: Metric.photoCollectionViewHeight, height: Metric.photoCollectionViewHeight)
    }
    
    lazy var photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.clipsToBounds = false
        $0.register(CounselingPhotoCollectionViewCell.self, forCellWithReuseIdentifier: CounselingPhotoCollectionViewCell.identifier)
        $0.register(CounselingPhotoSelectionCollectionViewCell.self, forCellWithReuseIdentifier: CounselingPhotoSelectionCollectionViewCell.identifier)
    }
    
    private let rightEdgeView = UIView().then {
        $0.backgroundColor = .background(.mainPurple)
    }
    
    private let leftEdgeView = UIView().then {
        $0.backgroundColor = .background(.mainPurple)
    }
    
    let sendingLetterView: SendingLetterView = SendingLetterView()
    
    let letterSendingButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("편지 보내기", for: .normal)
        $0.isEnabled = false
    }
    
    let tapGesture = UITapGestureRecognizer().then {
        $0.cancelsTouchesInView = false
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        addGestureRecognizer(tapGesture)
        backgroundColor = .background(.mainPurple)
        characterGreetingLabel.alpha = 0
        sendingLetterView.alpha = 0
        letterSendingButton.alpha = 0
        photoCollectionView.alpha = 0
    }
    
    private func addSubviews() {
        addSubview(containerView)
        
        containerView.addSubview(characterImageView)
        containerView.addSubview(characterGreetingLabel)
        containerView.addSubview(photoCollectionView)
        containerView.addSubview(sendingLetterView)
        containerView.addSubview(letterSendingButton)
        containerView.addSubview(rightEdgeView)
        containerView.addSubview(leftEdgeView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.characterImageTopPadding)
            make.leading.equalToSuperview().offset(Metric.characterImageLeadingPadding)
            make.height.equalTo(Metric.characterSize)
            make.width.equalTo(Metric.characterSize)
        }
        
        characterGreetingLabel.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.top)
            make.leading.equalTo(characterImageView.snp.trailing).offset(Metric.characterImageTrailingPadding)
            make.trailing.equalToSuperview().offset(-Metric.greetingLabelTrailingPadding)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(characterGreetingLabel.snp.bottom).offset(Metric.photoCollectionViewTopPadding)
            make.horizontalEdges.equalToSuperview().inset(Metric.photoCollectionViewHorizontalPadding)
            make.height.equalTo(Metric.photoCollectionViewHeight)
        }
        
        rightEdgeView.snp.makeConstraints { make in
            make.top.equalTo(photoCollectionView)
            make.trailing.equalToSuperview()
            make.height.equalTo(Metric.photoCollectionViewHeight)
            make.width.equalTo(Metric.photoCollectionViewHorizontalPadding)
        }
        
        leftEdgeView.snp.makeConstraints { make in
            make.top.equalTo(photoCollectionView)
            make.leading.equalToSuperview()
            make.height.equalTo(Metric.photoCollectionViewHeight)
            make.width.equalTo(Metric.photoCollectionViewHorizontalPadding)
        }
        
        sendingLetterView.snp.makeConstraints { make in
            make.top.equalTo(photoCollectionView.snp.bottom).offset(Metric.sendingLetterTopPadding)
            make.leading.equalToSuperview().offset(Metric.sendingLetterHorizontalPadding)
            make.trailing.equalToSuperview().offset(-Metric.sendingLetterHorizontalPadding)
            make.bottom.equalToSuperview().offset(-Metric.sendingLetterBottomPadding)
        }
        
        letterSendingButton.snp.makeConstraints { make in
            make.top.equalTo(sendingLetterView.snp.bottom).offset(Metric.sendingButtonTopPadding)
            make.centerX.equalToSuperview()
        }
    }
}

extension CounselingView {
    func configure(with character: CounselingCharacter) {
        characterImageView.image = UIImage(named: character.imageName)
        characterGreetingLabel.text = character.greetingMessage
    }
    
    func updateTextState(
        currentTextCount: Int,
        totalTextCount: Int,
        state: SendingTextState
    ) {
        sendingLetterView.letterCharacterCountLabel.text = "\(currentTextCount)/\(totalTextCount)"
        sendingLetterView.updateConfiguration(state: state)
        updateSendable(state: state)
    }
    
    private func updateSendable(state: SendingTextState) {
        switch state {
        case .max:
            letterSendingButton.isEnabled = false
        case .empty:
            letterSendingButton.isEnabled = false
        case .sendable:
            letterSendingButton.isEnabled = true
        }
    }
}


// MARK: - Animations

extension CounselingView {
    func hideAllComponents() {
        containerView.subviews.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func playFadeInAllComponents(duration: TimeInterval) async {
        characterImageView.alpha = 0.0
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: [
                    Animation(view: characterImageView,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: characterGreetingLabel,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: photoCollectionView,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: sendingLetterView,
                              animationCase: .fadeIn,
                              duration: duration),
                    Animation(view: letterSendingButton,
                              animationCase: .fadeIn,
                              duration: duration)
                ],
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playFadeOutAllComponents(duration: TimeInterval) async {
        let animations = [
            Animation(view: characterGreetingLabel,
                      animationCase: .fadeOut,
                      duration: duration),
            Animation(view: sendingLetterView,
                      animationCase: .fadeOut,
                      duration: duration),
            Animation(view: letterSendingButton,
                      animationCase: .fadeOut,
                      duration: duration),
            Animation(view: photoCollectionView,
                      animationCase: .fadeOut,
                      duration: duration)
        ]
        
        await withCheckedContinuation { continuation in
            AnimationGroup(
                animations: animations,
                mode: .parallel,
                loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
