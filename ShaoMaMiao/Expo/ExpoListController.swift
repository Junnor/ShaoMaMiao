//
//  ExpoListController.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 16/6/1.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class ExpoListController: UIViewController,UITableViewDataSource,UITableViewDelegate,QRCodeReaderViewControllerDelegate {
    var PublicNav: TabBar = TabBar()
    let Title:String = "漫展列表"
    var Page:Int = 1
    var PageStatus:Bool = false
    var InfoUser:UserModel = UserModel()
    var InfoExpo:ExpoModel = ExpoModel()
    var SWThreeType:Int = 0
    var Expoes:NSMutableOrderedSet = NSMutableOrderedSet()
    var ExpoCity:NSMutableOrderedSet = NSMutableOrderedSet()
    var CityListCount:Int = 0

    var NavTitle:String = "漫展"
    var BoolResh:Bool = true
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var BgNav: UIView!
//    @IBOutlet weak var BtnAreaopen: UIBarButtonItem!
    lazy var QRreader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {$0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true})
    func FuncCode(){
        do {
            //扫码模式
            QRreader.modalPresentationStyle = .formSheet
            QRreader.delegate = self
            PublicNav.selectedItem = nil
            
            if try QRCodeReader.supportsMetadataObjectTypes() {
                //回调
                QRreader.completionBlock = { (result: QRCodeReaderResult?) in
                    
                    if result?.value != nil{
                        //网址
                        let codeStr:String = String(describing: result!.value)
                        let codeArray:Array = codeStr.components(separatedBy: "http")
                        if codeArray.count > 1 {
                            self.QRreader.dismiss(animated: true, completion: {
                                let webVc:WebController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Web") as! WebController
                                webVc.URLS = codeStr
                                webVc.navTitle = "查看内容"
                                self.navigationController?.pushViewController(webVc, animated: true)
                            })


                        }else{
                            self.QRreader.dismiss(animated: true, completion: {
                                let urltype:Int = UserDefaults.standard.integer(forKey: "urltype")
                                Bottomnav.rootViewController.FuncGetCode(codeStr, urlType: urltype,type: 1)
                            })
                        }
                        let nowtime:TimeInterval = Date().timeIntervalSince1970
                        let codes:String = "\(codeStr)-\(nowtime)"
                        Bottomnav.rootViewController.Errors.add(codes)
                        Bottomnav.rootViewController.Errors.write(toFile: FilePath.Error, atomically: true)
                    }
                    
                }
                
                self.present(QRreader, animated: true, completion: nil)
            }else {
                let alert:UIAlertController = UIAlertController(title: "貌似出了点问题", message: "您有可能关了相机,请确认是否有授权该APP打开相机", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确 定", style: .cancel, handler: nil))
                Bottomnav.rootViewController.present(alert, animated: true, completion: nil)
            }
        } catch let error as NSError {
            switch error.code {
            case -11852:
                
                let alert = UIAlertController(title: "貌似出了点问题", message: "您有可能关了相机,请确认是否有授权该APP打开相机", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                Bottomnav.rootViewController.present(alert, animated: true, completion: nil)
                
            case -11814:
                let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                Bottomnav.rootViewController.present(alert, animated: true, completion: nil)
            default:()
            }
        }
        
    }
    
    func toErrorVC(){
        let errorVc:ErrorController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "errorList") as! ErrorController
        self.navigationController?.pushViewController(errorVc, animated: true)
    }
    
    //代理之一！！！！   扫描结果
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult){
        
        
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        self.clearAllNotice()
        reader.dismiss(animated: true, completion: nil)
    }

    
