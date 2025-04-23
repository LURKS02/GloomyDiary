//
//  HistoryView.swift
//  GloomyDiary
//
//  Created by 디해 on 8/5/24.
//

import UIKit
import SnapKit

final class HistoryView: UIView {
    
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
    
    init() {
        super.init(frame: .zero)
        
        setup()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    private func setup() {
        backgroundColor = AppColor.Background.main.color
    }
    
    private func addSubviews() {
        addSubview(listView)
        addSubview(emptyView)
    }
    
    private func setupConstraints() {
        listView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func themeChanged(with theme: AppearanceMode) {
        backgroundColor = AppColor.Background.main.color(for: theme)
        listView.themeChanged(with: theme)
        emptyView.themeChanged(with: theme)
    }
}
