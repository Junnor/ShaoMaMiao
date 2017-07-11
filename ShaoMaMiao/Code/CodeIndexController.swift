//
//  CodeIndexController.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/10/14.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class CodeIndexController: UIViewController,QRCodeReaderViewControllerDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate {
    
    //这3个代理要实现它。1.扫描结果； 2.打开照相机； 3.取消

    var PublicNav: TabBar = TabBar()
    var Phones:[NSDictionary] = [NSDictionary]()
    
    //展会信息model
    var InfoExpo:ExpoModel = ExpoModel()
    var exhibitionModel : ExhibitionModel = ExhibitionModel()
    var SelectTicketId:[Int] = [Int]()
    var UpTicketId:String = "0"
    var BoolExpo:Bool = false
    var Codedes:[TicketData] = [TicketData]()
    var db:SQLiteDB!
//    let data : SaoMaCoreData = SaoMaCoreData()

    //是否提示，false是提示框会出现
    var boolWithOutOfInternetUpdate:Bool!
    
    //作废门票
    var invalidticketArray : NSMutableArray!
    
    @IBOutlet weak var BgTop: UIView!
    @IBOutlet weak var BgSearch: UISearchBar!
    @IBOutlet weak var TopNav: UIView!
    @IBOutlet weak var BgNav: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LabelVerson: UILabel!
    
    @IBOutlet weak var LabelNum: UILabel!
    @IBOutlet weak var LabelModel: UILabel!
    @IBOutlet weak var BtnDate: UIButton!
    @IBOutlet weak var BtnMode: UIButton!
    @IBOutlet weak var BtnExpo: UIButton!
    @IBOutlet weak var BtnPhone: UIButton!
    
    @IBOutlet weak var BtnCodes: UIButton!
    var NavTitle:String = "未绑定"
    var urlType:Int = 0

    override func viewDidAppear(_ animated: Bool) {
        self.clearAllNotice()
        self.boolWithOutOfInternetUpdate = false
        
        //选择的票Id
        if UserDefaults.standard.array(forKey: "selectticketid") != nil {
            self.SelectTicketId = (UserDefaults.standard.object( forKey: "selectticketid") as! NSArray) as! [Int]
            UpTicketId = ""
            for ticket in SelectTicketId {
                if UpTicketId.characters.count > 0 {
                    UpTicketId += ",\(ticket)"
                }else{
                    UpTicketId += "\(ticket)"
                }
            }
            self.getSCodeSelects()
        }
        Bottomnav.rootViewController.Neworking()
        self.urlType = UserDefaults.standard.integer(forKey: "urltype")
        btnUrlStatus(typeurl: self.urlType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BgTop.clipsToBounds = true
        self.urlType = UserDefaults.standard.integer(forKey: "urltype")
        FuncNav()
        TopNav.backgroundColor = Color.Bg
        let ExpoDic = NSDictionary(contentsOfFile: FilePath.ExpoInfo)
        db = SQLiteDB.shared
        _ = db.openDB()
        _ = db.execute(sql: "create table if not exists ticketdatas(tid integer primary key,scode varchar(20),tel varchar(20),time varchar(20),code varchar(128),model varchar(20),is_used varchar(5),use_count varchar(5),usedTime varchar(20))")
        
        
        Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
        
        self.Codedes = self.Codedes.reversed()
        
        if ExpoDic == nil {
            NavTitle = "未绑定"
            BoolExpo = false
            FilePath.FileRemoveAll(true)
        }else{
            BoolExpo = true
            
            InfoExpo.code_secret = ExpoDic!.value(forKey: "code_secret") as! String
            InfoExpo.secret = ExpoDic!.value(forKey: "secret") as! String
            InfoExpo.scan_secret = ExpoDic!.value(forKey: "scan_secret") as! String
            InfoExpo.scan_token = self.TheSecondCheck(scan_secret: InfoExpo.scan_secret, secret: InfoExpo.secret)
            
            InfoExpo.Name = ExpoDic!.value(forKey: "ename") as! String
            NavTitle = "\(InfoExpo.Name)"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    
        BgSearch.delegate = self
        
        title = "\(NavTitle)"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        PublicNav = Bundle.main.loadNibNamed("TabBar", owner: nil, options: nil)?.first as! TabBar
        if Body.Width == 320 {
            PublicNav.frame.size.width = 375
        }else{
            PublicNav.frame.size.width = Body.Width
        }
        PublicNav.tintColor = Color.Red
        PublicNav.frame.origin.y = 1
        
        BgNav.addSubview(PublicNav)

        //操作导航
        BtnDate.backgroundColor = Color.Red
        BtnDate.layer.cornerRadius = 3
        BtnDate.layer.shouldRasterize = true
        BtnDate.layer.rasterizationScale = UIScreen.main.scale

        BtnExpo.backgroundColor = Color.Green
        BtnExpo.layer.cornerRadius = 3
        BtnExpo.layer.shouldRasterize = true
        BtnExpo.layer.rasterizationScale = UIScreen.main.scale
        
        BtnMode.backgroundColor = Color.Blue
        BtnMode.layer.cornerRadius = 3
        BtnMode.layer.shouldRasterize = true
        BtnMode.layer.rasterizationScale = UIScreen.main.scale

        BtnPhone.backgroundColor = Color.Nav
        BtnPhone.layer.cornerRadius = 5
        BtnPhone.layer.shouldRasterize = true
        BtnPhone.layer.rasterizationScale = UIScreen.main.scale
        
        BtnCodes.backgroundColor = Color.Nav
        BtnCodes.layer.cornerRadius = 5
        BtnCodes.layer.shouldRasterize = true
        BtnCodes.layer.rasterizationScale = UIScreen.main.scale
        
        //模式判定
        LabelModel.textColor = Color.Font(1)
        LabelModel.layer.borderColor = Color.Borders.cgColor
        LabelModel.layer.borderWidth = 1.5
        LabelModel.layer.cornerRadius = 30
        LabelModel.layer.shouldRasterize = true
        LabelModel.layer.rasterizationScale = UIScreen.main.scale

        LabelNum.layer.borderColor = Color.Borders.cgColor
        LabelNum.layer.borderWidth = 1.5
        LabelNum.layer.cornerRadius = 30
        LabelNum.layer.shouldRasterize = true
        LabelNum.layer.rasterizationScale = UIScreen.main.scale
        FuncNum()
        FuncModel(UserDefaults.standard.integer(forKey: "model"))

        let verson:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        LabelVerson.text = "Ver \(verson) Nyato喵特"

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "手机号查询"
        }else{
            return "本地操作日志"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.Phones.count
        }else{
            switch TypeList {
            case .defalut:
                if Codedes.count > 200 {
                    return 200
                }else{
                    return Codedes.count
                }
            default:
                return Searches.count
            }

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.clearAllNotice()
        self.BgSearch.resignFirstResponder()
        if indexPath.section == 1 {
            let cellModel:TicketData = Codedes[indexPath.row]
            UIPasteboard.general.string = "\(cellModel.code)\n验证码：\(cellModel.scode)"
            self.successNotice("复制成功")
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:CodeCell? = tableView.dequeueReusableCell(withIdentifier: "CodeCell") as? CodeCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("CodeCell", owner: nil, options: nil)?.first! as? CodeCell
        }
        
        cell?.BtnCode.removeTarget(self, action: #selector(self.ButtonPhoneCode(_:)), for: UIControlEvents.touchUpInside)
        cell?.BtnCode.removeTarget(self, action: #selector(self.ButtonAgainCode(_:)), for: UIControlEvents.touchUpInside)
        
        if indexPath.section == 0 {
            //手机查询
            let cellModel:NSDictionary = self.Phones[indexPath.row]
            let code:String = cellModel.value(forKey: "code") as! String
            let usercound:String = cellModel.value(forKey: "use_count") as! String
            let names:String = cellModel.value(forKey: "ticket_name") as! String
            cell?.BtnCode.tag = indexPath.row
            cell?.Names.text = "\(names)\n\(code)"
            cell?.BtnCode.addTarget(self, action: #selector(self.ButtonPhoneCode(_:)), for: UIControlEvents.touchUpInside)

            if usercound == "0" {
                cell?.Des.text = "该票有效"
                cell?.BtnCode.isEnabled = true
                cell?.BtnCode.alpha = 1
                cell?.BtnCode.backgroundColor = Color.Red
                cell?.BtnCode.setTitle("提交验票", for: UIControlState())
                cell?.BtnCode.setTitleColor(UIColor.white, for: UIControlState())
            }else{
                cell?.Des.text = "该票已被使用过"
                cell?.BtnCode.isEnabled = false
                cell?.BtnCode.alpha = 0.5
                cell?.BtnCode.setTitle("已使用", for: UIControlState())
                cell?.BtnCode.backgroundColor = Color.Bg
                cell?.BtnCode.setTitleColor(UIColor.gray, for: UIControlState())
            }
            
        }else{

            switch TypeList {
            case .defalut:
                
                let cellModel:TicketData = Codedes[indexPath.row]
                let time:TimeInterval = TimeInterval(cellModel.usedTime)!
                let date:NSDate = NSDate(timeIntervalSince1970: time)
                let formatter:DateFormatter = DateFormatter()
                formatter.dateFormat = "MM-dd HH:mm"
                let timestr:String = formatter.string(from: date as Date)
                if cellModel.code == "" {
                    cell?.Names.text = "上次验票时间：\(timestr)    已扫：\(cellModel.use_count)次 \n\(cellModel.scode)"
                }else{
                    cell?.Names.text = "上次验票时间：\(timestr)    已扫：\(cellModel.use_count)次 \n\(cellModel.code)"
                }
                if cellModel.is_used == "1" {
                    cell?.BtnCode.isEnabled = false
                    cell?.BtnCode.setTitleColor(Color.Green, for: UIControlState())
                    cell?.BtnCode.setTitle("提交成功", for: UIControlState())
                    cell?.BtnCode.backgroundColor = Color.Bg
                
                }else if cellModel.is_used == "2"{
                    cell?.BtnCode.isEnabled = false
                    cell?.BtnCode.setTitleColor(Color.Red, for: UIControlState())
                    cell?.BtnCode.setTitle("提交成功", for: UIControlState())
                    cell?.BtnCode.backgroundColor = Color.Bg
                }else{
                    cell?.BtnCode.isEnabled = true
                    cell?.BtnCode.setTitleColor(UIColor.white, for: UIControlState())
                    cell?.BtnCode.backgroundColor = Color.Red
                    cell?.BtnCode.setTitle("提交验票", for: UIControlState())
                }
                
                cell?.BtnCode.tag = indexPath.row
                //提交验票事件
                cell?.BtnCode.addTarget(self, action: #selector(self.ButtonAgainCode(_:)), for: UIControlEvents.touchUpInside)
                
                if cellModel.model == "0" {
                    cell?.Des.text = "在线模式"
                }else if cellModel.model == "1" {
                    cell?.Des.text = "离线模式"
                }else{
                    cell?.Des.text = "算法模式"
                }
                
            case .search:
                let cellModel:TicketData = Searches[indexPath.row] as! TicketData
                let time:TimeInterval = TimeInterval(cellModel.usedTime)!
                
                let date:NSDate = NSDate(timeIntervalSince1970: time)
                let formatter:DateFormatter = DateFormatter()
                formatter.dateFormat = "MM-dd HH:mm"
                let timestr:String = formatter.string(from: date as Date)
                cell?.Names.text = "上次验票时间：\(timestr)    已扫：\(cellModel.use_count)次 \n\(cellModel.code)"
                
                if cellModel.model == "0" {
                    cell?.Des.text = "在线模式"
                }else if cellModel.model == "1" {
                    cell?.Des.text = "离线模式"
                }else{
                    cell?.Des.text = "算法模式"
                }
                
                if cellModel.is_used == "1" {
                    cell?.BtnCode.isEnabled = false
                    cell?.BtnCode.setTitleColor(Color.Green, for: UIControlState())
                    cell?.BtnCode.setTitle("提交成功", for: UIControlState())
                    cell?.BtnCode.backgroundColor = Color.Bg
                
                }else if cellModel.is_used == "2"{
                    cell?.BtnCode.isEnabled = false
                    cell?.BtnCode.setTitleColor(Color.Red, for: UIControlState())
                    cell?.BtnCode.setTitle("提交成功", for: UIControlState())
                    cell?.BtnCode.backgroundColor = Color.Bg
                }else{
                    cell?.BtnCode.isEnabled = true
                    cell?.BtnCode.setTitleColor(UIColor.white, for: UIControlState())
                    cell?.BtnCode.backgroundColor = Color.Red
                    cell?.BtnCode.setTitle("提交验票", for: UIControlState())
                }
                
                cell?.BtnCode.tag = indexPath.row
                cell?.BtnCode.addTarget(self, action: #selector(self.ButtonAgainCode(_:)), for: UIControlEvents.touchUpInside)
            }
        }
        return cell!
    }
    
    func FuncModel(_ type:Int){
        var Tips:String = "扫票模式\n在线"
        switch type {
        case 1:
            Tips = "扫票模式\n离线"
        case 2:
            Tips = "扫票模式\n算法"
        default:
            Tips = "扫票模式\n在线"
        }
        
        let myMutableString = NSMutableAttributedString(string: Tips, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14)])
        
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: Color.Green, range: NSRange(location:4,length:Tips.characters.count-4))
        
        myMutableString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 14.0), range: NSRange(location:4,length:Tips.characters.count-4))
        
        LabelModel.attributedText = myMutableString

    }
    
    func FuncNum(){
        let Tips:String = "操作日志\n\(Codedes.count)条"
        let myMutableString = NSMutableAttributedString(string: Tips, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14)])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: Color.Red, range: NSRange(location:4,length:Tips.characters.count-5))
        myMutableString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 24.0), range: NSRange(location:4,length:Tips.characters.count-5))
        LabelNum.attributedText = myMutableString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func FuncNav() {
        self.navigationController?.navigationBar.barTintColor = Color.Nav
        self.navigationController?.navigationBar.tintColor = Color.Font(0)
        let NavTitleColor:NSDictionary = NSDictionary(object: Color.Font(0),forKey: NSForegroundColorAttributeName as NSCopying)
        self.navigationController?.navigationBar.titleTextAttributes = NavTitleColor as? [String : AnyObject]
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToModel" {
            let Page:ModelController = segue.destination as! ModelController
            Page.InfoExpo = InfoExpo
        }
    }
 
    @IBAction func ButtonModel(_ sender: UIButton) {
        if BoolExpo {
            
            self.performSegue(withIdentifier: "ToModel", sender: self)
        
        }else{
            
            self.infoNotice("请先绑定漫展")
            
        }
    }
    
    
    //扫码扫票
    
    lazy var QRreader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {$0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true})
    
    //MARK: 最底下那个扫码按钮
    @IBAction func ButtonCode(_ sender: UIButton) {
        if self.Phones.count > 0 {
            self.Phones.removeAll()
            self.tableView.reloadData()
        }
        
        BoolTipCode = true
        ExpoCodeBool = false
        if BoolExpo {
            if UpTicketId == "0" {
                self.infoNotice("还未选择门票")
                self.performSegue(withIdentifier: "ToModel", sender: self)
            }else{
                //功能
                FuncCode()
            }
        }else{
            self.infoNotice("请先绑定漫展")
        }
    }
    
