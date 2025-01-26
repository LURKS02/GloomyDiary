//
//  HistoryNavigationController.swift
//  GloomyDiary
//
//  Created by 디해 on 1/27/25.
//

import UIKit

final class HistoryNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = self.navigationBar.standardAppearance
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .component(.buttonPurple)
        appearance.shadowColor = .clear
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        
        self.interactivePopGestureRecognizer?.isEnabled = true
        self.interactivePopGestureRecognizer?.delegate = self
    }
}

extension HistoryNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
