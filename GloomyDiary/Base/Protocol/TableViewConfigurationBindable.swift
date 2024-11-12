//
//  TableViewConfigurationBindable.swift
//  GloomyDiary
//
//  Created by 디해 on 10/17/24.
//

import UIKit

protocol TableViewConfigurationBindable: UITableViewCell {
    func bind(with configuration: TableViewCellConfigurable)
}