//    func TipBund(){
//        let AlertBund:UIAlertController = UIAlertController(title: "是否重新绑定漫展？", message: "切换漫展会重新清空本地数据，是否继续", preferredStyle: UIAlertControllerStyle.Alert)
//        let BtnCancel:UIAlertAction = UIAlertAction(title: "取 消", style: UIAlertActionStyle.Cancel, handler: nil)
//        
//        let BtnSubmit:UIAlertAction = UIAlertAction(title: "重新绑定", style: UIAlertActionStyle.Destructive) { (action) in
//            self.ExpoCodeBool = true
//            self.UpTicketId = "0"
//            FilePath.FileRemoveAll(true)
//            self.db.execute("delete from t_ticket")
//            self.Codedes = TicketData().allRows("tid ASC")
//            self.tableView.reloadData()
//            self.FuncCode()
//
//        }
//        let BtnModel:UIAlertAction = UIAlertAction(title: "先去提交扫码数据", style: UIAlertActionStyle.Default) { (action) in
//            self.performSegueWithIdentifier("ToModel", sender: self)
//        }
//        AlertBund.addAction(BtnModel)
//        AlertBund.addAction(BtnSubmit)
//        AlertBund.addAction(BtnCancel)
//        Bottomnav.rootViewController.presentViewController(AlertBund, animated: true, completion: nil)
//    }
    
    
    //MARK:相机的扫描
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
                        
                        //ExpoCodeBool是否绑定漫展
                        if self.ExpoCodeBool {
                            //未绑定漫展的，重新扫码获取新漫展信息
                            self.ExpoGet(result!.value)
                        }else{
                            //已绑定漫展的
                            self.FuncCodeRead(result!.value)
                           
                        }
                       
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
    
    //代理之一！！！！   扫描结果
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult){
    
    
    }
    
    //MARK:3种扫码后的选择
    func FuncCodeRead(_ result:String){
        //在线模式
        if UpTicketId == "0" {
            self.errorNotice("还没有选择门票")

            self.performSegue(withIdentifier: "ToModel", sender: self)
            
        }else{
            if UserDefaults.standard.integer(forKey: "model") == 0 {
                CodeVerify(result, ticketId: UpTicketId,status: true,index: 0)
                
            }else{
                //首先进行数据库查询是否存在该废票的判断
                if isExistsModel(code: result) {
                    self.FuncTipsCode("票种不符!!", intro: "该票已是作废的门票",status: self.BoolTipCode)
                }else{
                    CodeRecording(result)
                }
            }
        }
    }
    //检测废票
    func isExistsModel(code: String)->Bool{
        var status:Bool = false
        for ticketes in self.Tickets {
            let savecode:String = (ticketes as! NSDictionary).value(forKey: "code") as! String
            if savecode == code {
                status = true
                break
            }
        }
        return status
    }
    //MARK:在线模式--扫票result传入(重做)
    func onlineModel(ticketCode:String, status: Bool,index: Int) {
        var BoolCodeNew:Bool = true
        var usedTime:TimeInterval = 0
        var use_count: Int = 0
        //遍历查找是否存在该票??
        for ticketes in self.Codedes {
            if ticketCode == ticketes.code || ticketCode == ticketes.scode {
                BoolCodeNew = false
                use_count = Int(ticketes.use_count)! + 1
                ticketes.use_count = "\(use_count)"
                usedTime = TimeInterval(ticketes.time) ?? NSDate().timeIntervalSince1970
                if ticketes.save() > 0 {
                    print("保存成功")
                }else{
                    print("保存失败")
                }
                break
            }
        }
        if BoolCodeNew {
            //新票
            let ticketId = UpTicketId
            QRreader.pleaseWait()
            let ExpoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "verify_ecode", type: urlType)
            
            Alamofire.request(ExpoURL, method: HTTPMethod.post,parameters:["scan_token":self.InfoExpo.scan_token,"code":"\(ticketCode)","ticket_id":"\(ticketId)","secret":self.InfoExpo.secret]).responseJSON { (response) in
                
                self.QRreader.clearAllNotice()
                if let Json = response.result.value as? NSDictionary{
                    //                print("获取门票信息\(Json)")
                    let result:Int = Json.value(forKey: "status") as! Int
                    if result == 1 {
                        let names:String = Json.value(forKeyPath: "data.ticket_name") as! String
                        let use_count:Int = Json.value(forKeyPath: "data.use_count") as! Int
                        
                        let Titles:String = Json.value(forKey: "info") as! String
                        
                        let usedTime:TimeInterval = TimeInterval(Json.value(forKeyPath: "data.usedTime") as! String)!
                        
                        let usedtimeStr:String = self.getNowTimeString(usedtime: usedTime) as String
                        
                        if status {
                            var BoolCodeNew:Bool = true
                            
                            for ticketes in self.Codedes {
                                
                                if ticketCode == ticketes.code || ticketCode == ticketes.scode {
                                    //已经存在，更新ticketes内容
                                    BoolCodeNew = false
                                    ticketes.use_count = "\(use_count)"
                                    ticketes.model = "\(UserDefaults.standard.integer(forKey:"model"))"
                                    ticketes.time = "\(usedTime)"
                                    ticketes.scode = Json.value(forKeyPath: "data.scode") as! String
                                    
                                    ticketes.tel = Json.value(forKeyPath: "data.tel") as! String
                                    
                                    ticketes.is_used = "1"
                                    ticketes.code = "\(ticketCode)"
                                    if ticketes.save() > 0 {
                                        print("保存成功")
                                    }
                                    break
                                }
                            }
                            
                            //ticket还未存在时
                            if use_count == 1 {
                                BoolCodeNew = true
                            }else{
                                BoolCodeNew = false
                            }
                            
                            if BoolCodeNew {
                                let ticketmodel = TicketData()
                                ticketmodel.code = "\(ticketCode)"
                                ticketmodel.model = "\(UserDefaults.standard.integer(forKey: "model"))"
                                ticketmodel.usedTime = "\(usedTime)"
                                ticketmodel.scode = Json.value(forKeyPath: "data.scode") as! String
                                ticketmodel.tel = Json.value(forKeyPath: "data.tel") as! String
                                ticketmodel.is_used = "1"
                                ticketmodel.use_count = "\(use_count)"
                                if ticketmodel.save() > 0 {
                                    print("保存成功")
                                }else{
                                    print("保存失败")
                                }
                                if index != -1 {
                                    self.successNotice("扫码成功\n第1次使用")
                                    self.FuncCodeTime()
                                }
                            }else{
                                Bottomnav.rootViewController.AudioTip()
                                if index != -1 {
                                    self.FuncTipsCode("\(Titles)", intro: "\(names)\n验票次数：\(use_count)次\n上次验票时间：\(usedtimeStr)",status: self.BoolTipCode)
                                }
                            }
                            self.FuncNum()
                            
                        }else{
                            self.Codedes[index].code = "\(ticketCode)"
                            self.Codedes[index].model = "\(UserDefaults.standard.integer(forKey:"model"))"
                            self.Codedes[index].usedTime = "\(usedTime)"
                            self.Codedes[index].scode = Json.value(forKeyPath: "data.scode") as! String
                            self.Codedes[index].tel = Json.value(forKeyPath: "data.tel") as! String
                            self.Codedes[index].is_used = "1"
                            self.Codedes[index].use_count = "\(use_count)"
                            if self.Codedes[index].save() > 0 {
                                print("保存成功")
                            }else{
                                print("保存失败")
                            }
                            
                            
                        }
                        
                    }else{
                        let info:String = Json.value(forKey: "info") as! String
                        
                        if index != -1 {
                            self.FuncTipsCode("验票提示!!", intro: "\(info)",status: self.BoolTipCode)
                        }
                        self.ErrorSave(ticketCode)
                        
                    }
                    self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
                    self.Codedes = self.Codedes.reversed()
                    self.tableView.reloadData()
                    self.FuncNum()
                }
            }
            
        }else{
            //已验过
            let usedtimeStr :String = self.getNowTimeString(usedtime: usedTime) as String
            Bottomnav.rootViewController.AudioTip()
            self.FuncTipsCode("本机已经扫过", intro: "验票次数：\(use_count)次\n上次验票时间：\(usedtimeStr)",status: self.BoolTipCode)
            self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
            self.Codedes = self.Codedes.reversed()
            self.FuncNum()
        }

        
    }
    
    //MARK:开辟一条条新线程提交
    func AsyncUpData() {
        DispatchQueue.global().async {
            self.boolWithOutOfInternetUpdate = true
            self.recordOutOfInternetUpdate()
            
        }
    }
    
    //MARK:手机查询提交
    func ButtonPhoneCode(_ sender:UIButton){
        BoolTipCode = false
        let cellModel:NSDictionary = self.Phones[sender.tag]
        let code:String = cellModel.value(forKey: "code") as! String
        FuncCodeRead(code)
        self.Phones.remove(at: sender.tag)
        self.tableView.reloadData()
    }

    //MARK:重新提交-除了手机输入的那部分
    func ButtonAgainCode(_ sender:UIButton){
        BoolTipCode = false
        self.Neworking()
        self.recordOutOfInternetUpdate(type: 2, tag: sender.tag)
        
        
//        switch TypeList {
//            case .defalut:
//                
//                    let cellModel:TicketData = Codedes[sender.tag]
//                    
//                    CodeVerify(cellModel.code, ticketId: UpTicketId,status: false,index: sender.tag)
//                    break
//            case .search:
//           
//                let cellModel:TicketData = Searches[sender.tag] as! TicketData
//                    CodeVerify(cellModel.code, ticketId: UpTicketId,status: false,index: sender.tag)
//            
//        }
    }
    
    //重新提交-手机输入的那部分
    func ButtonAgainCodeForPhone(_ sender:UIButton){
        BoolTipCode = false
        
        let dic : NSDictionary = Phones[sender.tag]
        
        CodeVerify(dic.object(forKey: "code") as! String, ticketId: UpTicketId,status: false,index: sender.tag)
    }
    
    //提示
    func FuncTips(_ title:String,intro:String){
//        self.QRreader.dismissViewControllerAnimated(true, completion: nil)
        let AlertTips:UIAlertController = UIAlertController(title: "\(title)", message: "\(intro)", preferredStyle: UIAlertControllerStyle.alert)
        let BubSumit:UIAlertAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.destructive, handler: nil)
        AlertTips.addAction(BubSumit)
        QRreader.present(AlertTips, animated: true, completion: nil)
    }
    
    func FuncTipsCode(_ title:String,intro:String,status:Bool){
        //        self.QRreader.dismissViewControllerAnimated(true, completion: nil)
        let AlertTips:UIAlertController = UIAlertController(title: "\(title)", message: "\(intro)", preferredStyle: UIAlertControllerStyle.alert)
        let BubSumit:UIAlertAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.destructive){(action) in
            if status {
                self.QRreader.startScanning()
            }else{
                
            }
        }
        AlertTips.addAction(BubSumit)
        if status {
            self.QRreader.present(AlertTips, animated: true, completion: nil)
        }else{
            Bottomnav.rootViewController.present(AlertTips, animated: true, completion: nil)
        }
    }

    //MARK:验证码验票
    func FuncTextCodeSubmit(){
        BoolTipCode = false
        if BoolExpo {
            let AlertBund:UIAlertController = UIAlertController(title: "输入验证码", message: "请输入门票验证码提交进行验证", preferredStyle: UIAlertControllerStyle.alert)
            AlertBund.addTextField { (textinput) in
                textinput.keyboardType = UIKeyboardType.numbersAndPunctuation
                textinput.autocapitalizationType = .allCharacters
            }
            let BtnCancel:UIAlertAction = UIAlertAction(title: "取 消", style: UIAlertActionStyle.cancel) { (action) in
            }
            let BtnSubmit:UIAlertAction = UIAlertAction(title: "提交验证", style: UIAlertActionStyle.destructive) { (action) in
                let result:String = (AlertBund.textFields?.first?.text)!
                self.BoolTipCode = false
                self.CodeVerify(result, ticketId: self.UpTicketId,status: true,index: 0)
            }
            AlertBund.addAction(BtnSubmit)
            AlertBund.addAction(BtnCancel)
            Bottomnav.rootViewController.present(AlertBund, animated: true, completion: nil)
        }else{
            self.infoNotice("请先绑定漫展")
        }
        self.PublicNav.selectedItem = nil
    }
    
    //退出扫描
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        self.clearAllNotice()
        reader.dismiss(animated: true, completion: nil)
    }
    
    //MARK:绑定漫展
    var ExpoCodeBool:Bool = false
    var ExpoBund:Bool = false
    @IBAction func ButtonExpo(_ sender: UIButton) {
        let ExpoDic = NSDictionary(contentsOfFile: FilePath.ExpoInfo)
        
        if ExpoDic == nil {
            ActionExpo()
        }else{
            let AlertExpo:UIAlertController = UIAlertController(title: "您已绑定漫展是否切换？", message: "切换漫展将会抹除当前扫码记录，请谨慎操作", preferredStyle: UIAlertControllerStyle.alert)
            let BtnCancel:UIAlertAction = UIAlertAction(title: "放弃操作", style: UIAlertActionStyle.cancel, handler: nil)
            let BtnSubmit:UIAlertAction = UIAlertAction(title: "重新绑定", style: UIAlertActionStyle.destructive, handler: { (action) in
            
                //删除旧的假票
//                self.data.removeAllModel()
//                self.invalidticketArray = self.data.getPerson()
                self.BoolExpo = false
                self.ActionExpo()
                if self.Codedes.count != 0 {
                    self.recordOutOfInternetUpdate()
                }
               
            })
            AlertExpo.addAction(BtnCancel)
            AlertExpo.addAction(BtnSubmit)
            Bottomnav.rootViewController.present(AlertExpo, animated: true, completion: nil)
        }
    }
    
    //MARK:提交数据按钮
