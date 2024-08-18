//
//  HomeView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit

final class HomeView: BaseView {
    struct Matric {
        static let moonTopPadding: CGFloat = 132
        static let ghostButtonPadding: CGFloat = 65
        static let buttonBottomPadding: CGFloat = 266
        
        static let ghostTalkingSpacing: CGFloat = 14
        static let ghostTalkingRightPadding: CGFloat = 23
        static let ghostImageRightPadding: CGFloat = 119
        
        static let moonImageSize: CGFloat = 43
        static let ghostImageSize: CGFloat = 78
    }
    
    let gradientView: GradientView = GradientView(colors: [.background(.darkPurple),
                                                           .background(.mainPurple),
                                                           .background(.mainPurple)])
    
    let moonImageView = ImageView(imageName: "moon",
                                  size: Matric.moonImageSize)
    
    let ghostImageView = ImageView(imageName: "ghost",
                                   size: Matric.ghostImageSize)
    
    let talkingView: TalkingView = TalkingView().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    let startButton = ButtonView(text: "상담하기")
    
    override func setup() {
        super.setup()
    }
    
    override func addSubviews() {
        addSubview(gradientView)
        addSubview(moonImageView)
        addSubview(talkingView)
        addSubview(ghostImageView)
        addSubview(startButton)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moonImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Matric.moonTopPadding)
        }
        
        talkingView.snp.makeConstraints { make in
            make.bottom.equalTo(ghostImageView.snp.top).offset(-Matric.ghostTalkingSpacing)
            make.right.equalTo(ghostImageView.snp.right).offset(-Matric.ghostTalkingRightPadding)
        }
        
        ghostImageView.snp.makeConstraints { make in
            make.bottom.equalTo(startButton.snp.top).offset(-Matric.ghostButtonPadding)
            make.right.equalToSuperview().offset(-Matric.ghostImageRightPadding)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Matric.buttonBottomPadding)
        }
    }
}
