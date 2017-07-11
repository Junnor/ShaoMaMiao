//
//  Color.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/10/13.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class Color: NSObject {
    static let Current:UIColor = UIColor(red: CGFloat(86)/255.0, green:  CGFloat(55)/255.0, blue: CGFloat(12)/255.0, alpha: 1)
    static let Nav:UIColor = UIColor(red: CGFloat(253)/255.0, green:  CGFloat(211)/255.0, blue: CGFloat(37)/255.0, alpha: 1)
    static let Input:UIColor = UIColor(red: CGFloat(34)/255.0, green:  CGFloat(36)/255.0, blue: CGFloat(41)/255.0, alpha: 1)
    static let FontInput:UIColor = UIColor(red: CGFloat(79)/255.0, green:  CGFloat(81)/255.0, blue: CGFloat(85)/255.0, alpha: 1)
    //按钮
    static let Btnone:UIColor = UIColor(red: CGFloat(250)/255.0, green:  CGFloat(99)/255.0, blue: CGFloat(99)/255.0, alpha: 1)
    static let Btntwo:UIColor = UIColor(red: CGFloat(145)/255.0, green:  CGFloat(161)/255.0, blue: CGFloat(247)/255.0, alpha: 1)
    static let Btnthree:UIColor = UIColor(red: CGFloat(223)/255.0, green:  CGFloat(157)/255.0, blue: CGFloat(247)/255.0, alpha: 1)
    static let Red:UIColor = UIColor(red: CGFloat(255)/255.0, green:  CGFloat(114)/255.0, blue: CGFloat(114)/255.0, alpha: 1)
    static let Green:UIColor = UIColor(red: CGFloat(0)/255.0, green:  CGFloat(200)/255.0, blue: CGFloat(172)/255.0, alpha: 1)
    static let Blue:UIColor = UIColor(red: CGFloat(127)/255.0, green:  CGFloat(169)/255.0, blue: CGFloat(253)/255.0, alpha: 1)
    
    static let Tabbar:UIColor = UIColor(red: CGFloat(253)/255.0, green:  CGFloat(211)/255.0, blue: CGFloat(37)/255.0, alpha: 1)
    
    static let Bg:UIColor = UIColor(red: CGFloat(250)/255.0, green:  CGFloat(250)/255.0, blue: CGFloat(250)/255.0, alpha: 1)
    
    static let Bgtwo:UIColor = UIColor(red: CGFloat(246)/255.0, green:  CGFloat(246)/255.0, blue: CGFloat(246)/255.0, alpha: 1)
    static let Borders:UIColor = UIColor(red: CGFloat(204)/255.0, green:  CGFloat(204)/255.0, blue: CGFloat(204)/255.0, alpha: 1)
    
    //提示
    static let ProgressTip = UIColor(red: CGFloat(9)/255.0, green:  CGFloat(163)/255.0, blue: CGFloat(213)/255.0, alpha: 1)
    static let ProgressBg:UIColor = UIColor(red: CGFloat(29)/255.0, green:  CGFloat(198)/255.0, blue: CGFloat(253)/255.0, alpha: 1)
    
    //字体
    static func Font(_ type:Int)->UIColor{
        switch type {
        case 0:
            let color:UIColor = UIColor(red: CGFloat(86)/255.0, green:  CGFloat(55)/255.0, blue: CGFloat(12)/255.0, alpha: 1)
            return color
        case 1:
            let color:UIColor = UIColor(red: CGFloat(51)/255.0, green:  CGFloat(51)/255.0, blue: CGFloat(51)/255.0, alpha: 1)
            return color
        case 2:
            let color:UIColor = UIColor(red: CGFloat(102)/255.0, green:  CGFloat(102)/255.0, blue: CGFloat(102)/255.0, alpha: 1)
            return color
        case 3:
            let color:UIColor = UIColor(red: CGFloat(250)/255.0, green:  CGFloat(99)/255.0, blue: CGFloat(99)/255.0, alpha: 1)
            return color
        case 4:
            let color:UIColor = UIColor(red: CGFloat(145)/255.0, green:  CGFloat(161)/255.0, blue: CGFloat(247)/255.0, alpha: 1)
            return color
        case 5:
            let color:UIColor = UIColor(red: CGFloat(230)/255.0, green:  CGFloat(230)/255.0, blue: CGFloat(230)/255.0, alpha: 1)
            return color
        default:
            let color:UIColor = UIColor(red: CGFloat(79)/255.0, green:  CGFloat(81)/255.0, blue: CGFloat(85)/255.0, alpha: 1)
            return color
        }
    }
}
