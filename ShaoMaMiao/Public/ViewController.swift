//
//  ViewController.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/10/12.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import AudioToolbox

class ViewController: UIViewController {

    var CodeNav:UINavigationController!
    var CodeIndexHtml:CodeIndexController!
    var InfoUser:UserModel = UserModel()
    var Tickets:[NSDictionary] = [NSDictionary]()
    var sCodes:[NSDictionary] = [NSDictionary]()
    var Errors:NSMutableArray = NSMutableArray()
    @IBOutlet weak var BgLoading: UIActivityIndicatorView!
    override func viewDidAppear(_ animated: Bool) {
        self.upVersion()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserDefaults.standard.set("wwww", forKey: "codeForOpen")

        // Do any additional setup after loading the view, typically from a nib.
        CodeNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeNav") as! UINavigationController
        CodeIndexHtml = CodeNav.viewControllers.first as! CodeIndexController
        self.view.addSubview(CodeIndexHtml.navigationController!.view)
        self.view.addSubview(CodeIndexHtml.view)
        //新增一个验证授权信息同步
        self.FuncGetCodeForCodeSynchronous()        
        
        let TicketJson = NSDictionary(contentsOfFile: FilePath.TicketList)
        if TicketJson != nil && TicketJson != [:] {
           Tickets = TicketJson!.value(forKey: "data") as! [NSDictionary]
        }
    }
    
    //MARK:验票授权的重新验证(这是同步)
    func FuncGetCodeForCodeSynchronous() {
     
            if UserDefaults.standard.value(forKey: "codeForOpen") != nil {
                let code : String = UserDefaults.standard.value(forKey: "codeForOpen") as! String
                //            print("string:\(UserDefaults.standard.value(forKey: "codeForOpen") as! String)")
                let urlType = UserDefaults.standard.integer(forKey: "urltype")

                let GetUinfoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "authorize_scan", type: urlType)
                
                let url:URL = URL(string:GetUinfoURL)!
                let request = NSMutableURLRequest(url:url)
                let body = "au_code=\(code)"
                
                //编码POST数据
                let postData = body.data(using: String.Encoding.utf8)
                //保用 POST 提交
                request.httpMethod = "POST"
                request.httpBody = postData
                //响应对象
                var response:URLResponse?
                
                do{
                    //发出请求
                    let data:NSData? = try NSURLConnection.sendSynchronousRequest(request as URLRequest,returning: &response) as NSData?
                    
                    let dict:NSDictionary?
                    do {
                        dict = try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        let Status = dict?.value(forKey: "status") as! Int
                        
                        if Status == 0 {
                            UserDefaults.standard.set(false, forKey: "open")
                            
                        }else{
                            UserDefaults.standard.set(true, forKey: "open")
                        }
                        
                    }catch _ {
                        
                        dict = nil
                    }
                    
                }catch let error as NSError{
                    //打印错误消息
                    print(error.code)
                    print(error.description)
                }
            }
            if UserDefaults.standard.bool(forKey: "open") == false {
                self.view.addSubview(Bottomnav.ExposNav.view)
            }
        
    }
    
    //授权窗口
    var CodeStr:String = "saomamiaoss"

    func appVerification(){
        let savetime:Int = UserDefaults.standard.integer(forKey: "savetime")
        let nowtime:Int = Int(Date().timeIntervalSince1970)
        
        if (nowtime - savetime) > 2160000 && nowtime > 1494382210 {
            self.CodeTip()
        }
    }
    func CodeTip(){
        let Alert:UIAlertController = UIAlertController(title: "请输入授权码", message: "您还没有获得授权，请输入授权码才可以使用", preferredStyle: UIAlertControllerStyle.alert)
        Alert.addTextField { (text) in
            text.keyboardType = .numbersAndPunctuation
        }
//        let BtnCancel:UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let BtnSubmit:UIAlertAction = UIAlertAction(title: "确认提交", style: UIAlertActionStyle.destructive) { (action) in
            self.CodeStr = (Alert.textFields?.first?.text)!
            let urlType:Int = UserDefaults.standard.integer(forKey: "urltype")
            self.FuncGetCode(self.CodeStr, urlType: urlType, type: 0)
        }
        let btnUrlChangeMain:UIAlertAction = UIAlertAction(title: "切换主线程", style: UIAlertActionStyle.default) { (action) in
            UserDefaults.standard.set(0, forKey: "urltype")
            self.CodeStr = (Alert.textFields?.first?.text)!
            self.FuncGetCode(self.CodeStr, urlType: 0, type: 0)
        }
        let btnUrlChangeOne:UIAlertAction = UIAlertAction(title: "切换线程一", style: UIAlertActionStyle.default) { (action) in
            UserDefaults.standard.set(1, forKey: "urltype")
            self.CodeStr = (Alert.textFields?.first?.text)!
            self.FuncGetCode(self.CodeStr, urlType: 1, type:0)

        }
        let btnUrlChangeTwo:UIAlertAction = UIAlertAction(title: "切换线程二", style: UIAlertActionStyle.default) { (action) in
            UserDefaults.standard.set(2, forKey: "urltype")
            self.CodeStr = (Alert.textFields?.first?.text)!
            self.FuncGetCode(self.CodeStr, urlType: 2, type:0)
        }
