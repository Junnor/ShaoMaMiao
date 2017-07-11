//
//  Bottomnav.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 16/5/31.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit
struct Bottomnav {
//    static let screenWidth = UIScreen.main.applicationFrame.maxX
    static let screenWidth = UIScreen.main.bounds.maxX
    static let screenHeight = UIScreen.main.bounds.maxY
    
    static let rootViewController = UIApplication.shared.keyWindow?.rootViewController as! ViewController
    
    static let ExposNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpoNav")
    static let UserNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeNav")
    static let LoginNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNav")
    
}
