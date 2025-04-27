//
//  CounselingPhotoSelectionCollectionViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 12/18/24.
//

import Combine
import UIKit

final class CounselingPhotoSelectionCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CounselingPhotoSelectionCell"
    
    var cancellableSet = Set<AnyCancellable>()
    
    private var count: Int = 0
    private var maxCount: Int = 0
    
    private let backgroundColorView = UIView().then {
        $0.backgroundColor = AppColor.Background.letter.color
        $0.applyCornerRadius(10)
    }
    
    private let containerView = UIView().then {
        $0.isUserInteractionEnabled = false
    }
    
    private let photoIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "camera.fill")
        $0.tintColor = AppColor.Text.subHighlight.color
    }
    
    private let countLabel = NormalLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addSubviews()
        setupConstraints()
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellableSet.removeAll()
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
    
    private func bind() {
        NotificationCenter.default
            .publisher(for: .themeShouldRefresh)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.changeThemeIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
    
    private func changeThemeIfNeeded() {
        backgroundColorView.backgroundColor = AppColor.Background.letter.color
        photoIconImageView.tintColor = AppColor.Text.subHighlight.color
        countLabel.changeThemeIfNeeded()
        
        if count == maxCount {
            countLabel.textColor = AppColor.Text.warning.color
        } else {
            countLabel.textColor = AppColor.Text.main.color
        }
    }
}

extension CounselingPhotoSelectionCollectionViewCell {
    func configure(count: Int, maxCount: Int) {
        self.count = count
        self.maxCount = maxCount
        
        countLabel.text = "\(count)/\(maxCount)"
        if count == maxCount {
            countLabel.textColor = AppColor.Text.warning.color
        } else {
            countLabel.textColor = AppColor.Text.main.color
        }
    }
}
