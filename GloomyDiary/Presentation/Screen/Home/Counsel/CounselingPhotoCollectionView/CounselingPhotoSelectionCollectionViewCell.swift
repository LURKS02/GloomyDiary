//
//  CounselingPhotoSelectionCollectionViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 12/18/24.
//

import UIKit

final class CounselingPhotoSelectionCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CounselingPhotoSelectionCell"
    
    private let backgroundColorView = UIView().then {
        $0.backgroundColor = .component(.buttonPurple)
        $0.applyCornerRadius(10)
    }
    
    private let containerView = UIView().then {
        $0.isUserInteractionEnabled = false
    }
    
    private let photoIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "camera.fill")
        $0.tintColor = .text(.subHighlight)
    }
    
    private let countLabel = IntroduceLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
    }
    
    private func addSubviews() {
        contentView.addSubview(backgroundColorView)
        backgroundColorView.addSubview(containerView)
        containerView.addSubview(photoIconImageView)
        containerView.addSubview(countLabel)
    }
    
    private func setupConstraints() {
        backgroundColorView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(3)
        }
        
        photoIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(15)
            make.width.equalTo(20)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(photoIconImageView.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension CounselingPhotoSelectionCollectionViewCell {
    func configure(count: Int, maxCount: Int) {
        countLabel.text = "\(count)/\(maxCount)"
        if count == maxCount {
            countLabel.textColor = .text(.warning)
        } else {
            countLabel.textColor = .text(.highlight)
        }
    }
}
