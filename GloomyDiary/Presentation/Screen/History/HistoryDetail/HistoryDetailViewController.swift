//
//  HistoryDetailViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 10/23/24.
//

import UIKit

final class HistoryDetailViewController: BaseViewController<HistoryDetailView> {
    
    init(session: CounselingSessionDTO) {
        let contentView = HistoryDetailView(session: session)
        super.init(contentView)
        self.hidesBottomBarWhenPushed = true
        self.title = "\(session.createdAt.normalDescription) 상담일지"
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}
