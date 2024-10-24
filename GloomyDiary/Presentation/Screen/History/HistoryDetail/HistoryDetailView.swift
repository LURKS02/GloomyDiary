//
//  HistoryDetailView.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class HistoryDetailView: BaseView {
    
    // MARK: - Views

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let letterImageView = ImageView().then {
        $0.setImage("letter")
        $0.setSize(45)
    }
    
    private let queryLetterView = QueryHistoryLetterView()
    
    private let responseLetterView = ResponseHistoryLetterView()
    
    
    // MARK: - Initialize
    
    init(session: CounselingSessionDTO) {
        super.init(frame: .zero)
        
        queryLetterView.configure(with: session.query)
        responseLetterView.configure(with: session.counselor, response: session.response)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle

    override func setup() {
        backgroundColor = .background(.mainPurple)
    }
    
    override func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(letterImageView)
        contentView.addSubview(queryLetterView)
        contentView.addSubview(responseLetterView)
    }
    
    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        letterImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        queryLetterView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.top.equalTo(letterImageView.snp.bottom).offset(10)
        }
        
        responseLetterView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.top.equalTo(queryLetterView.snp.bottom).offset(17)
            make.bottom.equalToSuperview().offset(-17)
        }
    }
}

