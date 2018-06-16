//
//  NewsCell.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import UIKit
import SwipeCellKit

class NewsCell: SwipeTableViewCell {

    @IBOutlet weak var lblAuthorDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