//    func UpData(){
//        BoolTipCode = false
//        var BoolUp:Bool = false
//        for ticket in Codedes {
//            if ticket.is_used == "0" {
//                BoolUp = true
//                if ticket.code.characters.count < 126 {
//                    self.CodeVerify(ticket.scode, ticketid: self.UpTicketId,stauts: true,index: -1)
//                }else{
//                    self.CodeVerify(ticket.code, ticketid: self.UpTicketId,stauts: true,index: -1)
//                }
//            }
//        }
//        if BoolUp {
//            self.successNotice("提交完成\n请确认数据")
//        }else{
//            self.infoNotice("当前的票都是验过的")
//        }
//    }
    
    func ActionExpo(){
        let OperationSheet:UIActionSheet = UIActionSheet()
        OperationSheet.addButton(withTitle: "取 消")
        OperationSheet.addButton(withTitle: "扫码绑定")
        OperationSheet.addButton(withTitle: "输入绑定")
        OperationSheet.cancelButtonIndex = 0
        OperationSheet.destructiveButtonIndex = 1
        OperationSheet.actionSheetStyle = .blackTranslucent
        OperationSheet.delegate = self
        OperationSheet.show(in: self.view)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }

    
    //MARK:扫码绑定协议代理
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            //扫码绑定

            ExpoCodeBool = true
            FuncCode()
        }else if buttonIndex == 2{
            UserDefaults.standard.set(2, forKey: "model")

            let AlertTips:UIAlertController = UIAlertController(title: "请输入绑定码", message: "请输入相关的绑定码绑定漫展", preferredStyle: UIAlertControllerStyle.alert)
            AlertTips.addTextField(configurationHandler: { (textinput) in
                textinput.keyboardType = .numbersAndPunctuation
            })
            let BubCancel:UIAlertAction = UIAlertAction(title: "取 消", style: UIAlertActionStyle.cancel, handler: nil)
            let BtnBubSmit:UIAlertAction = UIAlertAction(title: "绑定漫展", style: UIAlertActionStyle.default, handler: { (action) in
                let code:String = (AlertTips.textFields?.first?.text)!
                self.ExpoGet(code)
            })
            AlertTips.addAction(BubCancel)
            AlertTips.addAction(BtnBubSmit)
            Bottomnav.rootViewController.present(AlertTips, animated: true, completion: nil)
        }
        self.ExpoCodeBool = true
        self.UpTicketId = "0"
        self.title = "未绑定"
        FilePath.FileRemoveAll(true)
        if self.db.execute(sql: "delete from ticketdatas") > 0 {
            print("清空数据成功")
        }else{
            print("清空数据失败")
        }
        self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]

        self.FuncNum()
        self.tableView.reloadData()
    }
    
    //临时对应扫票结果请求的字典
    var Expoinfo:NSDictionary = NSDictionary()
    
    //扫票，且绑定漫展,传入扫票结果的值，result!.value
    func ExpoGet(_ code:String){
        self.QRreader.dismiss(animated: true, completion: nil)
        self.pleaseWait()
        let ExpoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "get_einfo", type: self.urlType)

        Alamofire.request(ExpoURL, method: HTTPMethod.post,parameters:["secret":code]).responseJSON { (response) in
            

            self.clearAllNotice()
            if let Json = response.result.value as? NSDictionary{
                let result:Int = Json.value(forKey: "result") as! Int
                if result == 1 {
//                    print("获取漫展信息\(Json)")

                    self.Expoinfo = Json.value(forKey: "data") as! NSDictionary
                    let exhibitionSecret :String = self.Expoinfo.value(forKey: "secret") as! String

                    UserDefaults.standard.set(exhibitionSecret, forKey: "exhibitionSecret")
                    
                    self.Expoinfo.write(toFile: FilePath.ExpoInfo, atomically: true)
                    
                    self.InfoExpo.scan_secret = Json.value(forKeyPath: "data.scan_secret") as! String
                    self.InfoExpo.code_secret = Json.value(forKeyPath: "data.code_secret") as! String
                    self.InfoExpo.secret = Json.value(forKeyPath: "data.secret") as! String

                    self.InfoExpo.scan_token = self.TheSecondCheck(scan_secret: self.InfoExpo.scan_secret, secret: self.InfoExpo.secret)
                    self.InfoExpo.Name = Json.value(forKeyPath: "data.ename") as! String
                    
                    self.title = "\(self.InfoExpo.Name)"
                
                    self.BoolExpo = true
                    self.UpTicketId = "0"
                    self.successNotice("绑定成功")
                    
                    //作废门票存储
                    self.invalidTicketOrder()
                    
                    UserDefaults.standard.set(2, forKey: "model")

                    self.performSegue(withIdentifier: "ToModel", sender: self)
                }else{
                    self.errorNotice("绑定失败\n二维码正确？")
                }
            }
        }
    }
    
    //在线扫码
    func CodeVerify(_ ticketCode:String,ticketId:String,status:Bool,index:Int){
        
        QRreader.pleaseWait()
       
        let ExpoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "verify_ecode", type: self.urlType)
        
        Alamofire.request(ExpoURL, method: HTTPMethod.post,parameters:["scan_token":self.InfoExpo.scan_token,"code":"\(ticketCode)","ticket_id":"\(ticketId)","secret":self.InfoExpo.secret]).responseJSON { (response) in
            
            self.QRreader.clearAllNotice()
            if let Json = response.result.value as? NSDictionary{
//                print("获取门票信息\(Json)")
                let result:Int = Json.value(forKey: "status") as! Int
                if result == 1 {
                    let names:String = Json.value(forKeyPath: "data.ticket_name") as! String
                    let use_count:Int = Json.value(forKeyPath: "data.use_count") as! Int
                    
                    let Titles:String = Json.value(forKey: "info") as! String
                    
                    let usedTime:TimeInterval = TimeInterval(Json.value(forKeyPath: "data.usedTime") as! String)!
                    
                    let usedtimeStr:String = self.getNowTimeString(usedtime: usedTime) as String
                    
                    if status {
                        var BoolCodeNew:Bool = true
                        
                        for ticketes in self.Codedes {
                            
                            if ticketCode == ticketes.code || ticketCode == ticketes.scode {
                                //已经存在，更新ticketes内容
                                BoolCodeNew = false
                                ticketes.use_count = "\(use_count)"
                                ticketes.model = "\(UserDefaults.standard.integer(forKey:"model"))"
                                ticketes.usedTime = "\(usedTime)"
                                ticketes.scode = Json.value(forKeyPath: "data.scode") as! String
                                
                                ticketes.tel = Json.value(forKeyPath: "data.tel") as! String
                                
                                ticketes.is_used = "1"
                                ticketes.code = "\(ticketCode)"
                                if ticketes.save() > 0 {
                                    print("保存成功")
                                }else{
                                    print("保存失败")
                                }

                                break
                            }
                        }
                        
                        //ticket还未存在时
                        if use_count == 1 {
                            BoolCodeNew = true
                        }else{
                            BoolCodeNew = false
                        }
                        
                        if BoolCodeNew {
                            let ticketmodel = TicketData()
                            ticketmodel.code = "\(ticketCode)"
                            ticketmodel.model = "\(UserDefaults.standard.integer(forKey: "model"))"
                            ticketmodel.usedTime = "\(Int(Date().timeIntervalSince1970))"
                            ticketmodel.scode = Json.value(forKeyPath: "data.scode") as! String
                            ticketmodel.tel = Json.value(forKeyPath: "data.tel") as! String
                            ticketmodel.is_used = "1"
                            ticketmodel.use_count = "\(use_count)"
                            
                            if ticketmodel.save() > 0 {
                                print("保存成功")
                            }else{
                                print("保存失败")
                            }

                            if index != -1 {
                                self.successNotice("扫码成功", autoClear: true)
                                self.successNotice("扫码成功\n第1次使用")
                                self.FuncCodeTime()
                            }
                        }else{
                            Bottomnav.rootViewController.AudioTip()
                            if index != -1 {
                                self.FuncTipsCode("\(Titles)", intro: "\(names)\n验票次数：\(use_count)次\n上次验票时间：\(usedtimeStr)",status: self.BoolTipCode)
                            }
                        }
                        self.FuncNum()
                        
                    }else{
                        self.Codedes[index].code = "\(ticketCode)"
                        self.Codedes[index].model = "\(UserDefaults.standard.integer(forKey:"model"))"
                        self.Codedes[index].usedTime = "\(usedTime)"
                        self.Codedes[index].scode = Json.value(forKeyPath: "data.scode") as! String
                        self.Codedes[index].tel = Json.value(forKeyPath: "data.tel") as! String
                        self.Codedes[index].is_used = "1"
                        self.Codedes[index].use_count = "\(use_count)"
                        if self.Codedes[index].save() > 0 {
                            print("保存成功")
                        }else{
                            print("保存失败")
                        }

                        
                    }
                    
                }else{
                    let info:String = Json.value(forKey: "info") as! String
                    
                    if index != -1 {
                        self.FuncTipsCode("验票提示!!", intro: "\(info)",status: self.BoolTipCode)
                    }
                    self.ErrorSave(ticketCode)
                    
                }
                self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
                self.Codedes = self.Codedes.reversed()
                self.tableView.reloadData()
                self.FuncNum()
            }else{
                self.QRreader.dismiss(animated: true, completion: { 
                    self.errorNotice("网络不佳请更换模式")
                })
            }
        }
    }
    
    var BoolTipCode:Bool = true
