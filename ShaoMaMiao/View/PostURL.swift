//
//  PostURL.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/11/29.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit
import AdSupport
extension String {
    var md5 : String{
        var md5String = ""
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
        
        if let data = self.data(using: .utf8) {
            data.withUnsafeBytes({ (bytes: UnsafePointer<CChar>) -> Void in
                CC_MD5(bytes, CC_LONG(data.count), md5Buffer)
                md5String = (0..<digestLength).reduce("") { $0 + String(format:"%02x", md5Buffer[$1]) }
            })
        }
        
        return md5String
    }
//    //根据开始位置和长度截取字符串
//    func subString(start:Int, length:Int = -1)->String {
//        var len = length
//        if len == -1 {
//            len = characters.count - start
//        }
//        let st = characters.index(startIndex, offsetBy:start)
//        let en = characters.index(st, offsetBy:len)
//        let range = st ..< en
//        return substring(with:range)
//    }
}
class PostURL: NSObject {
    let MainURL:String = "https://nyato.com"
    let ImgURL:String = "https://img.nyato.com"
    var NyatoURL:String = "https://apiplus.nyato.com"
    //    let NyatoURLS:String = "http://testapi.nyato.com"
    let App:String = "android"

    var IDFA:String = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    let VerificationCode="us8dgf30hjRJGFU21"
    func FromURL(_ php:String,mod:String,act:String,type:Int) -> String{
        switch type {
        case 0:
            NyatoURL = "https://apiplus.nyato.com"
        case 1:
            NyatoURL = "https://apiplus1.nyato.com"
        case 2:
            NyatoURL = "https://apiplus2.nyato.com"
        default:
            break
        }
        let NowTime:TimeInterval = NSDate().timeIntervalSince1970 * 1000
        let timestring:String = "\(NowTime)"
        let times:Array = timestring.components(separatedBy: ".")
        let time:String = times.first!
        let uid:Int = UserDefaults.standard.integer(forKey: "uid")
        
        let verson:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let Md5Code:String = (VerificationCode+act).md5
        var sign:Array = ["\(time)","\(uid)","\(Md5Code)","\(self.IDFA)"]
        sign.sort()
        let SignMD5:String = "\(sign.first!)&\(sign[1])&\(sign[2])&\(sign.last!)"
        let Key:String = "\(uid)"
        let network:Int = UserDefaults.standard.integer(forKey: "network")
        
        if UserDefaults.standard.object(forKey: "oauthtoken") == nil || UserDefaults.standard.object(forKey: "oauthtokensecret") == nil {
            let Urls:String = "\(NyatoURL)\(php)?app=\(App)&mod=\(mod)&act=\(act)&uid=\(uid)&token=\(Md5Code)&version=\(verson)&app_time=\(time)&app_device=\(IDFA)&app_sign=\(SignMD5.md5)&key=\(Key.md5)&oauth_token=\(time.md5)&oauth_token_secret=\(verson.md5)&network_status=\(network)"
//            print("\(uid) \(Urls)")
            return Urls
            
        }else{
            let OauthToken:String = UserDefaults.standard.object(forKey: "oauthtoken") as! String
            let OauthTokenSecret:String = UserDefaults.standard.object(forKey: "oauthtokensecret") as! String
            let Urls:String = "\(NyatoURL)\(php)?app=\(App)&mod=\(mod)&act=\(act)&uid=\(uid)&token=\(Md5Code)&version=\(verson)&app_time=\(time)&app_device=\(IDFA)&app_sign=\(SignMD5.md5)&key=\(Key.md5)&oauth_token=\(OauthToken)&oauth_token_secret=\(OauthTokenSecret)&network_status=\(network)"
//            print("\(OauthToken) \(OauthTokenSecret) \(uid) \(Urls)")
            return Urls
        }
    }
    

}
