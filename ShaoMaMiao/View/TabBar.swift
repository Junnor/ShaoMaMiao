//
//  TabBar.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 16/6/1.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class TabBar: UITabBar,UITabBarDelegate {

    @IBOutlet weak var NavExpo: UITabBarItem!
    @IBOutlet weak var NavUser: UITabBarItem!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.delegate = self
        self.layer.borderColor = Color.Borders.cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = Color.Bg
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag{
        case 2:
            Bottomnav.rootViewController.CodeIndexHtml.recordOutOfInternetUpdate()
        case 1:
            Bottomnav.rootViewController.CodeIndexHtml.FuncTextCodeSubmit()
        default:
            break
        }
    }

}
