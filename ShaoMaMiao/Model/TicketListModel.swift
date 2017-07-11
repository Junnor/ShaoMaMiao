//
//  TicketListModel.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/11/29.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class TicketListModel: NSObject {

    var Name:String = ""
    var Id:Int = 0
    var TotalNum:Int = 0
    var UsedNum:Int = 0
    init(name:String,id:Int,total:Int?,used:Int) {
        self.Name = "\(name)"
        self.Id = id
        if total != nil {
            self.TotalNum = total!
        }
        self.UsedNum = used
    }

}
