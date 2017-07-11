//
//  CodeCell.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/12/9.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class CodeCell: UITableViewCell {

    @IBOutlet weak var Des: UILabel!
    @IBOutlet weak var Names: UILabel!
    @IBOutlet weak var BtnCode: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        BtnCode.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
