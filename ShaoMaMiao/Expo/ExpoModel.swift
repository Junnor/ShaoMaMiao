//
//  ExpoModel.swift
//  ManZhanMiao
//
//  Created by 赵辉 on 15/10/6.
//  Copyright © 2015年 moelove. All rights reserved.
//

import UIKit

class ExpoModel: NSObject {
    
    //基本信息
    var Cover:String = ""
    var Description:String = ""
    var code_secret:String = ""
    var scan_secret:String = ""
    var secret:String = ""

    var scan_token:String = ""
    
    var StartTime:TimeInterval = 0
    var EndTime:TimeInterval = 0
    var PresalePrice:String = "0.0"
    var ScenePrice:String = "0.0"
    var SectionId:Int = 0
    var Name:String = ""
    var Coordinate:String = "0,0"
    var Tag:String!
    var Love:String = "0"
    //状态信息
    var IsTicket:String = "0"
    var IsHot:String = "0"
    
    //地区信息
    var Location:String = ""
    var Addr:String = ""
    var Province:String = ""
    var ProvinceId:Int = 0
    var CityId:Int = 0
    //类型判断
    func SectionName(_ id:Int)->String{
        switch id {
        case 1:
            return "同人展"
        case 2:
            return "动漫游戏"
        case 3:
            return "Cosplay"
        case 4:
            return "演唱会"
        case 5:
            return "音乐会"
        case 6:
            return "展示会"
        case 7:
            return "见面会"
        case 8:
            return "茶 会"
        case 9:
            return "比赛活动"
        default:
            return "其他活动"
        }
    }
}
