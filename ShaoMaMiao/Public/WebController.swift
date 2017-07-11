//
//  WebController.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/12/13.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class WebController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var BgLoading: UIActivityIndicatorView!
    @IBOutlet weak var BgWeb: UIWebView!
    var navTitle:String = "使用教程"
    var URLS:String = "https://nyato.com/help/annouce_detail/89"
    override func viewDidLoad() {
        super.viewDidLoad()

        title = navTitle
        BgLoading.startAnimating()
        BgWeb.delegate = self
        let request = URLRequest(url: Foundation.URL(string: "\(URLS)")!)
        BgWeb.loadRequest(request)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webViewDidFinishLoad(_ webView: UIWebView) {
        BgLoading.stopAnimating()
        BgLoading.isHidden = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
