//
//  TicketModel.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/11/29.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class TicketModel: NSObject {

    var Name:String = ""
    var Id:String = "0"
    var TotalNum:String = "0"
    var UsedNum:String = "0"
}
class TicketData:SQLTable {
    var tid = -1
    var time = "0"
    var model = "0"
    var is_used = "0"
    
    //以下的 se_count  usedTime is_used code scode
    var scode = "未标记"
    var code = "--"
    
    //lx加的，原本需求里的
    var tel = "0"
    var use_count = ""
    var usedTime = "0"
    
    
    required init() {
        //对应的数据库表

        super.init()
    }
    
    //设置主键（如果主键叫id的话，这个可以省去,不用覆盖）
    override func primaryKey() -> String {
        return "tid";
    }
    
    required convenience init(tableName:String) {
        self.init()
    }
}
