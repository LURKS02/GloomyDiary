//
//  CounselingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/28/24.
//

import UIKit

final class CounselingView: BaseView {
    
    let characterImageView: ImageView = ImageView().then {
        $0.setSize(61)
    }
    
    let characterGreetingLabel: IntroduceLabel = IntroduceLabel().then {
        $0.textAlignment = .left
    }
    
    let counselLetterView: CounselLetterView = CounselLetterView(state: .notStarted)
    
    let letterSendingButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("편지 보내기", for: .normal)
        $0.isEnabled = false
    }
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
        characterGreetingLabel.alpha = 0
        counselLetterView.alpha = 0
        letterSendingButton.alpha = 0
    }
    
    override func addSubviews() {
        addSubview(characterImageView)
        addSubview(characterGreetingLabel)
        addSubview(counselLetterView)
        addSubview(letterSendingButton)
    }
    
    override func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(90)
            make.leading.equalToSuperview().offset(25)
        }
        
        characterGreetingLabel.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.top)
            make.leading.equalTo(characterImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-25)
        }
        
        counselLetterView.snp.makeConstraints { make in
            make.top.equalTo(characterGreetingLabel.snp.bottom).offset(70)
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.bottom.equalToSuperview().offset(-250)
        }
        
        letterSendingButton.snp.makeConstraints { make in
            make.top.equalTo(counselLetterView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
    }
}

extension CounselingView {
    func configure(with character: Character) {
        characterImageView.setImage(character.imageName)
        characterGreetingLabel.text = character.greetingMessage
    }
    
    func activateEditing() {
        counselLetterView.state = .inProgress
    }
}


// MARK: - Animations

extension CounselingView {
    @MainActor
    func showAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: characterGreetingLabel,
                                              animationCase: .fadeIn,
                                              duration: 1.5),
                                        .init(view: counselLetterView,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: letterSendingButton,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func removeAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: characterImageView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: characterGreetingLabel,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: counselLetterView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: letterSendingButton,
                                              animationCase: .fadeOut,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
