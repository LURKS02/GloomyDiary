//
//  ViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/1/24.
//

import UIKit
import Lottie
import SnapKit
import ComposableArchitecture

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background(.mainPurple)
        
        let testLabel = UILabel()
        testLabel.text = "안녕하세요!"
        testLabel.textColor = .white
        testLabel.font = .무궁화.title
        
        view.addSubview(testLabel)
        
        testLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }


}

