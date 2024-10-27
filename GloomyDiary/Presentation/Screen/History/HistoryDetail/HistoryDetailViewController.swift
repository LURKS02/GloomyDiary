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
        self.title = "\(session.createdAt.normalDescription) 상담일지"
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task { @MainActor in
            guard let tabBarController = tabBarController as? CircularTabBarControllable else { return }
            await tabBarController.hideCircularTabBar(duration: 0.3)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}
