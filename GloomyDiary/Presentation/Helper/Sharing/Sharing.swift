//
//  ShareManager.swift
//  GloomyDiary
//
//  Created by 디해 on 12/14/24.
//

import UIKit

enum Sharing {
    static func makeBody(from session: Session) -> String {
        """
        ✉️ \(session.counselor.name)로부터 답장이 도착했어요!

        보낸 내용: \(session.query)

        답장: [\(session.response)]

        \(session.counselor.name)와 더 많은 이야기를 나누고 싶다면 아래 링크를 방문해보세요! 🥳

        https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id6738892165
        """
    }
}
