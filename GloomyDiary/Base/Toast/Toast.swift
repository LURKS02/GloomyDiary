//
//  Toast.swift
//  GloomyDiary
//
//  Created by 디해 on 10/14/24.
//

import UIKit

final class Toast {
    private static var toastWindow: UIWindow?
    
    static func show(text: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              toastWindow == nil else { return }
        
        let window = UIWindow(windowScene: scene)
        self.toastWindow = window
        
        window.windowLevel = .alert + 1
        window.rootViewController = UIViewController()
        window.isUserInteractionEnabled = false
        
        let messageLabel = UILabel().then {
            $0.text = text
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textColor = .white
            $0.numberOfLines = 0
            $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
        
        window.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(200)
            
            let estimatedWidth = messageLabel.intrinsicContentSize.width + 25
            let estimatedHeight = messageLabel.intrinsicContentSize.height + 25
            make.width.equalTo(estimatedWidth)
            make.height.equalTo(estimatedHeight)
        }
        
        window.layoutSubviews()
        messageLabel.applyCircularShape()
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard toastWindow != nil && toastWindow == window else { return }
            
            AnimationGroup(animations: [.init(view: messageLabel,
                                              animationCase: .fadeOut,
                                              duration: 1.0)],
                           mode: .parallel,
                           loop: .once(completion: {
                messageLabel.removeFromSuperview()
                toastWindow = nil
            }))
            .run()
        }
    }
}
