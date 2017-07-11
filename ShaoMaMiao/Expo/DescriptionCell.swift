//
//  DescriptionCell.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 16/6/1.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class DescriptionCell: UITableViewCell {

    @IBOutlet weak var LabelContent: UILabel!
    @IBOutlet weak var BtnFeed: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        BtnFeed.setTitleColor(Color.Btnone, for: UIControlState())
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
