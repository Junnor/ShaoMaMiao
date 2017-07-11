//
//  UserModel.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/11/29.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    //基本信息
    var Uname:String = ""
    var Uid:Int = 0
    var Uavatar:String = ""
    var Sex:Int = 0
    var Intro:String = ""
    var Password:String = ""
    var Status:Int = 0
    //地理位置
    var Country:String = ""
    var Location:String = ""
    var Provnice:String = ""
    var Pid:Int = 0
    var City:String = "未定位"
    var Cid:Int = 0
    var Area:String = ""
    var Aid:Int = 0
    var Coordinate:String = ""
    //积分信息
    var Mcion:String = "0.0"
    var Cion:String = "0"
    var Checkstatus:Int = 0
    var ConNum:String = "0"
    var TotalNum:String = "0"
    var NumFollow:Int = 0
    var NumFollower:Int = 0
    var NumExpoLike:Int = 0
    
    //绑定信息
    var SWThreeType:String = "Nyato"
    var Typeuid:String = ""
    var Token:String = ""
    var OtherFace:String = ""
    var Phone:String = ""
    var RyToken:String = ""
    //收货地址
    var AddressNew:Bool = true
    var RName:String = ""
    var RLocation:String = "地区为空"
    var Tel:String = ""
    var Address:String = ""
    var ZidCode:String = "邮政编码还是空的"
    var AddressId:String = "0"

}
