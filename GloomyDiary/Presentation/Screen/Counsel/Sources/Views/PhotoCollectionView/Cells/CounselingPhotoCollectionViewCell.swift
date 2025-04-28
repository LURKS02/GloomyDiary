//
//  CounselingPhotoCollectionViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 12/18/24.
//

import Combine
import CombineCocoa
import UIKit

protocol CounselingPhotoCellDelegate: AnyObject {
    func openImageViewer(with image: UIImage)
    func removeSelection(_ id: UUID)
}

final class CounselingPhotoCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CounselingPhotoCell"
    
    let imageTapPublisher = PassthroughSubject<Void, Never>()
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let removeButton = CancelButton(frame: .zero)
    
    private var imageTap = UITapGestureRecognizer()
    
    weak var delegate: CounselingPhotoCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        delegate = nil
    }
    
    private func setup() {
        imageView.addGestureRecognizer(imageTap)
        imageView.applyCornerRadius(10)
    }
    
    private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(removeButton)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(11)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(11)
            make.bottom.equalToSuperview()
        }
        
        removeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(22)
            make.width.equalTo(22)
        }
    }
}

extension CounselingPhotoCollectionViewCell { 
    func configure(with selection: ImageSelection, delegate: CounselingPhotoCellDelegate) {
        self.delegate = delegate
        self.imageView.image = selection.thumbnailImage
        self.imageView.addGestureRecognizer(imageTap)
        
        imageTap.tapPublisher
            .sink { [weak delegate] _ in
                delegate?.openImageViewer(with: selection.image)
            }
            .store(in: &cancellables)
        
        removeButton.tapPublisher
            .sink { [weak delegate] in
                delegate?.removeSelection(selection.uuid)
            }
            .store(in: &cancellables)
    }
}
