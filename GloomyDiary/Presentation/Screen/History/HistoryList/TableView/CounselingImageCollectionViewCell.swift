//
//  CounselingImageCollectionViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 12/19/24.
//

import UIKit

final class CounselingImageCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CounselingImageCell"
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
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
        contentView.applyCornerRadius(10)
        contentView.isUserInteractionEnabled = false
    }
    
    private func addSubviews() {
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}
