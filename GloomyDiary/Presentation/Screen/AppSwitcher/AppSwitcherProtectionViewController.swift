//
//  AppSwitcherProtectionViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 5/1/25.
//

import UIKit

final class AppSwitcherProtectionViewController: UIViewController {
    
    private let imageView = UIImageView().then {
        $0.image = AppImage.Character.ghost(.normal).image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.Background.main.color
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.center.equalToSuperview()
        }
    }
}
