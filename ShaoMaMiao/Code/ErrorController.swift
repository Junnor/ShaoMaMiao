//
//  ErrorController.swift
//  ShaoMaMiao
//
//  Created by 赵辉 on 16/12/12.
//  Copyright © 2016年 moelove. All rights reserved.
//

import UIKit

class ErrorController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    var Errors:NSMutableArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        let NowTime:TimeInterval = Date().timeIntervalSince1970
        if NowTime > 1494382210 {
            self.errorLabel.text = "操作记录是把没有通过验证的二维码进行记录，如果发生争议时，可以点击记录进行复制，反馈喵特工作人员进行查证"
        }else{
            self.errorLabel.text = "这里可以查阅最近相关的扫码内容，如不需要可以右上角点击清空，也可以点击进行复制"
        }
        title = "扫码记录"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清空", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.ClearError))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ClearError(){
        let none = NSData()
        none.write(toFile: FilePath.Error, atomically: true)
        Bottomnav.rootViewController.Errors.removeAllObjects()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Bottomnav.rootViewController.Errors.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let error:String = Bottomnav.rootViewController.Errors[indexPath.row] as! String
        UIPasteboard.general.string = "\(error)"
        self.successNotice("复制成功")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath)
        let cellModel:String = Bottomnav.rootViewController.Errors[indexPath.row] as! String
        let errors:Array = cellModel.components(separatedBy: "-")
        let time:TimeInterval = TimeInterval(errors.last!)!
        
        //开始
        let date:Date = Date(timeIntervalSince1970: time)
        // 创建时间戳
        let formatter:DateFormatter = DateFormatter()
        
        // 设置日期格式，以字符串表示的日期形式的格式
        formatter.dateFormat = "MM-dd HH:mm"
        
        // 转换成指定的格式
        let timestr:String = formatter.string(from: date)
        
        cell.detailTextLabel?.text = "操作时间：\(timestr)"
        cell.textLabel?.text = "【No.\(indexPath.row)】\(errors.first!)"
        return cell
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
