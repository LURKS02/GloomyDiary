//
//  FloatingTabBarControllerDelegate.swift
//  GloomyDiary
//
//  Created by 디해 on 4/20/25.
//

import Foundation

protocol FloatingTabBarControllerDelegate: NSObjectProtocol {
    func tabDidDisappear()
    func tabWillAppear()
}
