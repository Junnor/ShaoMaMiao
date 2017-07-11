//
//  ExpoDetailController.swift
//  ShangWuMiao
//
//  Created by 赵辉 on 16/6/1.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit
class ExpoDetailController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {
    var BoolTickets:[Bool] = [Bool]()
    var BoolPrice:Bool = false
    var Alphas:CGFloat = 0
    var numlines:Int = 5
    
    var Page:Int = 1
    var PageStatus:Bool = false
    var InfoExpo:ExpoModel = ExpoModel()
    var InfoUser:UserModel = UserModel()
    var Tickets:NSMutableOrderedSet = NSMutableOrderedSet()
    @IBOutlet weak var BgBottom: UIView!

    @IBOutlet weak var ImageBg: UIImageView!
    @IBOutlet weak var LabelAddrs: UILabel!
    @IBOutlet weak var LabelStartime: UILabel!
    @IBOutlet weak var LabelPrices: UILabel!
    @IBOutlet weak var LabelPrice: UILabel!
    @IBOutlet weak var ImageLogoLeft: UIImageView!
    @IBOutlet weak var LabelTitle: UILabel!
    @IBOutlet weak var HeightImage: NSLayoutConstraint!
    @IBOutlet weak var BgTop: UIView!
    @IBOutlet weak var tableView: UITableView!
    var BoolReash:Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        if BoolReash {
            BoolReash = false
        }
        self.clearAllNotice()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //基本信息初始化

        LabelAddrs.text = "\(InfoExpo.Location)"
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let visualViews = UIVisualEffectView(effect: blurEffect)
        visualViews.alpha = 1
        visualViews.frame = CGRect(x: 0, y: 0, width: Body.Width, height: Body.Height)
        ImageBg.addSubview(visualViews)
        ImageBg.clipsToBounds = true
        let request:URLRequest = URLRequest(url: URL(string: InfoExpo.Cover)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue()) { (_, data, error) in
            if data != nil {
                let image = UIImage(data: data!)
                self.ImageLogoLeft.image = image
                self.ImageBg.image = image
            }
        } 

        LabelTitle.text = "\(InfoExpo.Name)"
        title = InfoExpo.Name
        
        //开始
        let dateStart:NSDate = NSDate(timeIntervalSince1970: TimeInterval(InfoExpo.StartTime))
        let dateEnd:NSDate = NSDate(timeIntervalSince1970: TimeInterval(InfoExpo.EndTime))

        // 创建时间戳
        let formatter:DateFormatter = DateFormatter()
        
        // 设置日期格式，以字符串表示的日期形式的格式
        formatter.dateFormat = "MM-dd HH:mm"
        
        // 转换成指定的格式
        let Startime:String = formatter.string(from: dateStart as Date)
        let Endtime:String = formatter.string(from: dateEnd as Date)

//        let Startime:String = Date(timeIntervalSince1970: TimeInterval(InfoExpo.StartTime)).toString(format: DateFormatter.custom("MM.dd HH:mm"))
//        let Endtime:String = Date(timeIntervalSince1970: TimeInterval(InfoExpo.EndTime)).toString(format: DateFormatter.custom("MM.dd HH:mm"))
        LabelStartime.text = "\(Startime)--\(Endtime)"
        LabelPrice.text = "¥ \(InfoExpo.PresalePrice)"
        LabelPrices.text = "现场 \(InfoExpo.ScenePrice)"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.view.backgroundColor = Color.Bg
        // Do any additional setup after loading the view.
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    let BtnPrice:UIButton = UIButton(frame: CGRect(x: Body.Width-112, y: 0, width: 100, height: 24))

    
    func FuncPriceChange(_ sender:UIButton){
        if BoolPrice {
            BoolPrice = false
        }else{
            BoolPrice = true
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 36
        }else{
            return 0.01
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return Tickets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //介绍
            var CellDescription:DescriptionCell? = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as? DescriptionCell
        
            if CellDescription == nil{
                CellDescription = Bundle.main.loadNibNamed("DescriptionCell", owner: nil, options: nil)?.first as? DescriptionCell
            }
            CellDescription?.BtnFeed.addTarget(self, action: #selector(ExpoDetailController.FuncDesOpen(_:)), for: UIControlEvents.touchUpInside)
            CellDescription?.BtnFeed.setTitle("\(btntitle)", for: UIControlState())
            CellDescription?.BtnFeed.addTarget(self, action: #selector(ExpoDetailController.FuncDesOpen(_:)), for: UIControlEvents.touchUpInside)
            CellDescription?.LabelContent.text = "详细地址：\(InfoExpo.Location) \(InfoExpo.Addr)\n\n\(InfoExpo.Description)"
            CellDescription?.LabelContent.numberOfLines = numlines
            if InfoExpo.Description.characters.count < 80 {
                CellDescription?.BtnFeed.setTitle("", for: UIControlState())
                CellDescription?.BtnFeed.alpha = 0
            }else{
                CellDescription?.BtnFeed.setTitle("\(btntitle)", for: UIControlState())
            }
            CellDescription?.BtnFeed.setTitle("\(btntitle)", for: UIControlState())
            CellDescription?.contentView.backgroundColor = UIColor.white
            
            return CellDescription!
       
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    

    //////////////////////展开介绍///////////////////////
    var btntitle:String = "了解更多"
    func FuncDesOpen(_ sender:UIButton){
        ZLSwithRefreshFootViewText = ""
        if numlines == 0 {
            numlines = 5
            btntitle = "了解更多"
            let indexSet:IndexSet = IndexSet(integer: 0)
            tableView.reloadSections(indexSet, with: UITableViewRowAnimation.fade)
            HeightImage.constant = 224
        }else{
            numlines = 0
            btntitle = "收起介绍"
            let indexSet:IndexSet = IndexSet(integer: 0)
            tableView.reloadSections(indexSet, with: UITableViewRowAnimation.fade)
            
        }
        
    }
    

    
}