//    //离线验票
//    func CodeOutLine(_ code:String){
//        let Tickets = NSDictionary(contentsOfFile: FilePath.TicketList)
//        if Tickets != nil {
//            var BoolCodeNew:Bool = true
//            var use_count: Int = 0
//            var usedtimeStr:String = ""
//            var usedtime:TimeInterval = 0
//            //已验数据验证
//            for ticketes in self.Codedes {
//                if code == ticketes.code || code == ticketes.scode {
//                    BoolCodeNew = false
//                    use_count = Int(ticketes.use_count)! + 1
//                    ticketes.use_count = "\(use_count)"
//                    usedtime = TimeInterval(ticketes.time)!
//                    let resulttt : Int = ticketes.save()
//                    self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
//
////                    self.Codedes = TicketData().allRows("tid ASC")
//                    self.Codedes = self.Codedes.reversed()
//                    self.tableView.reloadData()
//                    break
//                }
//            }
//            if BoolCodeNew {
//                //缓存数据验证
//                var BoolSaveNew:Bool = false
//                var Tid:String = "0"
//                var Times:String = "0"
//                for ticketes in Bottomnav.rootViewController.Tickets {
//                    let savecode:String = (ticketes as AnyObject).value(forKey: "code") as! String
//                    let savescode:String = (ticketes as AnyObject).value(forKey: "scode") as! String
//                    
//                    Tid = (ticketes as AnyObject).value(forKey: "id") as! String
//                    if code == savecode || code == savescode {
//                        let ticketmodel = TicketData()
//                        ticketmodel.code = savecode
//                        ticketmodel.scode = savescode
//                        ticketmodel.model = "\(UserDefaults.standard.integer(forKey: "model"))"
//                        ticketmodel.time = "\(Int(Date().timeIntervalSince1970))"
//                        let statrtime:Int = Int((ticketes as AnyObject).value(forKeyPath: "use_count") as! String)! + 1
//                        ticketmodel.use_count = "\(statrtime)"
//                        Times = "\(statrtime)"
//                        ticketmodel.save()
//                        self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
//
////                        self.Codedes = TicketData().allRows("tid ASC")
//                        self.Codedes = self.Codedes.reversed()
//                        self.tableView.reloadData()
//                        BoolSaveNew = true
//                        break
//                    }
//                }
//                if BoolSaveNew {
//                    //票种验证
//                    var BoolTicket:Bool = false
//                    for ticketid in SelectTicketId {
//                        if Tid == "\(ticketid)" {
//                            BoolTicket = true
//                        }
//                    }
//                    if BoolTicket {
//                        if Int(Times)! > 1 {
//                            self.FuncTipsCode("该票已扫过", intro: "验票次数：\(Times)次\n上次验票时间：--",status: self.BoolTipCode)
//                            ErrorSave(code)
//                        }else{
//                            self.successNotice("扫码成功\n第1次使用")
//                            self.FuncCodeTime()
//                        }
//                    }else{
//                        self.FuncTipsCode("票种不符!!", intro: "该票种不在当前验票范围内",status: self.BoolTipCode)
//                        self.ErrorSave(code)
//                    }
//
//                }else{
//                    self.FuncTipsCode("没有该票数据", intro: "更新本地缓存数据试下，或者更换记录模式",status: self.BoolTipCode)
//                    ErrorSave(code)
//                }
//            }else{
//                //开始
//                let date:NSDate = NSDate(timeIntervalSince1970: usedtime)
//                // 创建时间戳
//                let formatter:DateFormatter = DateFormatter()
//                
//                // 设置日期格式，以字符串表示的日期形式的格式
//                formatter.dateFormat = "MM-dd HH:mm"
//                
//                // 转换成指定的格式
//                let usedtimeStr:String = formatter.string(from: date as Date)
//                
//                self.FuncTipsCode("本机已经扫过", intro: "验票次数：\(times)次\n上次验票时间：\(usedtimeStr)",status: self.BoolTipCode)
//                ErrorSave(code)
//
//            }
//        }else{
//            self.infoNotice("请先缓存数据")
//            self.performSegue(withIdentifier: "ToModel", sender: self)
//        }
//    }
    
    //异常数据
    func ErrorSave(_ code:String){
        Bottomnav.rootViewController.AudioTip()
        let nowtime:TimeInterval = Date().timeIntervalSince1970
        let codes:String = "\(code)-\(nowtime)"
        Bottomnav.rootViewController.Errors.add(codes)
        Bottomnav.rootViewController.Errors.write(toFile: FilePath.Error, atomically: true)

    }
    
    //MARK:算法式验票   (里面包含3重加密验证)
    func CodeRecording(_ code:String){
        //code为200位的字符串
        if code.characters.count < 26 {
            //短码二维码
            self.verifySCode(code: code)
        }else if code.characters.count == 126 {
            //长码二维码
            //第一层验证
            //第三十个的字符？？
            let StartThreeTen = code.characters.index(code.startIndex, offsetBy: 30)
            //从0到30位的自负截取
            let StartThreeTenStr = code.substring(to: StartThreeTen)

            //第十位的字符？？
            let OneStartTen = code.characters.index(code.startIndex, offsetBy: 10)
            
            //StartThreeTenStr的倒数第15到StartThreeTenStr的正数第25
            let OneIndex: Range = Range(StartThreeTenStr.characters.index(StartThreeTenStr.endIndex, offsetBy: -15) ..< StartThreeTenStr.characters.index(StartThreeTenStr.startIndex, offsetBy: 25))
            //StartThreeTenStr的前10和StartThreeTenStr的15-25拼接
            let OneCode:String = "\(StartThreeTenStr.substring(to: OneStartTen))\(StartThreeTenStr.substring(with: OneIndex))"

            //code的第94号字符
            let JiuLiu = code.characters.index(code.startIndex, offsetBy: 94)
            //取code的第94号字符之后的字符串
            let OneCodeStr:String = code.substring(from: JiuLiu)

            //第二层验证
            if OneCodeStr == OneCode.md5 {
                //字符范围：64----倒数96
                let ThreeIndex: Range = Range(code.characters.index(code.endIndex, offsetBy: -96) ..< code.characters.index(code.startIndex, offsetBy: 62))
                
                //CodeThree字符串为code的64---104位字符串
                let CodeThreeStr:String = code.substring(with: ThreeIndex)

                let ExpoCode:String = self.InfoExpo.code_secret
                
                if ExpoCode == CodeThreeStr {
                    var BoolTwo:Bool = false
                    let TwoIndex: Range = Range(code.characters.index(code.endIndex, offsetBy: -64) ..< code.characters.index(code.startIndex, offsetBy: 94))
                    // CodeTwo 为范围code的94 - 136的字符串
                    let CodeTwo:String = code.substring(with: TwoIndex)

                    for ticketid in SelectTicketId {
                        let ticketStr:String = "\(ticketid)"
                        if ticketStr.md5 == "\(CodeTwo)" {
                            BoolTwo = true
                        }
                    }
                    
                    //第三层验证
                    if BoolTwo {
                        var BoolCodeNew:Bool = true
                        var use_count: Int = 0
                        var usedTime:TimeInterval = 0
                        //遍历查找是否存在该票
                        for ticketes in self.Codedes {
                            if code == ticketes.code || code == ticketes.scode {
                                BoolCodeNew = false
                                use_count = Int(ticketes.use_count)! + 1
                                ticketes.use_count = "\(use_count)"
                                usedTime = TimeInterval(ticketes.usedTime)!
//                                ticketes.usedTime = "\(Int(Date().timeIntervalSince1970))"

                                if ticketes.save() > 0 {
                                    print("保存成功")
                                }else{
                                    print("保存失败")
                                }

                                break
                            }
                        }
                        //这就是不存在该票，新加入的票
                        if BoolCodeNew {
                            let ticketmodel = TicketData()

                            ticketmodel.code = "\(code)"
                            ticketmodel.use_count = "1"
                            ticketmodel.scode = ""

                            ticketmodel.tel = "0"
                            ticketmodel.is_used = "0"
                            ticketmodel.model = "\(UserDefaults.standard.integer(forKey: "model"))"
                            ticketmodel.usedTime = "\(Int(Date().timeIntervalSince1970))"
                            usedTime = TimeInterval(ticketmodel.usedTime)!
                            
                            use_count = Int(ticketmodel.use_count)!
                            if ticketmodel.save() > 0 {
                                print("保存成功")
                            }else{
                                print("保存失败")
                            }

                            
                            self.successNotice("扫码成功\n第1次使用")
                            self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]

                            self.Codedes = self.Codedes.reversed()
                            self.FuncCodeTime()
                            self.FuncNum()
                        }else{
                            
                            let usedtimeStr :String = self.getNowTimeString(usedtime: usedTime) as String
                            
                            Bottomnav.rootViewController.AudioTip()
                            self.FuncTipsCode("本机已经扫过", intro: "验票次数：\(use_count)次\n上次验票时间：\(usedtimeStr)",status: self.BoolTipCode)
                            self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
                            self.Codedes = self.Codedes.reversed()
                            self.FuncNum()
                        }
                    }else{
                        self.FuncTipsCode("票种不符!!", intro: "该票种不在当前验票范围内",status: self.BoolTipCode)
                        self.ErrorSave(code)
                    }
                    
                }else{
                    self.FuncTipsCode("该票不属于当前漫展!!", intro: "如有问题，请反馈客服进行查证",status: self.BoolTipCode)
                    self.ErrorSave(code)
                }

            }else{
//                QRreader.startScanning()
                self.FuncTipsCode("不是喵特门票!!", intro: "有可能是微票等其他渠道的电子票",status: self.BoolTipCode)
                self.ErrorSave(code)
            }
            self.tableView.reloadData()

        }else{
            //字符串不是126位
            self.FuncTipsCode("不是喵特门票!!", intro: "有可能是微票等其他渠道的电子票",status: self.BoolTipCode)
            self.ErrorSave(code)
        }
        
    }
    //短码-取出要对比的短码
    var sCode:NSMutableArray = NSMutableArray()
    func getSCodeSelects(){
        let sCodeSave = NSDictionary(contentsOfFile: FilePath.sCodeData)
        if sCodeSave != [:] && sCodeSave != nil {
            if Bottomnav.rootViewController.sCodes.count == 0 {
                Bottomnav.rootViewController.sCodes = sCodeSave?.value(forKey: "data") as! [NSDictionary]
            }
            self.sCode.removeAllObjects()
            for ticketId in self.SelectTicketId {
                for scodes in Bottomnav.rootViewController.sCodes {
                    let scodeTicketId:Int = Int(scodes.value(forKey: "ticket_id") as! String) ?? 0
                    if ticketId == scodeTicketId && scodeTicketId != 0 {
                        let codes:NSArray = scodes.value(forKey: "scode") as! NSArray
                        self.sCode.addObjects(from: codes as! [Any])
                        break
                    }
                }
            }
        }
    }
    //短码-对比验证
    func verifySCode(code:String){
        var BoolCodeNew:Bool = true
        var usedTime:TimeInterval = 0
        var use_count: Int = 0
        //遍历查找是否存在该票
        for ticketes in self.Codedes {
            if code == ticketes.code || code == ticketes.scode {
                BoolCodeNew = false
                use_count = Int(ticketes.use_count)! + 1
                ticketes.use_count = "\(use_count)"
                usedTime = TimeInterval(ticketes.time) ?? NSDate().timeIntervalSince1970
                if ticketes.save() > 0 {
                    print("保存成功")
                }else{
                    print("保存失败")
                }
                break
            }
        }
        if BoolCodeNew {
            //新票
            var boolSCode:Bool = false
            for scode in self.sCode {
                let scodeStr:String = scode as! String
                let firstCode:String = scodeStr.subString(start: 0, length: scodeStr.characters.count-1)
                if firstCode == code {
                    let lastCode:String = scodeStr.subString(start: scodeStr.characters.count-1, length: 1)
                    if lastCode == "0" {
                        let ticketmodel = TicketData()
                        ticketmodel.code = ""
                        ticketmodel.use_count = "1"
                        ticketmodel.scode = "\(code)"
                        
                        ticketmodel.tel = "0"
                        ticketmodel.is_used = "0"
                        ticketmodel.model = "\(UserDefaults.standard.integer(forKey: "model"))"
                        ticketmodel.usedTime = "\(Int(Date().timeIntervalSince1970))"
                        usedTime = TimeInterval(ticketmodel.usedTime)!
                        
                        use_count = Int(ticketmodel.use_count)!

                        if ticketmodel.save() > 0 {
                            print("保存成功")
                        }else{
                            print("保存失败")
                        }
                        self.successNotice("扫码成功\n第1次使用")
                        self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
                        self.Codedes = self.Codedes.reversed()
                        self.tableView.reloadData()
                        self.FuncCodeTime()
                    }else if lastCode == "1" {
                        Bottomnav.rootViewController.AudioTip()
                        self.FuncTipsCode("该票已经验过", intro: "该票已经使用过，为无效二维码",status: self.BoolTipCode)
                        self.ErrorSave(code)
                    }else{
                        Bottomnav.rootViewController.AudioTip()
                        self.FuncTipsCode("不是喵特门票!!", intro: "有可能是票种不符，或者是微票等其他渠道的电子票",status: self.BoolTipCode)
                        self.ErrorSave(code)
                    }
                    boolSCode = true
                    break
                }
                
            }
            
            
            if boolSCode == false {
                Bottomnav.rootViewController.AudioTip()
                self.FuncTipsCode("票种不符！！！", intro: "有可能是票种不符，或者是微票等其他渠道的电子票，请确认下该票是否符合当天日期",status: self.BoolTipCode)
                self.ErrorSave(code)
            }

        }else{
            //已验过
            let usedtimeStr :String = self.getNowTimeString(usedtime: usedTime) as String
            Bottomnav.rootViewController.AudioTip()
            self.FuncTipsCode("本机已经扫过", intro: "验票次数：\(use_count)次\n上次验票时间：\(usedtimeStr)",status: self.BoolTipCode)
            self.Codedes = TicketData.rows(order: "tid ASC") as! [TicketData]
            self.Codedes = self.Codedes.reversed()
            self.FuncNum()
        }
        
    }
    
    //查看异常数据
    @IBAction func ButtonError(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ToError", sender: self)
    }
    
    var soud:UInt32 = 1000
    @IBAction func ButtonUpData(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ToWeb", sender: self)
//        self.UpData()
//        AudioServicesPlaySystemSound(soud)
//        print(soud)
//        soud += 1
    }
    
    
    //MARK:查看门票
    @IBAction func ButtonTicketInfo(_ sender: UIButton) {
        if BoolExpo {
            FuncListJson()
        }else{
            self.infoNotice("请先绑定漫展")
        }
    }
    
    var Tickets:NSMutableOrderedSet = NSMutableOrderedSet()
    var TicketInfo:String = ""
    
    
    func FuncListJson(){
        self.pleaseWait()
        let ExpoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "get_ticket_count", type: self.urlType)
        Alamofire.request(ExpoURL, method: HTTPMethod.post,parameters:["scan_token":self.InfoExpo.scan_token,"secret":self.InfoExpo.secret]).responseJSON { (response) in

            self.clearAllNotice()
            if let Json = response.result.value as? NSDictionary{
//                print("门票信息:\(Json)")
                let result:Int = Json.value(forKey: "result") as! Int
                if result == 1 {
                    let ListJson = (Json.value(forKey: "data") as! [NSDictionary]).map{
                        TicketListModel(name: $0["name"] as! String, id: $0["ticket_id"] as! Int, total: $0["total_num"] as? Int, used: $0["used_num"] as! Int)
                    }
                    Json.write(toFile: FilePath.TicketInfo, atomically: true)
                    self.Tickets.removeAllObjects()
                    self.Tickets.addObjects(from: ListJson)
                    self.SelectTicketId.removeAll()
                    self.TicketInfo = ""
                    for ticket in self.Tickets {
                        let cellModel:TicketListModel = ticket as! TicketListModel
                        let ticketcell:String = "\n\(cellModel.Name)\n销售：\(cellModel.TotalNum)张  已扫：\(cellModel.UsedNum)张\n"
                        self.TicketInfo += ticketcell
                    }
                    self.TicketInfoTip()
                }else{
                    let info:String = Json.value(forKey: "error") as! String
                    self.errorNotice("\(info)")
                }
            }
        }
    }
    
    func TicketInfoTip(){
        let alert:UIAlertController = UIAlertController(title: "查看验票数据", message: "\(TicketInfo)", preferredStyle: .alert)
    
        alert.addAction(UIAlertAction(title: "确 定", style: .cancel, handler: nil))
        Bottomnav.rootViewController.present(alert, animated: true, completion: nil)
    }

    //搜索扫码记录
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        BgSearch.resignFirstResponder()
    }
    enum List {
        case defalut,search
    }
    var TypeList:List = List.defalut
    
    var Searches:NSMutableArray = NSMutableArray()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            TypeList = List.defalut
            BgTop.frame.size.height = 293
            tableView.reloadData()
        }else{
            BgTop.frame.size.height = 44.01
            Searches.removeAllObjects()
            for ticket in Codedes {
                if ticket.tel.lowercased().hasPrefix(searchText.lowercased()){
                    Searches.add(ticket)
                }
            }
            TypeList = .search
            tableView.reloadData()
        }
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        TypeList = .defalut
        BgTop.frame.size.height = 293
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    //时间器
    var Index:Int = 0
    var TipTime:Timer!
    var BoolReturn:Bool = true
    func FuncCodeTime(){
        self.AsyncUpData()
        Index = 0
        TipTime = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.FuncTip), userInfo: nil, repeats: true)
    }
    func FuncTip(){
        Index += 1
        if Index > 10 {
            Index = 0
            QRreader.startScanning()
            if TipTime != nil {
                TipTime.invalidate()
            }
        }
    }
    
    func TimeClose(){
        Index = 0
        if TipTime != nil {
            TipTime.invalidate()
        }
    }
    ///////////查询手机号
    var SearchPhone:String = "0"
    @IBAction func ButtonPhoneSearch(_ sender: UIButton) {
        let Alert:UIAlertController = UIAlertController(title: "手机号查询", message: "用户如果无法打开网页或APP时，可以让用户提供手机号进行查询验证", preferredStyle: UIAlertControllerStyle.alert)
       
            Alert.addTextField { (textinput) in
                
            textinput.keyboardType = .numberPad
        }
        let BtnCancel:UIAlertAction = UIAlertAction(title: "取 消", style: UIAlertActionStyle.cancel){ (action) in
            self.Phones.removeAll()
            self.tableView.reloadData()
        }

        let BtnSubmit:UIAlertAction = UIAlertAction(title: "确认查询", style: UIAlertActionStyle.destructive) { (action) in
            let phone:String = (Alert.textFields?.first!.text)!
            self.PhoneSearch(phone)
        }
        Alert.addAction(BtnCancel)
        Alert.addAction(BtnSubmit)
        Bottomnav.rootViewController.present(Alert, animated: true, completion: nil)
    }
    
    //MARK:分两种检票,1种手机号查询的，1种其他的
    func PhoneSearch(_ phone:String){
        self.Phones.removeAll()
        if phone.characters.count != 11 {
            self.errorNotice("手机号码输入不对")
        }else{
            if BoolExpo {
                //手机号通过网络请求获得票，不再是本地存储的了
                self.PhoneSearchFromInternet(telphone: phone)
            }else{
                self.errorNotice("请先绑定漫展")
            }
        }
    }

    func PhoneSearchFromInternet(telphone : String) {
        self.pleaseWait()
        let exhibitionURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "getOrderByTel", type: self.urlType)
