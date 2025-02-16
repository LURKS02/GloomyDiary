//
//  FeatureAction.swift
//  GloomyDiary
//
//  Created by 디해 on 2/2/25.
//

import Foundation

protocol FeatureAction {
    associatedtype ViewAction
    associatedtype InnerAction
    associatedtype ScopeAction
    associatedtype DelegateAction
    
    static func view(_: ViewAction) -> Self
    
    static func inner(_: InnerAction) -> Self
    
    static func scope(_: ScopeAction) -> Self
    
    static func delegate(_: DelegateAction) -> Self
}
