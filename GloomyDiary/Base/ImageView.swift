//
//  ImageView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/13/24.
//

import UIKit

class ImageView: BaseView {
    private let imageView = UIImageView()
    
    override func addSubviews() {
        addSubview(imageView)
    }
    
    override func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.width.equalTo(0)
        }
    }
}

extension ImageView {
    func setImage(_ name: String) {
        imageView.image = UIImage(named: name)
    }
    
    func setSize(_ size: CGFloat) {
        self.snp.updateConstraints { make in
            make.height.equalTo(size)
            make.width.equalTo(size)
        }
    }
}
