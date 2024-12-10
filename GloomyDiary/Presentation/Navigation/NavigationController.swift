//
//  NavigationController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/24/24.
//

import Foundation

class NavigationController: BaseNavigationController {
    override func setup() {
        super.setup()
        
        self.backgroundColor = .background(.mainPurple)
        self.font = .온글잎_의연체.body
        self.backButtonColor = .component(.white)
    }
}
