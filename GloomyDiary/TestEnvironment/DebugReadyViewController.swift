//
//  DebugReadyViewController.swift
//  GloomyDiary
//
//  Created by 디해 on 12/22/24.
//

import UIKit

final class DebugReadyViewController: UIViewController {
    
    private let label = UILabel().then {
        $0.text = "디버그 세팅 준비 중 ..."
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension DebugReadyViewController: TestEnvironmentManagerDelegate {
    func didUpdateProcess(_ message: String) {
        Task {
            await MainActor.run {
                label.text = message
            }
        }
    }
    
    func didFinishPreparing() {
        Task {
            await MainActor.run {
                self.dismiss(animated: false)
            }
        }
    }
}
