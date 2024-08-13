//
//  ImageView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

final class ImageView: BaseView {
    private let imageView = UIImageView()
    
    private let size: CGFloat
    
    init(imageName: String, size: CGFloat) {
        self.size = size
        super.init(frame: .zero)
        imageView.image = UIImage(named: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubviews() {
        addSubview(imageView)
    }
    
    override func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(size)
            make.width.equalTo(size)
        }
    }
}
