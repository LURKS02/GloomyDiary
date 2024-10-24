//
//  SpacerTableViewCellConfiguration.swift
//  GloomyDiary
//
//  Created by 디해 on 10/17/24.
//

import UIKit

struct SpacerTableViewCellConfiguration: TableViewCellConfigurable {
    static var identifier: String = "SpacerTableViewCell"
    
    static var cellType: UITableViewCell.Type = SpacerTableViewCell.self
    
    var spacing: CGFloat
}
