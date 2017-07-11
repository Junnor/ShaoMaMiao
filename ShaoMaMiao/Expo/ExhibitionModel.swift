//
//  ExhibitionModel.swift
//  ShaoMaMiao
//
//  Created by nyato喵特 on 2017/2/17.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

//漫展信息的Model

class ExhibitionModel: NSObject {

    var ename:String = ""
    var exhibition_id:String = ""
    var id:String = ""
    var secret:String = ""
    var use_count:String = ""

    func writeModelWitDic(dic : NSDictionary) {
        ename = dic.value(forKey: "ename") as! String
        exhibition_id = dic.value(forKey: "exhibition_id") as! String
        id = dic.value(forKey: "id") as! String
        secret = dic.value(forKey: "secret") as! String
        use_count = dic.value(forKey: "use_count") as! String
        
    }
}


