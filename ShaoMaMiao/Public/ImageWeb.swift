//
//  ImageWeb.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 2017/2/27.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class ImageWeb: NSObject {
    static func imageLoading(url:String,imageviews:UIImageView) {
        let urls = URL(string: url) ?? URL(string: "https://www.nyato.com/addons/theme/stv1/_static/expo-image/app/icon.png")
        let requests:URLRequest = URLRequest(url: urls!)
        NSURLConnection.sendAsynchronousRequest(requests, queue: OperationQueue.main, completionHandler: { (response:URLResponse?, data:Data?, error:Error?) in
            if data != nil {
                let images = UIImage(data: data!)
                imageviews.image = images
            }
        })
    }
    
    static func imageBtnLoading(url:String,imageviews:UIButton) {
        let urls = URL(string: url) ?? URL(string: "https://www.nyato.com/addons/theme/stv1/_static/expo-image/app/icon.png")
        let requests:URLRequest = URLRequest(url: urls!)
        NSURLConnection.sendAsynchronousRequest(requests, queue: OperationQueue.main, completionHandler: { (response:URLResponse?, data:Data?, error:Error?) in
            if data != nil {
                let images = UIImage(data: data!)
                imageviews.setBackgroundImage(images, for: UIControlState.normal)
            }
        })
        
    }
}
