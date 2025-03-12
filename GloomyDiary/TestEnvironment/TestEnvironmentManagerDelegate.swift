//
//  TestEnvironmentManagerDelegate.swift
//  GloomyDiary
//
//  Created by 디해 on 3/11/25.
//

import Foundation

protocol TestEnvironmentManagerDelegate: AnyObject {
    func didUpdateProcess(_ message: String)
    func didFinishPreparing()
}
