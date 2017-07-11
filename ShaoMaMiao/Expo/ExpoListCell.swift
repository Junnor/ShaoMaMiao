//
//  ExpoListCell.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 16/6/1.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class ExpoListCell: UITableViewCell {

    @IBOutlet weak var Like: UILabel!
    @IBOutlet weak var LabelType: UILabel!
    @IBOutlet weak var SWThreeType: UIButton!
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var Title: UILabel!
    
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Location: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Like.textColor = Color.Font(2)
        Location.textColor = Color.Font(2)
        Time.textColor = Color.Font(2)
        LabelType.layer.cornerRadius = 3
        LabelType.layer.borderWidth = 1.5
        LabelType.layer.borderColor = Color.Borders.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
