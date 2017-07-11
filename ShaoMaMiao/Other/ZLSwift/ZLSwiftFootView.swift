//
//  ZLSwiftFootView.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-6.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

open class ZLSwiftFootView: UIView {
    
    var scrollView:UIScrollView = UIScrollView()
    var footLabel: UILabel = UILabel()
    
    var loadMoreAction: (() -> Void)? = {}
    var loadMoreTempAction:(() -> Void)? = {}
    var loadMoreEndTempAction:(() -> Void)? = {}
    
    var isEndLoadMore:Bool = false{
        willSet{
            self.footLabel.text = ZLSwithRefreshMessageText
            self.isEndLoadMore = newValue
        }
    }
    var title:String {
        set {
            footLabel.text = newValue
        }
        
        get {
            return footLabel.text!
        }
    }
    
    convenience init(action: @escaping (() -> ()), frame: CGRect){
        self.init(frame: frame)
        self.loadMoreAction = action
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        self.setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Currently it is not supported to load view from nib
    }
    
    func setupUI(){
        let footTitleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        footTitleLabel.textAlignment = .center
        footTitleLabel.text = ZLSwithRefreshFootViewText
        self.addSubview(footTitleLabel)
        footLabel = footTitleLabel
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        refreshStatus = .normal
    }
    
    open override func willMove(toSuperview newSuperview: UIView!) {
        
        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
        superview?.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &KVOContext)
        
        refreshStatus = .normal
        if (newSuperview != nil && newSuperview.isKind(of: UIScrollView.self)) {
            self.scrollView = newSuperview as! UIScrollView
            
            // 如果UITableViewController情况下，contentInset.bottom 会加20
            var offset:CGFloat = 0
            if (!self.getViewControllerWithView(self.scrollView).isKind(of: UITableViewController.self)){
                offset = self.frame.height * 0.5
            }else{
                offset = self.frame.height * 0.5 - 20
            }
            
            self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom + self.frame.height + offset + self.scrollView.frame.origin.y, self.scrollView.contentInset.right)
            
            newSuperview.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .initial, context: &KVOContext)
            newSuperview.addObserver(self, forKeyPath: contentSizeKeyPath, options: .initial, context: &KVOContext)
        }
    }
    
    //MARK: KVO methods
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (self.loadMoreAction == nil) {
            return;
        }
        
        let scrollView:UIScrollView = self.scrollView
        if (keyPath == contentSizeKeyPath){
            // change contentSize
            if(scrollView.isKind(of: UICollectionView.self) == true){
                let tempCollectionView :UICollectionView = scrollView as! UICollectionView
                let height = tempCollectionView.collectionViewLayout.collectionViewContentSize.height
                self.frame.origin.y = height
            }else{
                if (self.scrollView.contentSize.height == 0){
                    self.frame.origin.y = 0
                }else if(scrollView.contentSize.height < self.frame.size.height){
                    self.frame.origin.y = self.scrollView.frame.size.height - self.frame.height
                }else{
                    self.frame.origin.y = scrollView.contentSize.height
                }
            }
            self.frame.origin.y += ZLSwithRefreshFootViewHeight * 0.5
            return;
        }
        
        // change contentOffset
        let scrollViewContentOffsetY:CGFloat = scrollView.contentOffset.y
//        var height:CGFloat = 0
//        height = ZLSwithRefreshHeadViewHeight
//        if (ZLSwithRefreshHeadViewHeight > animations){
//            height = animations
//        }
//        
        // 上拉加载更多
        if (
            scrollViewContentOffsetY > 0
            )
        {
            let nowContentOffsetY:CGFloat = scrollViewContentOffsetY + self.scrollView.frame.size.height
            var tableViewMaxHeight:CGFloat = 0
            
            if (scrollView.isKind(of: UICollectionView.self))
            {
                let tempCollectionView :UICollectionView = scrollView as! UICollectionView
                let height = tempCollectionView.collectionViewLayout.collectionViewContentSize.height
                tableViewMaxHeight = height
            }else if(scrollView.contentSize.height > 0){
                tableViewMaxHeight = scrollView.contentSize.height
            }
            
            if (refreshStatus == .normal){
                loadMoreTempAction = loadMoreAction
            }
            
            if (nowContentOffsetY - tableViewMaxHeight) > 0 && scrollView.contentOffset.y != 0{
                if isEndLoadMore == false && refreshStatus == .normal {
                    if loadMoreTempAction != nil{
                        refreshStatus = .loadMore
                        self.title = ZLSwithRefreshLoadingText
                        loadMoreTempAction?()
                        loadMoreTempAction = {}
                    }else {
                        self.title = ZLSwithRefreshMessageText
                    }
                }
            }else if (isEndLoadMore == false){
                loadMoreTempAction = loadMoreAction
                self.title = ZLSwithRefreshFootViewText
            }
        }else if (isEndLoadMore == false){
            self.title = ZLSwithRefreshFootViewText
        }
    }
    
    func getViewControllerWithView(_ vcView:UIView) -> AnyObject{
        if( (vcView.next?.isKind(of: UIViewController.self) ) == true){
            return vcView.next as! UIViewController
        }
        
        if(vcView.superview == nil){
            return vcView
        }
        return self.getViewControllerWithView(vcView.superview!)
    }
}
