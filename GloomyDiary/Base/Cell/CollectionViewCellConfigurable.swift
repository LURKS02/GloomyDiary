//
//  CollectionViewCellConfigurable.swift
//  GloomyDiary
//
//  Created by 디해 on 12/18/24.
//

import UIKit

protocol CollectionViewCellConfigurable {
    static var identifier: String { get }
    static var cellType: UICollectionViewCell.Type { get }
}
