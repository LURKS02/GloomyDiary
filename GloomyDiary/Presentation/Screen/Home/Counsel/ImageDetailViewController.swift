//
//  ImageDetailViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 12/19/24.
//

import UIKit

final class ImageDetailViewController: UIViewController {
    private let closeButton = UIButton().then {
        $0.setImage(.init(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .black
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func addSubviews() {
        view.addSubview(closeButton)
        view.addSubview(imageView)
    }
    
    private func setupConstraints() {
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(700)
        }
    }
}
