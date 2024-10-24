//
//  QueryHistoryLetterView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class QueryHistoryLetterView: LetterView {
    
    // MARK: - View Life Cycle
    
    override func setup() {
        super.setup()
        
        letterTextView.isEditable = false
        letterTextView.isScrollEnabled = false
        backgroundColor = .component(.fogPurple)
    }
}

extension QueryHistoryLetterView {
    func configure(with query: String) {
        letterTextView.text = query
    }
}
