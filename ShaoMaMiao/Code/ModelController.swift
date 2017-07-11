//
//  ModelController.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/11/29.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit
import Alamofire
class ModelController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var LabelRecord: UILabel!
    @IBOutlet weak var LabelOnline: UILabel!
    @IBOutlet weak var LabelTip: UILabel!
    var Tickets:NSMutableOrderedSet = NSMutableOrderedSet()
    @IBOutlet weak var tableView: UITableView!
    var InfoExpo:ExpoModel = ExpoModel()
    var SelectTickets:[Bool] = [Bool]()
    @IBOutlet weak var outLineButton: UIButton!
    
    var SelectTicketId:[Int] = [Int]()
    @IBOutlet weak var BgLoading: UIActivityIndicatorView!
   
    override func viewDidAppear(_ animated: Bool) {
        self.clearAllNotice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "扫票模式"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.FuncClose))
        let status: Int = UserDefaults.standard.integer(forKey: "model")
    
        FuncButton(status)
        let nib:UINib = UINib(nibName: "TicketCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TicketCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        LabelTip.textColor = Color.Red
        
        LabelOnline.layer.shouldRasterize = true
        LabelOnline.layer.rasterizationScale = UIScreen.main.scale
        LabelOnline.layer.cornerRadius = 40
        LabelOnline.clipsToBounds = true

//        LabelOutline.layer.shouldRasterize = true
//        LabelOutline.layer.rasterizationScale = UIScreen.main.scale
//        LabelOutline.layer.cornerRadius = 40
//        LabelOutline.clipsToBounds = true
//        LabelOutline.isHidden = false
//        LabelOutline.text = "模式选择"
        outLineButton.isUserInteractionEnabled = false
        outLineButton.isHidden = true
        
        LabelRecord.layer.shouldRasterize = true
        LabelRecord.layer.rasterizationScale = UIScreen.main.scale
        LabelRecord.layer.cornerRadius = 40
        LabelRecord.clipsToBounds = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更新数据", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.FuncGetCode))

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.plain, target: self, action: nil)

        let TicketJson = NSDictionary(contentsOfFile: FilePath.TicketInfo)
        if TicketJson == nil {
            self.BgLoading.startAnimating()
            self.FuncListJson()
        }else{
            //初始化已存的设定
            self.BgLoading.isHidden = true
            let ListJson = (TicketJson!.value(forKey: "data") as! [NSDictionary]).map{
                TicketListModel(name: $0["name"] as! String, id: $0["ticket_id"] as! Int, total: $0["total_num"] as? Int, used: $0["used_num"] as! Int)
            }
            self.Tickets.removeAllObjects()
            self.Tickets.addObjects(from: ListJson)
            self.SelectTickets = UserDefaults.standard.object(forKey: "selecttickets") as? Array ?? [Bool]()
            self.SelectTicketId = UserDefaults.standard.object(forKey: "selectticketid") as? Array ?? [Int]()
    
            if self.SelectTickets.count == 0 && self.Tickets.count != 0 {
                for _ in self.Tickets {
                    self.SelectTickets.append(false)
                }
                UserDefaults.standard.set(self.SelectTickets, forKey: "selecttickets")
            }
            self.tableView.reloadData()
        }
        refreshControl.attributedTitle = NSAttributedString(string:"下拉刷新数据")
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        refreshControl.superview?.sendSubview(toBack: refreshControl)
        //初始化缓存数据
        if Bottomnav.rootViewController.NetWork == 0 {
            self.CodesGet(0,status: false)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel:TicketListModel = Tickets.object(at: indexPath.section) as! TicketListModel
        if SelectTickets[indexPath.section] {
            SelectTickets[indexPath.section] = false
            for id in SelectTicketId {
                if id == cellModel.Id {
                    let index:Int = SelectTicketId.index(of: id)!
                    SelectTicketId.remove(at: index)
                }
            }
        }else{
            SelectTickets[indexPath.section] = true
            SelectTicketId.append(cellModel.Id)

        }
            Bottomnav.rootViewController.CodeIndexHtml.UpTicketId = "0"
        for ticket in SelectTicketId {
            Bottomnav.rootViewController.CodeIndexHtml.UpTicketId += ",\(ticket)"
        }

        Bottomnav.rootViewController.CodeIndexHtml.SelectTicketId = SelectTicketId
        UserDefaults.standard.set(SelectTicketId, forKey: "selectticketid")
        UserDefaults.standard.set(SelectTickets, forKey: "selecttickets")
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Tickets.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:TicketCell? = tableView.dequeueReusableCell(withIdentifier: "TicketCell") as? TicketCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TicketCell", owner: nil, options: nil)?.first as? TicketCell
        }
        let cellModel:TicketListModel = Tickets.object(at: indexPath.section) as! TicketListModel
        cell?.Name.text = "\(cellModel.Name)"
        if SelectTickets[indexPath.section] {
            cell?.Select.textColor = Color.Red
            cell?.Select.layer.borderColor = Color.Red.cgColor
            cell?.Des.text = "已选择该门票"
        }else{
            cell?.Select.textColor = UIColor.clear
            cell?.Select.layer.borderColor = Color.Font(2).cgColor
            cell?.Des.text = "未选择该门票"
        }
        //缓存判定
        let ticket = NSDictionary(contentsOfFile: FilePath.sCodeData)
                
        if ticket == nil {
            cell?.Status.textColor = Color.Font(2)
            cell?.Status.text = "未缓存"
        }else{
            cell?.Status.textColor = Color.Green
            cell?.Status.text = "已缓存"
        }

        cell?.Select.text = "✔︎"
        return cell!
    }
    
    //在线模式
    @IBAction func ButtonOnline(_ sender: UIButton) {
        FuncButton(sender.tag)
        UserDefaults.standard.set(sender.tag, forKey: "model")
        self.navigationItem.rightBarButtonItem = nil
        if Bottomnav.rootViewController.CodeIndexHtml.Codedes.count != 0 {
            Bottomnav.rootViewController.CodeIndexHtml.recordOutOfInternetUpdate()
        }
        Bottomnav.rootViewController.Neworking()
    }
    //离线模式
    @IBAction func ButtonOutLine(_ sender: UIButton) {
        FuncButton(sender.tag)
        UserDefaults.standard.set(sender.tag, forKey: "model")
    }
    //缓存数据
    func FuncSave(_ sender:UIButton){
    }
    
    //记录式验票
    @IBAction func ButtonRecord(_ sender: UIButton) {
        FuncButton(sender.tag)
        UserDefaults.standard.set(sender.tag, forKey: "model")
        self.navigationItem.rightBarButtonItem = nil
    }
    
    //按钮样式
    func FuncButton(_ status:Int){
        switch status {
//        case 1:
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "缓存", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.FuncGetCode))
//            LabelOutline.backgroundColor = Color.Red
//            LabelOutline.textColor = UIColor.white
//            LabelOnline.backgroundColor = UIColor.groupTableViewBackground
//            LabelOnline.textColor = Color.Font(2)
//            LabelRecord.backgroundColor = UIColor.groupTableViewBackground
//            LabelRecord.textColor = Color.Font(2)
//            LabelTip.text = "离线模式是，预先缓存已购买的门票数据，无需联网就可以进行验票，不大适用验证现场购买的喵特门票"
        case 2:
            LabelRecord.backgroundColor = Color.Red
            LabelRecord.textColor = UIColor.white
