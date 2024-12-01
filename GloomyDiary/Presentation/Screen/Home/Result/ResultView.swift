//
//  ResultView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import UIKit

final class ResultView: BaseView {
    
    let characterImageView: ImageView = ImageView().then {
        $0.setSize(87)
    }
    
    let resultLetterView = ResultLetterView()
    
    let shareButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("공유하기", for: .normal)
        $0.backgroundColor = .component(.blackPurple)
    }
    
    let homeButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("홈으로", for: .normal)
    }
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
        resultLetterView.alpha = 0
        homeButton.alpha = 0
        shareButton.alpha = 0
    }
    
    override func addSubviews() {
        addSubview(characterImageView)
        addSubview(resultLetterView)
        addSubview(shareButton)
        addSubview(homeButton)
    }
    
    override func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(71)
            make.centerX.equalToSuperview()
        }
        
        resultLetterView.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.bottom.equalToSuperview().offset(-218)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(resultLetterView.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
}

extension ResultView {
    func configure(with character: CharacterDTO) {
        characterImageView.setImage(character.imageName)
    }
}


// MARK: - Animations

extension ResultView {
    @MainActor
    func playAllComponentsFadeIn() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: resultLetterView,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: homeButton,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: shareButton,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
    
    @MainActor
    func playAllComponentsFadeOut() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: resultLetterView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: homeButton,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: characterImageView,
                                              animationCase: .fadeOut,
                                              duration: 1.0),
                                        .init(view: shareButton,
                                              animationCase: .fadeOut,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
