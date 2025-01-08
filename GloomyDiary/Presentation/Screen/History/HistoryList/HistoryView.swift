//
//  HistoryView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import SnapKit

final class HistoryView: BaseView {
    
    // MARK: - Views
    
    let listView = HistoryListView()
    
    let emptyView = EmptyListView()
    
    
    // MARK: - Properties
    
    var showContent: Bool = false {
        didSet {
            if showContent {
                emptyView.alpha = 0.0
                listView.alpha = 1.0
            } else {
                emptyView.alpha = 1.0
                listView.alpha = 0.0
            }
        }
    }
    
    
    // MARK: - View Life Cycle
    
    override func setup() {
        backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(listView)
        addSubview(emptyView)
    }
    
    override func setupConstraints() {
        listView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
