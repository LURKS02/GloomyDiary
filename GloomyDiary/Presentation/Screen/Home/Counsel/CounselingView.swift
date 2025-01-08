//
//  CounselingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import UIKit

final class CounselingView: BaseView {
    
    // MARK: - Metric
    
    enum Metric {
        static let characterSize: CGFloat = .verticalValue(61)
        static let characterImageTopPadding: CGFloat = .verticalValue(90)
        static let characterImageLeadingPadding: CGFloat = .horizontalValue(25)
        static let characterImageTrailingPadding: CGFloat = .horizontalValue(20)
        static let greetingLabelTrailingPadding: CGFloat = .horizontalValue(25)
        static let photoCollectionViewTopPadding: CGFloat = .verticalValue(60)
        static let photoCollectionViewHorizontalPadding: CGFloat = .horizontalValue(21)
        static let photoCollectionViewHeight: CGFloat = 78
        static let sendingLetterTopPadding: CGFloat = .verticalValue(20)
        static let sendingLetterHorizontalPadding: CGFloat = .horizontalValue(17)
        static let sendingLetterBottomPadding: CGFloat = .verticalValue(250)
        static let sendingButtonTopPadding: CGFloat = .verticalValue(25)
    }

    
    // MARK: - Views

    let containerView = UIView()
    
    let characterImageView: ImageView = ImageView().then {
        $0.setSize(Metric.characterSize)
    }
    
    let characterGreetingLabel: IntroduceLabel = IntroduceLabel().then {
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
    
    let sendingLetterView: SendingLetterView = SendingLetterView()
    
    let letterSendingButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("편지 보내기", for: .normal)
        $0.isEnabled = false
    }
    
    let tapGesture = UITapGestureRecognizer().then {
        $0.cancelsTouchesInView = false
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        addGestureRecognizer(tapGesture)
        backgroundColor = .background(.mainPurple)
        characterGreetingLabel.alpha = 0
        sendingLetterView.alpha = 0
        letterSendingButton.alpha = 0
        photoCollectionView.alpha = 0
    }
    
    override func addSubviews() {
        addSubview(containerView)
        
        containerView.addSubview(characterImageView)
        containerView.addSubview(characterGreetingLabel)
        containerView.addSubview(photoCollectionView)
        containerView.addSubview(sendingLetterView)
        containerView.addSubview(letterSendingButton)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metric.characterImageTopPadding)
            make.leading.equalToSuperview().offset(Metric.characterImageLeadingPadding)
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
    func configure(with character: CharacterDTO) {
        characterImageView.setImage(character.imageName)
        characterGreetingLabel.text = character.greetingMessage
    }
}


// MARK: - Animations

extension CounselingView {
    func hideAllComponents() {
        containerView.subviews.forEach { $0.alpha = 0.0 }
    }
    
    @MainActor
    func showAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: characterImageView,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: characterGreetingLabel,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: photoCollectionView,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: sendingLetterView,
                                              animationCase: .fadeIn,
                                              duration: 0.5),
                                        .init(view: letterSendingButton,
                                              animationCase: .fadeIn,
                                              duration: 0.5)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func removeAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: characterGreetingLabel,
                                              animationCase: .fadeOut,
                                              duration: 0.5),
                                        .init(view: sendingLetterView,
                                              animationCase: .fadeOut,
                                              duration: 0.5),
                                        .init(view: letterSendingButton,
                                              animationCase: .fadeOut,
                                              duration: 0.5),
                                        .init(view: photoCollectionView,
                                              animationCase: .fadeOut,
                                              duration: 0.5)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
