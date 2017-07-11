//
//  ExpoListModel.swift
//  ManZhanMiao
//
//  Created by 赵辉 on 15/10/6.
//  Copyright © 2015年 moelove. All rights reserved.
//

import UIKit

class ExpoListModel: NSObject {
    
    //基本信息
    var Cover:String!
    var Description:String!
    var Eid:String!
    var StartTime:String!
    var EndTime:String!
    var PresalePrice:String!
    var ScenePrice:String!
    var SectionId:String!
    var Name:String!
    var Tag:String!
    var Love:String = "0"
    var Status:String = ""
    //状态信息
    var IsTicket:String = "0"
    var IsHot:String = "0"
    //地区信息
    var Location:String!
    var Addr:String!
    var Province:String!
    var City:String!
    var Coordinate:String!
    
    
    
    init(name:String,eid:String,status:String){
        self.Eid = eid
        self.Name = name
        self.Status = status
    }
    
    init(name:String,cover:String,description:String,eid:String,start:String,end:String,addr:String,location:String,section:String,scene:String,presale:String,tag:String,province:String,city:String,coordinate:String,love:String){
        self.Cover = "\(PostURL().ImgURL)\(cover)"
        self.Description = description
        self.Eid = eid
        self.EndTime = end
        self.StartTime = start
        self.ScenePrice = scene
        self.PresalePrice = presale
        self.Location = location
        self.Addr = addr
        self.SectionId = section
        self.Name = name
        self.Tag = tag
        self.Province = province
        self.City = city
        self.Coordinate = coordinate
        self.Love = love
    }
    
    
    
}
