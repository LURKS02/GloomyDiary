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
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        toastWindow = UIWindow(windowScene: scene)
        toastWindow?.windowLevel = .alert + 1
        toastWindow?.rootViewController = UIViewController()
        toastWindow?.isUserInteractionEnabled = false
        
        let messageLabel = UILabel().then {
            $0.text = text
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textColor = .white
            $0.numberOfLines = 0
            $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
        
        toastWindow?.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(200)
            
            let estimatedWidth = messageLabel.intrinsicContentSize.width + 25
            let estimatedHeight = messageLabel.intrinsicContentSize.height + 25
            make.width.equalTo(estimatedWidth)
            make.height.equalTo(estimatedHeight)
        }
        
        toastWindow?.layoutSubviews()
        messageLabel.applyCircularShape()
        
        toastWindow?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