//    @IBAction func ButtonArea(sender: UIBarButtonItem) {
//        
//        Bottomnav.rootViewController.performSegueWithIdentifier("ToCity", sender: self)
//    }
    func FuncNav() {
        self.navigationController?.navigationBar.barTintColor = Color.Nav
        self.navigationController?.navigationBar.tintColor = Color.Font(0)
        let NavTitleColor:NSDictionary = NSDictionary(object: Color.Font(0),forKey: NSForegroundColorAttributeName as NSCopying)
        self.navigationController?.navigationBar.titleTextAttributes = NavTitleColor as? [String : AnyObject]
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        FuncNav()
        InfoUser.Uid = UserDefaults.standard.integer(forKey: "uid")
        if InfoUser.Uid == 0 {
            Bottomnav.rootViewController.shouldPerformSegue(withIdentifier: "ToLogin", sender: self)
        }else if BoolResh {
            BoolResh = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(NavTitle)"
        InfoUser.Uid = UserDefaults.standard.integer(forKey: "uid")
        let NowTime:TimeInterval = Date().timeIntervalSince1970
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "记录", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.toErrorVC))
        if NowTime > 1494382210 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "验票", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.CodeTip))
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "扫码", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.FuncCode))
        }
        FuncNav()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        tableView.dataSource = self
        tableView.delegate = self
        let nib:UINib = UINib(nibName: "ExpoListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ExpoListCell")
        
        //初始化plist已有数据
        let PlistExpo = NSDictionary(contentsOfFile: FilePath.FileExpo)
        if PlistExpo != nil {
            FuncUIExpo()
        }
        
        weak var weakSelf = self as ExpoListController
        tableView.nowRefresh({ () -> Void in
            weakSelf?.delay(3.0, closure: { () -> () in
                self.tableView.starLoadMoreData()
                self.PageStatus = false
                self.Page = 1
                self.FuncExpolist()
            })
        })
        
        // 上啦加载更多
        tableView.toLoadMoreAction({ () -> Void in
            self.Page += 1
            self.PageStatus = true
            self.FuncExpolist()
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.clearAllNotice()
    }
    //授权
    func CodeTip(){
        Bottomnav.rootViewController.CodeTip()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 10 {
            if CityListCount == 0 {
                return 64
            }else{
                return 120
            }
        }else{
            return 120
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }else{
            let BgHeaderbg:UIView = UIView(frame: CGRect(x: 0, y: 0, width: Body.Width, height: 40))
            let BtnOtherTit:UIButton = UIButton(frame: CGRect(x: 12, y: 8, width: 87, height: 24))
            BtnOtherTit.setTitle("其他地区   ", for: UIControlState())
            BtnOtherTit.setTitleColor(Color.Font(4), for: UIControlState())
            BtnOtherTit.titleLabel!.font = UIFont.systemFont(ofSize: 14.0)
            BtnOtherTit.setBackgroundImage(UIImage(named: "bg-tit"), for: UIControlState())
            BgHeaderbg.addSubview(BtnOtherTit)
            return BgHeaderbg
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 10 {
            if CityListCount == 0 {
                var cellTip:ExpoTipCell? = tableView.dequeueReusableCell(withIdentifier: "ExpoTipCell") as? ExpoTipCell
                if cellTip == nil{
                    cellTip = Bundle.main.loadNibNamed("ExpoListCell", owner: nil, options: nil)?.last as? ExpoTipCell
                }
                
                if InfoUser.Pid == 100 {
                    cellTip?.LabelTip.text = "当前没有定位城市，点击这里切换"
                }else{
                    cellTip?.LabelTip.text = "该城市没有漫展。有情报？点击反馈"
                }
                cellTip?.backgroundColor = UIColor.white
                return cellTip!
                
            }else{
                var cell:ExpoListCell? = tableView.dequeueReusableCell(withIdentifier: "ExpolistsCell") as? ExpoListCell
                if cell == nil{
                    cell = Bundle.main.loadNibNamed("ExpoListCell", owner: nil, options: nil)?[0] as? ExpoListCell
                }
                let cellModel = ExpoCity.object(at: indexPath.row) as! ExpoListModel
                ImageWeb.imageLoading(url: cellModel.Cover, imageviews: (cell?.Logo)!)
                
                cell?.Title.text = cellModel.Name
                
                //开始
                let dateStart : NSDate = NSDate.init(timeIntervalSince1970: TimeInterval(cellModel.StartTime)!)
                let dateEnd : NSDate = NSDate.init(timeIntervalSince1970: TimeInterval(cellModel.EndTime)!)
                
                let formatterStart : DateFormatter = DateFormatter()
                formatterStart.dateFormat = "YYYY年MM月dd日"
                
                let formatterEnd : DateFormatter = DateFormatter()
                formatterEnd.dateFormat = "MM月dd日"
                
                let startTime :String = formatterStart.string(from: dateStart as Date)
                
                let endTime : String = formatterEnd.string(from: dateEnd as Date)
                
                cell?.Time.text = "\(startTime)-\(endTime)"
                let section:String = ExpoModel().SectionName(Int(cellModel.SectionId)!)
                cell?.LabelType.text = "\(section)"
                cell?.Location.text = String(cellModel.Location)! + String(cellModel.Addr)!
                cell?.SWThreeType.tag = indexPath.row
                cell?.SWThreeType.isEnabled = false
                cell?.SWThreeType.addTarget(self, action: #selector(ExpoListController.FuncButtonExpo(_:)), for: UIControlEvents.touchUpInside)
                cell?.Like.text = "\(cellModel.Love)"
                return cell!
            }
        }else{
            var cell:ExpoListCell? = tableView.dequeueReusableCell(withIdentifier: "ExpolistsCell") as? ExpoListCell
            if cell == nil{
                cell = Bundle.main.loadNibNamed("ExpoListCell", owner: nil, options: nil)?[0] as? ExpoListCell
            }
            
            let cellModel = Expoes.object(at: indexPath.row) as! ExpoListModel

            ImageWeb.imageLoading(url: cellModel.Cover, imageviews: (cell?.Logo)!)
            
            cell?.Title.text = cellModel.Name
            
            //开始
            let dateStart : NSDate = NSDate.init(timeIntervalSince1970: TimeInterval(cellModel.StartTime)!)
            let dateEnd : NSDate = NSDate.init(timeIntervalSince1970: TimeInterval(cellModel.EndTime)!)
            
            let formatterStart : DateFormatter = DateFormatter()
            formatterStart.dateFormat = "YYYY年MM月dd日"
            
            let formatterEnd : DateFormatter = DateFormatter()
            formatterEnd.dateFormat = "MM月dd日"
            
            let startTime :String = formatterStart.string(from: dateStart as Date)
            
            let endTime : String = formatterEnd.string(from: dateEnd as Date)
            
            cell?.Time.text = "\(startTime)-\(endTime)"
            let section:String = ExpoModel().SectionName(Int(cellModel.SectionId)!)
            cell?.LabelType.text = "\(section)"
            
            cell?.Location.text = String(cellModel.Location)! + String(cellModel.Addr)!
            cell?.SWThreeType.tag = indexPath.row
            cell?.SWThreeType.isEnabled = false
            cell?.SWThreeType.addTarget(self, action: #selector(ExpoListController.FuncButtonExpos(_:)), for: UIControlEvents.touchUpInside)
            
            cell?.Like.text = "\(cellModel.Love)"
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Expoes.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        }else{
            return 40
        }
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 10 {
            if CityListCount == 0 {
                if InfoUser.Pid == 100 {
                    Bottomnav.rootViewController.performSegue(withIdentifier: "ToCity", sender: self)
                }else if InfoUser.Pid != 0 {
                    InfoUser.Uid = UserDefaults.standard.integer(forKey: "uid")
                    if InfoUser.Uid == 0 {
                        Bottomnav.rootViewController.performSegue(withIdentifier: "ToLogin", sender: self)
                    }else{
                        
                    }
                }
            }else{
                let cellMode = ExpoCity.object(at: indexPath.row) as! ExpoListModel
                InfoExpo.Cover = cellMode.Cover
                InfoExpo.code_secret = String(cellMode.Eid)!
                InfoExpo.Name = String(cellMode.Name)!
                InfoExpo.StartTime = TimeInterval(cellMode.StartTime)!
                InfoExpo.EndTime = TimeInterval(cellMode.EndTime)!
                InfoExpo.SectionId = Int(cellMode.SectionId)!
                InfoExpo.Location = String(cellMode.Location)!
                InfoExpo.Description = String(cellMode.Description)!
                InfoExpo.Addr = String(cellMode.Addr)!
                InfoExpo.PresalePrice = String(cellMode.PresalePrice)!
                InfoExpo.ScenePrice = String(cellMode.ScenePrice)!
                InfoExpo.Tag = String(cellMode.Tag)!
                InfoExpo.CityId = Int(cellMode.City)!
                InfoExpo.ProvinceId = Int(cellMode.Province)!
                InfoExpo.Coordinate = String(cellMode.Coordinate)!
                InfoExpo.Love = String(cellMode.Love)!
                InfoExpo.IsTicket = cellMode.IsTicket
                UserDefaults.standard.set(false, forKey: "ExpoMy")
                self.performSegue(withIdentifier: "ToExpoDetail", sender: nil)
            }
        }else{
            let cellMode = Expoes.object(at: indexPath.row) as! ExpoListModel
            InfoExpo.Cover = cellMode.Cover
            InfoExpo.code_secret = String(cellMode.Eid)!
            InfoExpo.Name = String(cellMode.Name)!
            InfoExpo.StartTime = TimeInterval(cellMode.StartTime)!
            InfoExpo.EndTime = TimeInterval(cellMode.EndTime)!
            InfoExpo.SectionId = Int(cellMode.SectionId)!
            InfoExpo.Location = String(cellMode.Location)!
            InfoExpo.Description = String(cellMode.Description)!
            InfoExpo.Addr = String(cellMode.Addr)!
            InfoExpo.PresalePrice = String(cellMode.PresalePrice)!
            InfoExpo.ScenePrice = String(cellMode.ScenePrice)!
            InfoExpo.Tag = String(cellMode.Tag)!
            InfoExpo.CityId = Int(cellMode.City)!
            InfoExpo.ProvinceId = Int(cellMode.Province)!
            InfoExpo.Coordinate = String(cellMode.Coordinate)!
            InfoExpo.Love = String(cellMode.Love)!
            InfoExpo.IsTicket = cellMode.IsTicket
            self.performSegue(withIdentifier: "ToExpoDetail", sender: nil)
        }
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        
    }
    func FuncButtonExpo(_ sender:UIButton){
        let cellMode = ExpoCity.object(at: sender.tag) as! ExpoListModel
        InfoExpo.Cover = cellMode.Cover
        InfoExpo.code_secret = String(cellMode.Eid)!
        InfoExpo.Name = String(cellMode.Name)!
        InfoExpo.StartTime = TimeInterval(cellMode.StartTime)!
        InfoExpo.EndTime = TimeInterval(cellMode.EndTime)!
        InfoExpo.SectionId = Int(cellMode.SectionId)!
        InfoExpo.Location = String(cellMode.Location)!
        InfoExpo.Description = String(cellMode.Description)!
        InfoExpo.Addr = String(cellMode.Addr)!
        InfoExpo.PresalePrice = String(cellMode.PresalePrice)!
        InfoExpo.ScenePrice = String(cellMode.ScenePrice)!
        InfoExpo.Tag = String(cellMode.Tag)!
        InfoExpo.CityId = Int(cellMode.City)!
        InfoExpo.ProvinceId = Int(cellMode.Province)!
        InfoExpo.Coordinate = String(cellMode.Coordinate)!
        InfoExpo.Love = String(cellMode.Love)!
        InfoExpo.IsTicket = cellMode.IsTicket
        self.performSegue(withIdentifier: "ToExpoDetail", sender: nil)
    }
    func FuncButtonExpos(_ sender:UIButton){
        let cellMode = Expoes.object(at: sender.tag) as! ExpoListModel
        InfoExpo.Cover = cellMode.Cover
        InfoExpo.code_secret = String(cellMode.Eid)!
        InfoExpo.Name = String(cellMode.Name)!
        InfoExpo.StartTime = TimeInterval(cellMode.StartTime)!
        InfoExpo.EndTime = TimeInterval(cellMode.EndTime)!
        InfoExpo.SectionId = Int(cellMode.SectionId)!
        InfoExpo.Location = String(cellMode.Location)!
        InfoExpo.Description = String(cellMode.Description)!
        InfoExpo.Addr = String(cellMode.Addr)!
        InfoExpo.PresalePrice = String(cellMode.PresalePrice)!
        InfoExpo.ScenePrice = String(cellMode.ScenePrice)!
        InfoExpo.Tag = String(cellMode.Tag)!
        InfoExpo.CityId = Int(cellMode.City)!
        InfoExpo.ProvinceId = Int(cellMode.Province)!
        InfoExpo.Coordinate = String(cellMode.Coordinate)!
        InfoExpo.Love = String(cellMode.Love)!
        InfoExpo.IsTicket = cellMode.IsTicket
        self.performSegue(withIdentifier: "ToExpoDetail", sender: nil)
    }
    
    /////////////////////////获取漫展////////////////
    //筛选传参判定
    func FuncExpolist(){
        ZLSwithRefreshFootViewText = ""
        
        let ExpoURL:String = PostURL().FromURL("/index.php", mod: "Expo", act: "ex_list", type: 0)
        
        
        Alamofire.request(ExpoURL, method: .post,parameters:["uid":InfoUser.Uid,"p":Page]).responseJSON { (response) in
            
            if let Json = response.result.value as? NSDictionary{
                self.BoolErorr = false
                let Result = Json.value(forKey: "result") as! Int
                if Result == 0 {
                    if self.PageStatus {
                        self.Page -= 1
                        self.tableView.endLoadMoreData()
                    }else {
                        self.Expoes.removeAllObjects()
                        self.ExpoCity.removeAllObjects()
                        self.infoNotice("没有相关漫展")
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                            
                        })
                    }
                }else{
                    if self.PageStatus {
                        let ExpolistJson = (Json.value(forKey: "data") as! [NSDictionary]).map{
                            ExpoListModel(name: $0["name"] as! String,cover: $0["cover"] as! String, description: $0["description"] as! String, eid: $0["eid"] as! String, start: $0["start_time"] as! String, end: $0["end_time"] as! String, addr: $0["addr"] as! String, location: $0["location"] as! String, section: $0["section_id"] as! String, scene: $0["scene_price"] as! String, presale: $0["presale_price"] as! String,tag: $0["tags"] as! String, province: $0["province"] as! String,city: $0["city"] as! String,coordinate: $0["coordinate"] as! String,love: $0["love"] as! String)
                        }
                        self.Expoes.addObjects(from: ExpolistJson)
                        
                        DispatchQueue.main.async(execute: {
                            
                        })
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                            
                        })
                    }else{
                        
                        self.Expoes.removeAllObjects()
                        Json.write(toFile: FilePath.FileExpo, atomically: true)
                        self.FuncUIExpo()
                    }
                    
                }
                self.tableView.doneRefresh()
            }else{
                self.tableView.doneRefresh()
            }
        }
    }
    
    func FuncUIExpo(){
        let SetExpoes = NSDictionary(contentsOfFile: FilePath.FileExpo)
        if SetExpoes != nil{
            
            
            let ExpolistJson = (SetExpoes!.value(forKey: "data") as! [NSDictionary]).map{
                ExpoListModel(name: $0["name"] as! String,cover: $0["cover"] as! String, description: $0["description"] as! String, eid: $0["eid"] as! String, start: $0["start_time"] as! String, end: $0["end_time"] as! String, addr: $0["addr"] as! String, location: $0["location"] as! String, section: $0["section_id"] as! String, scene: $0["scene_price"] as! String, presale: $0["presale_price"] as! String,tag: $0["tags"] as! String, province: $0["province"] as! String,city: $0["city"] as! String,coordinate: $0["coordinate"] as! String,love: $0["love"] as! String)
            }
            self.Expoes.addObjects(from: ExpolistJson)
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToExpoDetail" {
            let ExpoDetailPage:ExpoDetailController = segue.destination as! ExpoDetailController
            ExpoDetailPage.InfoExpo = InfoExpo
            ExpoDetailPage.InfoUser = InfoUser
            
        }
    }
    /////////////////////////分页////////////////
    var BoolErorr:Bool = false
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
