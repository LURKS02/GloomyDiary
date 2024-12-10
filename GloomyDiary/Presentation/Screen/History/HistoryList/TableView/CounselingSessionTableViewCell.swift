//
//  CounselingSessionTableViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import UIKit

final class CounselingSessionTableViewCell: UITableViewCell {

    // MARK: - Metric
    
    private struct Metric {
        static let cellPadding: CGFloat = 25
    }
    
    // MARK: - Component
    
    let titleLabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.font = .온글잎_의연체.heading
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    let stateLabel = UILabel().then {
        $0.textColor = .text(.fogHighlight)
        $0.font = .온글잎_의연체.body
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    let characterImageView = ImageView()
    
    let contentLabel = UILabel().then {
        $0.textColor = .text(.subHighlight)
        $0.font = .온글잎_의연체.title
        $0.textAlignment = .left
        $0.numberOfLines = 4
        $0.contentMode = .topLeft
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.applyCornerRadius(20)
        self.selectionStyle = .none
        self.backgroundColor = .component(.buttonPurple)
    }
    
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(stateLabel)
        contentView.addSubview(characterImageView)
        contentView.addSubview(contentLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.leading.equalToSuperview().offset(Metric.cellPadding)
            make.trailing.equalToSuperview().offset(-Metric.cellPadding)
        }
        
        stateLabel.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(Metric.cellPadding)
        }
        
        characterImageView.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().offset(-Metric.cellPadding)
            make.top.equalToSuperview().offset(Metric.cellPadding)
            make.size.equalTo(37)
        }
        
        contentLabel.snp.remakeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(Metric.cellPadding)
            make.trailing.equalToSuperview().offset(-Metric.cellPadding)
            make.bottom.equalToSuperview().offset(-Metric.cellPadding)
        }
    }
}

extension CounselingSessionTableViewCell: TableViewConfigurationBindable {
    func bind(with configuration: TableViewCellConfigurable) {
        guard let configuration = configuration as? CounselingSessionTableViewCellConfiguration else { return }
        let counselingSessionDTO = configuration.counselingSessionDTO
        
        titleLabel.text = counselingSessionDTO.title
        stateLabel.text = "날씨 \(counselingSessionDTO.weather.name), \(counselingSessionDTO.emoji.description)"
        characterImageView.setImage(counselingSessionDTO.counselor.imageName)
        contentLabel.text = counselingSessionDTO.query
    }
}

extension CounselingSessionTableViewCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.backgroundColor = .component(.buttonSelectedBlue).withAlphaComponent(0.3)
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity.scaledBy(x: 0.97, y: 0.97)),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        self.backgroundColor = .component(.buttonSelectedBlue).withAlphaComponent(0.3)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.backgroundColor = .component(.buttonPurple)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = .component(.buttonPurple)
        
        AnimationGroup.init(animations: [.init(view: self,
                                               animationCase: .transform(transform: .identity),
                                               duration: 0.1)],
                            mode: .parallel,
                            loop: .once(completion: nil))
        .run()
        
    }
}
