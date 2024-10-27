//
//  Dismissable.swift
//  GloomyDiary
//
//  Created by 디해 on 10/27/24.
//

import UIKit

protocol Dismissable: UIViewController {
    func playDismissingAnimation() async
}
