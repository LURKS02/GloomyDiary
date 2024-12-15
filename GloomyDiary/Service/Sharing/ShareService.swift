//
//  ShareManager.swift
//  GloomyDiary
//
//  Created by 디해 on 12/14/24.
//

import UIKit

enum ShareService {
    static func share(character: CharacterDTO, request: String, response: String, in viewController: UIViewController, completion: (() -> Void)? = nil) {
        let textToShare = "✉️ \(character.name)로부터 답장이 도착했어요!\n\n보낸 내용: \(request)\n\n답장: [\(response)]\n\n\(character.name)와 더 많은 이야기를 나누고 싶다면 아래 링크를 방문해보세요! 🥳\n\nhttps://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id6738892165"
        let itemsToShare: [Any] = [textToShare]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            completion?()
        }
        
        viewController.present(activityViewController, animated: true)
    }
}