//        Alert.addAction(BtnCancel)
        Alert.addAction(BtnSubmit)
        Alert.addAction(btnUrlChangeMain)
        Alert.addAction(btnUrlChangeOne)
        Alert.addAction(btnUrlChangeTwo)
        self.present(Alert, animated: true, completion: nil)
    }
    func FuncGetCode(_ code:String,urlType:Int,type:Int){
        let GetUinfoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "authorize_scan", type: urlType)
        Alamofire.request(GetUinfoURL, method: .post,parameters: ["au_code":code]).responseJSON { (response) in
            if let Json = response.result.value as? NSDictionary{
                let Status = Json.value(forKey: "status") as! Int
                if Status == 0 {
                    if type == 0 {
                        let Info:String = Json.value(forKey: "info") as! String
                        self.errorNotice("\(Info)")
                        self.CodeTip()
                    }else{
                        let alert = UIAlertController(title: "扫码内容", message: "您刚刚扫码的内容是\(code)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        Bottomnav.rootViewController.present(alert, animated: true, completion: nil)
                    }
                }else{
                    Bottomnav.ExposNav.view.removeFromSuperview()
                    UserDefaults.standard.set(code, forKey: "codeForOpen")
                    UserDefaults.standard.set(true, forKey: "open")
                    let nowtime:TimeInterval = Date().timeIntervalSince1970
                    UserDefaults.standard.set(Int(nowtime), forKey: "savetime")
                }
            }else{
                self.errorNotice("连接超时")
            }
            
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///////////////////////////////版本更新提示/////////////////////
    func upVersion(){
        let verson:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let Urls:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "ios_update", type: 0)
        Alamofire.request(Urls, method: .post, parameters:["versioncode":"\(verson)"]).responseJSON { (response) -> Void in
            if let Json = response.result.value as? NSDictionary {
                let Status:Int = Json.value(forKey: "status") as! Int
                if Status == 1 {
                    let urlString:String = Json.value(forKey: "down_url") as! String
                    self.FuncUpVersionTip(urls: urlString)
                }
            }
        }
    }
    func FuncUpVersionTip(urls:String){
        let AlertGood:UIAlertController = UIAlertController(title: "喵特扫码有新的更新", message: "未避免影响使用，建议您使用最新版的喵特扫码APP", preferredStyle: UIAlertControllerStyle.alert)
   
        let BtnCancel:UIAlertAction = UIAlertAction(title: "等会更新", style: UIAlertActionStyle.cancel) { (action) -> Void in
        }
        let BtnSubmit:UIAlertAction = UIAlertAction(title: "更新APP", style: UIAlertActionStyle.destructive) { (action) -> Void in
            UIApplication.shared.openURL(URL(string: urls)!)
        }
        AlertGood.addAction(BtnSubmit)
        AlertGood.addAction(BtnCancel)
        self.view.window?.rootViewController?.present(AlertGood, animated: true, completion: nil)
    }

    //请求超时
    var Index:Int = 0
    var TipTime:Timer!
    var BoolReturn:Bool = true
    func FuncTime(){
        Index = 0
        TipTime = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.FuncTip), userInfo: nil, repeats: true)
    }
    func FuncTip(){
        Index += 1
        if Index > 120 {
            self.clearAllNotice()
            Index = 0
            if TipTime != nil {
                TipTime.invalidate()
            }
            self.errorNotice("请求超时")
        }
    }
    
    func TimeClose(){
        Index = 0
        if TipTime != nil {
            TipTime.invalidate()
        }
    }
    //提示音
    func AudioTip(){
        AudioServicesPlaySystemSound(1010)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    //网络监测
    var NetWork:Int = 0
    
    func Neworking(){
        let reachability = Reachability()!
        if reachability.isReachableViaWiFi {
            //self.infoNotice("当前WIFI网络环境")
            self.NetWork = 0
        }else if reachability.isReachableViaWWAN{
            self.infoNotice("当前处于4G网络环境")
            self.NetWork = 1
        }else{
            self.errorNotice("没有连接网络")
            self.NetWork = 2
        }
    }
    
    
}