//            LabelOutline.backgroundColor = UIColor.groupTableViewBackground
//            LabelOutline.textColor = Color.Font(2)
            LabelOnline.backgroundColor = UIColor.groupTableViewBackground
            LabelOnline.textColor = Color.Font(2)
            LabelTip.text = "算法模式是，判定该票符合喵特平台下的漫展门票，无需联网就可以进行验票，也可适用现场购买的喵特门票，但结束需要及时联网提交验票信息"
        default:
            LabelOnline.backgroundColor = Color.Red
            LabelOnline.textColor = UIColor.white
//            LabelOutline.backgroundColor = UIColor.groupTableViewBackground
//            LabelOutline.textColor = Color.Font(2)
            LabelRecord.backgroundColor = UIColor.groupTableViewBackground
            LabelRecord.textColor = Color.Font(2)
            LabelTip.text = "在线模式是，每次验票都会跟喵特服务器进行请求验证门票的真伪，也适用现场购买门票进行验票，但需要进行联网"
        }
        Bottomnav.rootViewController.CodeIndexHtml.FuncModel(status)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //上拉刷新
    var refreshControl:UIRefreshControl = UIRefreshControl()
    func refreshData(){
        self.FuncListJson()
    }

    func FuncClose(){
        if SelectTicketId.count > 0 {
            if UserDefaults.standard.integer(forKey: "model") == 1 {
                //离线判定
                let Tickets = NSDictionary(contentsOfFile: FilePath.sCodeData)
                if Tickets == nil {
                    self.infoNotice("还没缓存数据")
                }else{
                    self.navigationController!.popViewController(animated: true)
                }
            }else{
                self.navigationController!.popViewController(animated: true)
            }
        }else{
            self.infoNotice("还没有选择要扫的门票")
        }
    }

    func FuncListJson(){
        let urlType = UserDefaults.standard.integer(forKey: "urltype")

        let ExpoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "get_ticket_count", type: urlType)
        
        Alamofire.request(ExpoURL, method: HTTPMethod.post, parameters:["scan_token":"\(self.InfoExpo.scan_token)","secret":"\(self.InfoExpo.secret)"]).responseJSON { (response) in
            if let Json = response.result.value as? NSDictionary{
                //                print("门票列表\(Json)")
                self.BgLoading.stopAnimating()
                self.BgLoading.isHidden = true
                self.refreshControl.endRefreshing()
                let result:Int = Json.value(forKey: "result") as! Int
                if result == 1 {
                    let ListJson = (Json.value(forKey: "data") as! [NSDictionary]).map{
                        TicketListModel(name: $0["name"] as! String, id: $0["ticket_id"] as! Int, total: $0["total_num"] as? Int, used: $0["used_num"] as! Int)
                }
                    Json.write(toFile: FilePath.TicketInfo, atomically: true)
                    self.Tickets.removeAllObjects()
                    self.Tickets.addObjects(from: ListJson)
                    self.SelectTickets.removeAll()
                    self.SelectTicketId.removeAll()
                    for _ in self.Tickets {
                        self.SelectTickets.append(false)
                        //                        self.SelectSave.append(false)
                }
                    UserDefaults.standard.set(self.SelectTickets, forKey: "selecttickets")
                    //                    NSUserDefaults.standardUserDefaults().setObject(self.SelectSave, forKey: "selectsave")
                    self.tableView.reloadData()
                }else{
                    let info:String = Json.value(forKey: "error") as! String
                    self.errorNotice("\(info)")
                }
            }
        }
    }
    
    //缓存短码
    func FuncGetCode(){
        let AlertTip:UIAlertController = UIAlertController(title: "是否开始缓存数据", message: "开始缓存后请耐心等待，不要关闭APP", preferredStyle: UIAlertControllerStyle.actionSheet)
        let BtnCancel:UIAlertAction = UIAlertAction(title: "取 消", style: UIAlertActionStyle.cancel, handler: nil)
        let BtnSubmit:UIAlertAction = UIAlertAction(title: "缓存门票数据", style: UIAlertActionStyle.destructive) { (action) in
            self.CodesGet(0,status: true)
        }
        AlertTip.addAction(BtnCancel)
        AlertTip.addAction(BtnSubmit)
        Bottomnav.rootViewController.present(AlertTip, animated: true, completion: nil)
    }
    
    
    func CodesGet(_ ticketid:Int,status:Bool){
        pleaseWait()
        Bottomnav.rootViewController.FuncTime()
        let type:Int = UserDefaults.standard.integer(forKey: "urltype")
        let ExpoURL:String = PostURL().FromURL("/index.php", mod: "Scanner", act: "getScodeData", type: type)
        Alamofire.request(ExpoURL, method: HTTPMethod.post, parameters:["scan_token":"\(self.InfoExpo.scan_token)","secret":self.InfoExpo.secret]).responseJSON { (response) in
            
            self.clearAllNotice()
            Bottomnav.rootViewController.TimeClose()
            if let Json = response.result.value as? NSDictionary{
//                print(Json)
                let result:Int = Json.value(forKey: "result") as! Int
                if result == 1 {
                    if status {
                        self.successNotice("缓存成功")
                    }
                    Bottomnav.rootViewController.sCodes = Json.value(forKey: "data") as! [NSDictionary]
                    Json.write(toFile: FilePath.sCodeData, atomically: true)
                }else{
                    let error:String = Json.value(forKey: "info") as? String ?? "发生异常"
                    self.errorNotice("\(error)")
                }
            }
        }
    }
}
