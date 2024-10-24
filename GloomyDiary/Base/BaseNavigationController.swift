//
//  BaseNavigationController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/24/24.
//

import UIKit

class BaseNavigationController: UINavigationController {
    lazy var backButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "chevron.left")
        $0.target = self
        $0.action = #selector(backButtonTapped)
    }
    
    var backButtonColor: UIColor = .white {
        didSet {
            backButton.tintColor = backButtonColor
        }
    }
    
    var backgroundColor: UIColor = .white {
        didSet {
            let appearance = self.navigationBar.standardAppearance
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
            appearance.shadowColor = .clear
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    var font: UIFont = .systemFont(ofSize: 20) {
        didSet {
            let appearance = self.navigationBar.standardAppearance
            appearance.titleTextAttributes = [
                .font: font,
                .foregroundColor: UIColor.text(.highlight)
            ]
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.isEnabled = true
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        viewController.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        self.popViewController(animated: true)
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
