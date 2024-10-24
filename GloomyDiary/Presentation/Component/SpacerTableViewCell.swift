//
//  SpacerTableViewCell.swift
//  GloomyDiary
//
//  Created by 디해 on 10/17/24.
//

import UIKit

final class SpacerTableViewCell: UITableViewCell { }

extension SpacerTableViewCell: TableViewConfigurationBindable {
    func bind(with configuration: TableViewCellConfigurable) {
        guard let configuration = configuration as? SpacerTableViewCellConfiguration else { return }
        let spacing = configuration.spacing
        
        self.snp.remakeConstraints { make in
            make.height.equalTo(spacing)
        }
    }
}
