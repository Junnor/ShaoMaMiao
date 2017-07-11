//
//  FilePath.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/11/29.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class FilePath: NSObject {
    static let ExpoInfo:String = "\(NSHomeDirectory())/Documents/expo.plist"
    static let TicketInfo:String = "\(NSHomeDirectory())/Documents/ticketinfo.plist"
    static let TicketList:String = "\(NSHomeDirectory())/Documents/ticketList.plist"
    static let sCodeData:String = "\(NSHomeDirectory())/Documents/codeData.plist"
    static let FileUserInfo:String = "\(NSHomeDirectory())/Documents/userinfo.plist"
    static let TicketId:String = "\(NSHomeDirectory())/Documents/ticketid.plist"
    static let Error:String = "\(NSHomeDirectory())/Documents/error.plist"
    static let FileExpo:String = "\(NSHomeDirectory())/Documents/expolist.plist"
    static let Refunds:String = "\(NSHomeDirectory())/Documents/refunds.plist"

    static func FileRemoveAll(_ out:Bool){
        let data = NSMutableData()
        UserDefaults.standard.set(0, forKey: "model")
        if out {
            data.write(toFile: FileUserInfo, atomically: true)
            let NowTime:TimeInterval = Date().timeIntervalSince1970
            let starcode:String = "20161010\(NowTime)"
            UserDefaults.standard.set("\(starcode.md5)", forKey: "oauthtoken")
            UserDefaults.standard.set("\(starcode.md5)", forKey: "oauthtokensecret")
            UserDefaults.standard.set(0, forKey: "uid")
            data.write(toFile: ExpoInfo, atomically: true)
            data.write(toFile: TicketInfo, atomically: true)
            data.write(toFile: TicketList, atomically: true)
            data.write(toFile: FileUserInfo, atomically: true)
            data.write(toFile: TicketId, atomically: true)
            data.write(toFile: Error, atomically: true)
            data.write(toFile: Refunds, atomically: true)
            UserDefaults.standard.set(nil, forKey: "selecttickets")
            UserDefaults.standard.set(nil, forKey: "selectticketid")
        }else{
            data.write(toFile: ExpoInfo, atomically: true)
        }
        
    }
    static func delRefunds(){
        let data = NSMutableData()
        data.write(toFile: Refunds, atomically: true)
    }
}
