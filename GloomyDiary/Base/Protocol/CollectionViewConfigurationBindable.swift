//
//  CollectionViewConfigurationBindable.swift
//  GloomyDiary
//
//  Created by 디해 on 12/18/24.
//

import UIKit

protocol CollectionViewConfigurationBindable: UICollectionViewCell {
    func bind(with configuration: CollectionViewCellConfigurable)
}
