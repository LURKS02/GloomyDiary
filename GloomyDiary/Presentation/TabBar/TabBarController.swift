//
//  TabBarViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit

class TabBarController: BaseTabBarController {
    override func setup() {
        super.setup()
        
        self.backgroundColor = .component(.darkPurple)
        self.selectedFontColor = .text(.highlight)
        self.normalFontColor = .text(.dark)
        self.font = .무궁화.tabBar
        self.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: 1, right: 0)
    }
}
