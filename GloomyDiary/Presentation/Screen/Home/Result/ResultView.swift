//
//  ResultView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import UIKit

final class ResultView: UIView {
    
    lazy var validResultView = ValidResultView()
    
    lazy var errorResultView = ErrorResultView()
    
    func showValidResult() {
        addSubview(validResultView)
        
        validResultView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func showErrorResult() {
        addSubview(errorResultView)
        
        errorResultView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func playShowingValidResult(duration: TimeInterval) async {
        await validResultView.playAllComponentsFadeIn(duration: duration)
    }
    
    func playShowingErrorResult(duration: TimeInterval) async {
        await errorResultView.playAllComponentsFadeIn(duration: duration)
    }
    
    func playHidingValidResult(duration: TimeInterval) async {
        await validResultView.playAllComponentsFadeOut(duration: duration)
    }
    
    func playHidingErrorResult(duration: TimeInterval) async {
        await errorResultView.playAllComponentsFadeOut(duration: duration)
    }
}
