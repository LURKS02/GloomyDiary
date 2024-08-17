//
//  TalkingView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class TalkingView: BaseView {
    private struct Matric {
        static let verticalPadding: CGFloat = 18
        static let horizontalPadding: CGFloat = 23
        static let cornerRadius: CGFloat = 20
    }
    
    private let talkingLabel: UILabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .무궁화.title
    }
    
    override func setup() {
        self.backgroundColor = .component(.darkPurple)
        self.layer.cornerRadius = Matric.cornerRadius
        self.layer.masksToBounds = true
    }
    
    override func addSubviews() {
        self.addSubview(talkingLabel)
    }
    
    override func setupConstraints() {
        talkingLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(Matric.verticalPadding)
            make.horizontalEdges.equalToSuperview().inset(Matric.horizontalPadding)
        }
    }
}

extension TalkingView {
    func update(text: String) {
        self.talkingLabel.text = text
    }
}
