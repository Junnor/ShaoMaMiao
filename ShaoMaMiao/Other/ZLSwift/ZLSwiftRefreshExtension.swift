//
//  ZLSwiftRefreshExtension.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-6.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

enum RefreshStatus{
    case normal, refresh, loadMore
}

enum HeaderViewRefreshAnimationStatus{
    case headerViewRefreshPullAnimation, headerViewRefreshLoadingAnimation, headerViewRefreshArrowAnimation
}

var loadMoreAction: (() -> ()) = {}
var refreshStatus:RefreshStatus = .normal
let animations:CGFloat = 25.0
var isFooterViewHidden:Bool?
var tableViewOriginContentInset:UIEdgeInsets = UIEdgeInsets.zero

extension UIScrollView: UIScrollViewDelegate {
    
    public var headerRefreshView: ZLSwiftHeadView? {
        get {
            let headerRefreshView = viewWithTag(ZLSwiftHeadViewTag)
            return headerRefreshView as? ZLSwiftHeadView
        }
    }
    
    public var footerRefreshView: ZLSwiftFootView? {
        get {
            let footerRefreshView = viewWithTag(ZLSwiftFootViewTag)
            return footerRefreshView as? ZLSwiftFootView
        }
    }
    
    //MARK: Refresh
    //下拉刷新
    func toRefreshAction(_ action :@escaping (() -> Void)){
        
        self.alwaysBounceVertical = true
        if self.headerRefreshView == nil{
            let headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRect(x: 0, y: -ZLSwithRefreshHeadViewHeight, width: self.frame.size.width, height: ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }
    }
    
    //MARK: LoadMore
    //上拉加载更多
    func toLoadMoreAction(_ action :@escaping (() -> Void)){
        if (refreshStatus == .loadMore){
            refreshStatus = .normal
        }
        
        self.addLoadMoreView(action)
    }
    
    func showFooterView(){
        isFooterViewHidden = false
        self.footerRefreshView?.isHidden = false
    }
    
    func hiddenFooterView(){
        isFooterViewHidden = true
        self.footerRefreshView?.isHidden = true
    }
    
    func addLoadMoreView(_ action :@escaping (() -> Void)){
        self.alwaysBounceVertical = true
        loadMoreAction = action
        if self.footerRefreshView == nil {
            let footView = ZLSwiftFootView(action: action, frame: CGRect( x: 0 , y: UIScreen.main.bounds.size.height - ZLSwithRefreshFootViewHeight, width: Body.Width, height: ZLSwithRefreshFootViewHeight))
            footView.scrollView = self
            if (isFooterViewHidden != nil){
                footView.isHidden = isFooterViewHidden!
            }
            footView.tag = ZLSwiftFootViewTag
            self.addSubview(footView)
        }
    }
    
    //MARK: nowRefresh
    //立马上拉刷新
    func nowRefresh(_ action :@escaping (() -> Void)){
        self.alwaysBounceVertical = true
        if self.headerRefreshView == nil {
            let headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRect(x: 0, y: -ZLSwithRefreshHeadViewHeight, width: Body.Width, height: ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }else{
            self.headerRefreshView?.action = action
        }
        
        self.headerRefreshView?.nowAction = action
        self.headerRefreshView?.nowLoading = true
    }
    
    func headerViewRefreshAnimationStatus(_ status:HeaderViewRefreshAnimationStatus, images:[UIImage]){
        // 箭头动画是自带的效果
        if self.headerRefreshView == nil {
            let headView:ZLSwiftHeadView = ZLSwiftHeadView(action: {},frame: CGRect(x: 0, y: -ZLSwithRefreshHeadViewHeight, width: Body.Width, height: ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }
        
        if (status != .headerViewRefreshArrowAnimation){
            self.headerRefreshView?.customAnimation = true
        }
        
        self.headerRefreshView?.animationStatus = status
        
        if (status == .headerViewRefreshLoadingAnimation){
            self.headerRefreshView?.headImageView.animationImages = images
        }else{
            self.headerRefreshView?.headImageView.image = images.first
            self.headerRefreshView?.pullImages = images
        }
        
    }
    
    //MARK: endLoadMoreData
    //数据加载完毕
    func endLoadMoreData() {
        let footView:ZLSwiftFootView = self.viewWithTag(ZLSwiftFootViewTag) as! ZLSwiftFootView
        footView.isEndLoadMore = true
        footView.isHidden = false
    }
    func starLoadMoreData() {
        let footView:ZLSwiftFootView = self.viewWithTag(ZLSwiftFootViewTag) as! ZLSwiftFootView
        if footView.isEndLoadMore == true {
            footView.isEndLoadMore = false
        }
    }

    //MARK: doneRefersh
    //完成刷新
    func doneRefresh(){
        if let headerView:ZLSwiftHeadView = self.viewWithTag(ZLSwiftHeadViewTag) as? ZLSwiftHeadView {
            headerView.stopAnimation()
        }
        refreshStatus = .normal
        toLoadMoreAction(loadMoreAction)

//                if (loadMoreAction != nil){
//                    toLoadMoreAction(loadMoreAction)
//                }
    }
    
}

