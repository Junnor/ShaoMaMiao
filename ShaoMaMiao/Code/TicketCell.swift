//
//  TicketCell.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/11/29.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class TicketCell: UITableViewCell {

    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Select: UILabel!
    @IBOutlet weak var BtnUpdata: UIButton!
    @IBOutlet weak var BtnSave: UIButton!
    @IBOutlet weak var Des: UILabel!
    @IBOutlet weak var Name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        BtnUpdata.backgroundColor = UIColor.white
        BtnUpdata.layer.borderColor = Color.Borders.cgColor
        BtnUpdata.layer.borderWidth = 1
        BtnUpdata.setTitleColor(Color.Font(1), for: UIControlState())
        BtnUpdata.isHidden = true
        
        BtnSave.backgroundColor = Color.Bg
        BtnSave.layer.borderColor = Color.Borders.cgColor
        BtnSave.layer.borderWidth = 1
        BtnSave.setTitleColor(Color.Font(1), for: UIControlState())
        BtnSave.isHidden = true
        
        Select.layer.shouldRasterize = true
        Select.layer.rasterizationScale = UIScreen.main.scale
        Select.layer.cornerRadius = 12
        Select.layer.borderColor = Color.Font(2).cgColor
        Select.layer.borderWidth = 1
        Select.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
