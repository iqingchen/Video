//
//  DLMPlayerModel.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

class DLMPlayerModel: NSObject {
    /** 视频标题 */
    var title : String = ""
    /** 视频URL */
    var videoURL : NSURL?
    /** 视频封面本地图片 */
    var placeholderImage : UIImage?
    /**
     * 视频封面网络图片url
     * 如果和本地图片同时设置，则忽略本地图片，显示网络图片
     */
    var placeholderImageURLString : String = ""
    /**
     * 视频分辨率字典, 分辨率标题与该分辨率对应的视频URL.
     * 例如: @{@"高清" : @"https://xx/xx-hd.mp4", @"标清" : @"https://xx/xx-sd.mp4"}
     */
    var resolutionDic : [String:String]?
    /** 从xx秒开始播放视频(默认0) */
    var seekTime : Int = 0
    //todo不做tableView中的视频，下面的属性就用不到
//     cell播放视频，以下属性必须设置值
//    var tableView : UITableView?
//    /** cell所在的indexPath */
//    var indexPath : IndexPath?
    /** 播放器View的父视图（必须指定父视图）*/
    var fatherView : UIView!
    
    // 自定义构造函数
    init(dict: [NSString : NSObject]) {
        super.init()
        setValuesForKeys(dict as [String : Any])
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
