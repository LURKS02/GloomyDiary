//
//  TableViewCellConfigurable.swift
//  GloomyDiary
//
//  Created by 디해 on 10/17/24.
//

import UIKit

protocol TableViewCellConfigurable {
    static var identifier: String { get }
    static var cellType: UITableViewCell.Type { get }
}
