//
//  ResultView.swift
//  GloomyDiary
//
//  Created by 디해 on 9/19/24.
//

import UIKit

final class ResultView: BaseView {
    
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
    
    func animateValidResult() async {
        await validResultView.playAllComponentsFadeIn()
    }
    
    func animateErrorResult() async {
        await errorResultView.playAllComponentsFadeIn()
    }
}