//        print(["tel":"\(telphone)","scan_token":self.InfoExpo.scan_token,"secret": self.InfoExpo.secret,"ticket_id":"\(self.UpTicketId)"])
        Alamofire.request(exhibitionURL, method: HTTPMethod.post,parameters:["tel":"\(telphone)","scan_token":self.InfoExpo.scan_token,"secret": self.InfoExpo.secret,"ticket_id":"\(self.UpTicketId)"]).responseJSON(completionHandler: { (response) in
            self.clearAllNotice()
            if let Json = response.result.value as? NSDictionary{
//                print(Json)
                let result:Int = Json.value(forKey: "result") as! Int
                if result == 1 {
                    
                    let dataDiccc : NSArray = Json.value(forKey: "data") as! NSArray
                    for ticketes in dataDiccc{
                        self.Phones.append(ticketes as! NSDictionary)
                    }
                    if self.Phones.count == 0 {
                        self.infoNotice("手机号没有相关票务数据")
                    }else{
                        
                    }
                    
                    self.tableView.reloadData()
                }else{
                    self.FuncTipsCode("提示", intro: "此手机号没有相关票务信息", status: false)
                }
            }
        })
        
    }
    
    //MARK:作废门票
    func invalidTicketOrder() {
        let exhibitionURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "used_code", type: self.urlType)
        self.pleaseWait()
        Alamofire.request(exhibitionURL, method: HTTPMethod.post,parameters:["scan_token":"\(self.InfoExpo.scan_token)","secret":"\(self.InfoExpo.secret)"]).responseJSON(completionHandler: { (response) in
            self.clearAllNotice()
            if let Json = response.result.value as? NSDictionary{
//                print(Json)
                let result = Json.value(forKey: "result") as? Int ?? 2
                if result == 1{
                    Json.write(toFile: FilePath.Refunds, atomically: true)
                }else if result == 2 {
                    self.errorNotice("请重新绑定漫展")
                    FilePath.FileRemoveAll(true)
                }else{
                    //删除作废门票
                    FilePath.delRefunds()
                }
            }else{
                self.errorNotice("连接超时")
            }
        })
    }
    
    //记录离线更新  1为全体上传 2为单个上传且要输入第几个
    func recordOutOfInternetUpdate(type : Int = 1, tag : Int = 0) {
//        self.Neworking()
        self.PublicNav.selectedItem = nil
        var dataArray : [NSDictionary] = [NSDictionary]()
        var datasArray:[TicketData] = [TicketData]()
        print("\(type) -------")
        if type == 1 {
            for ticket in Codedes {
                if ticket.is_used == "0" {
                    print(ticket.code)
                    let dicData : NSMutableDictionary = NSMutableDictionary()
                    dicData.setValue(ticket.use_count, forKey: "use_count")
                    dicData.setValue(ticket.usedTime, forKey: "usedTime")
                    dicData.setValue(ticket.is_used, forKey: "is_used")
                    dicData.setValue(ticket.code, forKey: "code")
                    dicData.setValue(ticket.scode, forKey: "scode")
                    dataArray.append(dicData)
                    datasArray.append(ticket)
                }
            }
        }else{
            let modelData:TicketData = Codedes[tag]
            let dicData : NSMutableDictionary = NSMutableDictionary()
            dicData.setValue(modelData.use_count, forKey: "use_count")
            dicData.setValue(modelData.usedTime, forKey: "usedTime")
            dicData.setValue(modelData.is_used, forKey: "is_used")
            dicData.setValue(modelData.code, forKey: "code")
            dicData.setValue(modelData.scode, forKey: "scode")
            dataArray.append(dicData)
        }
        
//        if dataArray.count ==  0{
////            self.infoNotice("当前的票都是验过的")
//        }
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: dataArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let codeStr : NSString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
//            print("code:\(code)")
//            let codeStr:String = jsonData.description.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let exhibitionURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "update_ticket", type: self.urlType)
//            print(["code":codeStr,"secret":"\(self.InfoExpo.secret)","scan_token":"\(self.InfoExpo.scan_token)"])
            Alamofire.request(exhibitionURL, method: HTTPMethod.post,parameters:["code":"\(codeStr)","secret":"\(self.InfoExpo.secret)","scan_token":"\(self.InfoExpo.scan_token)"]).responseJSON(completionHandler: { (response) in
                
                if let Json = response.result.value as? NSDictionary{
                    let status = Json.value(forKey: "status") as! Int
                    
                    if status == 1{

                        if type == 1{
                            for ticket in self.Codedes {
                                if ticket.is_used == "0" {
                                    ticket.is_used = "1"
                        
                                    if ticket.save() > 0 {
                                        print("保存成功")
                                    }else{
                                        print("保存失败")
                                    }
                                }
                            }
                        }else{
                            let model:TicketData = self.Codedes[tag]
                            model.is_used = "1"
                            if model.save() > 0 {
                                print("保存成功")
                            }else{
                                print("保存失败")
                            }
                        }
                        self.tableView.reloadData()
                        
                    }else{
                        if type == 1 {
                            for ticket in self.Codedes {
                                ticket.is_used = "2"
                                if ticket.save() > 0 {
                                    print("保存成功")
                                }else{
                                    print("保存失败")
                                }
                            }
                        }else{
                            self.Codedes[tag].is_used = "2"
                            if self.Codedes[tag].save() > 0 {
                                print("存储验证不通过码成功")
                            }else{
                                print("存储验证不通过码失败")
                            }
                            self.tableView.reloadData()
                        }
                        self.boolWithOutOfInternetUpdate = false
                    }
                }else{
//                    self.errorNotice("网络连接失败")
                }
            })
        } catch {

        }
    }
    
    //MARK:获得当前时间戳
    func getNowTimeString(usedtime : TimeInterval) -> NSString {
        //开始
        let date:NSDate = NSDate(timeIntervalSince1970: usedtime)
        // 创建时间戳
        let formatter:DateFormatter = DateFormatter()
        
        // 设置日期格式，以字符串表示的日期形式的格式
        formatter.dateFormat = "MM-dd HH:mm"
        
        // 转换成指定的格式
        let usedtimeStr:String = formatter.string(from: date as Date)
        
        return usedtimeStr as NSString
    }
    
    //MARK:第二层验证
    func TheSecondCheck(scan_secret :String, secret: String) -> String {
        let scan_tokenStr :String = scan_secret
        let scan_tokenStrMD5 :String = scan_tokenStr.md5.md5
        let scan_tokenTwenty = scan_tokenStrMD5.characters.index(scan_tokenStrMD5.startIndex, offsetBy: 20)
        //从0到20位的字符截取
        let scan_tokenTwentyStr = scan_tokenStrMD5.substring(to: scan_tokenTwenty)
        
        //取后面的20 位字符
        let secretStr :String = secret
        let secretStrMD5 :String = secretStr.md5.md5.md5
        let secretTwenty: Range = Range(secretStrMD5.characters.index(secretStrMD5.endIndex, offsetBy: -20) ..< secretStrMD5.characters.index(secretStrMD5.endIndex, offsetBy: 0))
        let secretTwentyStr:String = "\(secretStrMD5.substring(with: secretTwenty))"
        
        let lastScan_token : String = "\(scan_tokenTwentyStr)\(secretTwentyStr)"

        return lastScan_token
    }

    //网络监测
    var NetWork:Int = 0
    var reachability: Reachability?

    func Neworking(){
        reachability = Reachability()
        if reachability!.isReachableViaWiFi {
            //self.infoNotice("当前WIFI网络环境")
            self.NetWork = 0
        }else if reachability!.isReachableViaWWAN{
            //                self.infoNotice("当前处于4G网络环境")
            self.NetWork = 1
        }else{
            self.errorNotice("没有连接网络")
            self.NetWork = 2
        }

    }
    //切换线程
    @IBOutlet weak var btnUrlMain: UIButton!
    @IBOutlet weak var btnUrlOne: UIButton!
    @IBOutlet weak var btnUrlTwo: UIButton!
    
    @IBAction func buttonUrlChange(_ sender: UIButton) {
        UserDefaults.standard.set(sender.tag, forKey: "urltype")
        btnUrlStatus(typeurl: sender.tag)
        self.urlType = sender.tag
    }
    func btnUrlStatus(typeurl:Int){
        switch typeurl {
        case 1:
            btnUrlOne.backgroundColor = Color.Red
            btnUrlOne.setTitleColor(UIColor.white, for: UIControlState.normal)
            btnUrlMain.backgroundColor = UIColor.white
            btnUrlMain.setTitleColor(Color.Font(2), for: UIControlState.normal)
            btnUrlTwo.backgroundColor = UIColor.white
            btnUrlTwo.setTitleColor(Color.Font(2), for: UIControlState.normal)

        case 2:
            btnUrlTwo.backgroundColor = Color.Red
            btnUrlTwo.setTitleColor(UIColor.white, for: UIControlState.normal)
            btnUrlOne.backgroundColor = UIColor.white
            btnUrlOne.setTitleColor(Color.Font(2), for: UIControlState.normal)
            btnUrlMain.backgroundColor = UIColor.white
            btnUrlMain.setTitleColor(Color.Font(2), for: UIControlState.normal)

        default:
            btnUrlMain.backgroundColor = Color.Red
            btnUrlMain.setTitleColor(UIColor.white, for: UIControlState.normal)
            btnUrlOne.backgroundColor = UIColor.white
            btnUrlOne.setTitleColor(Color.Font(2), for: UIControlState.normal)
            btnUrlTwo.backgroundColor = UIColor.white
            btnUrlTwo.setTitleColor(Color.Font(2), for: UIControlState.normal)

        }
    }
}






