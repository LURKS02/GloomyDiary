//
//  SessionConfigurable.swift
//  GloomyDiary
//
//  Created by 디해 on 10/17/24.
//

import UIKit

struct CounselingSessionTableViewCellConfiguration: TableViewCellConfigurable {
    static var identifier: String = "CounselingSessionTableViewCell"
    
    static var cellType: UITableViewCell.Type = CounselingSessionTableViewCell.self
    
    var counselingSessionDTO: CounselingSessionDTO
}
