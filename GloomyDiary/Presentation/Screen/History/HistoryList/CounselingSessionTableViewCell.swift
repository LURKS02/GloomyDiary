//
//  CounselingSessionTableViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 10/16/24.
//

import UIKit

final class CounselingSessionTableViewCell: UITableViewCell {
    private let characterImageView = ImageView().then {
        $0.setSize(47)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .text(.highlight)
        $0.font = .무궁화.title
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .text(.subHighlight)
        $0.font = .무궁화.body
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    private lazy var stackView = UIStackView().then {
        $0.addArrangedSubview(titleLabel)
        $0.addArrangedSubview(contentLabel)
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .leading
        $0.spacing = 3
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.applyCornerRadius(20)
    }
    
    private func setup() {
        contentView.backgroundColor = .component(.buttonPurple)
    }
    
    private func addSubviews() {
        contentView.addSubview(characterImageView)
        contentView.addSubview(stackView)
    }
    
    private func setupConstraints() {
        characterImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(19)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(characterImageView.snp.trailing).offset(23)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(11)
            make.bottom.equalToSuperview().inset(19)
        }
    }
}

extension CounselingSessionTableViewCell: TableViewConfigurationBindable {
    func bind(with configuration: TableViewCellConfigurable) {
        guard let configuration = configuration as? CounselingSessionTableViewCellConfiguration else { return }
        let counselingSessionDTO = configuration.counselingSessionDTO
        
        characterImageView.setImage(counselingSessionDTO.counselor.imageName)
        titleLabel.text = "\(counselingSessionDTO.createdAt.normalDescription) 상담일지"
        contentLabel.text = counselingSessionDTO.query
    }
}
