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
    
    let counselLetterView: CounselLetterView = CounselLetterView(state: .completed)
    
    let diaryWritingButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("다이어리 작성하기", for: .normal)
        $0.isEnabled = false
    }
    
    let homeButton: HorizontalButton = HorizontalButton().then {
        $0.setTitle("홈으로", for: .normal)
        $0.isEnabled = false
    }
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
        counselLetterView.alpha = 0
        diaryWritingButton.alpha = 0
        homeButton.alpha = 0
    }
    
    override func addSubviews() {
        addSubview(characterImageView)
        addSubview(counselLetterView)
        addSubview(diaryWritingButton)
        addSubview(homeButton)
    }
    
    override func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(71)
            make.centerX.equalToSuperview()
        }
        
        counselLetterView.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.bottom.equalToSuperview().offset(-218)
        }
        
        diaryWritingButton.snp.makeConstraints { make in
            make.top.equalTo(counselLetterView.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints { make in
            make.top.equalTo(diaryWritingButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
}

extension ResultView {
    func configure(with character: Character) {
        characterImageView.setImage(character.imageName)
        counselLetterView.state = .completed
    }
}


// MARK: - Animations

extension ResultView {
    @MainActor
    func showAllComponents() async {
        await withCheckedContinuation { continuation in
            AnimationGroup(animations: [.init(view: counselLetterView,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: diaryWritingButton,
                                              animationCase: .fadeIn,
                                              duration: 1.0),
                                        .init(view: homeButton,
                                              animationCase: .fadeIn,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: { continuation.resume() }))
            .run()
        }
    }
}
