//
//  CounselingPhotoCollectionViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 12/18/24.
//

import UIKit
import RxSwift
import RxRelay

final class CounselingPhotoCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CounselingPhotoCell"
    
    let tapRelay = PublishRelay<Void>()
    let removeRelay = PublishRelay<Void>()
    var disposeBag = DisposeBag()
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let removeButton = CancelButton(frame: .zero)
    
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
        disposeBag = DisposeBag()
    }
    
    private func setup() {
        imageView.applyCornerRadius(10)
        
        imageView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.tapRelay.accept(())
            })
            .disposed(by: rx.disposeBag)
        
        removeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.removeRelay.accept(())
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(removeButton)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        removeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(16)
        }
    }
}

extension CounselingPhotoCollectionViewCell { 
    func configure(with image: UIImage, viewController: UIViewController) {
        imageView.image = image
        
        tapRelay.subscribe(onNext: { _ in
            guard let viewController = viewController as? CounselingViewController else { return }
            viewController.openImageViewer(with: url)
        })
        .disposed(by: disposeBag)
        
        removeRelay.subscribe(onNext: { _ in
            guard let viewController = viewController as? CounselingViewController else { return }
            viewController.removeImage(url)
        })
        .disposed(by: disposeBag)
    }
}
