//
//  DLMBrightnessView.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

final class DLMBrightnessView: UIView {
    
    //MARK: - 公开属性
    /** 调用单例记录播放状态是否锁定屏幕方向*/
    var isLockScreen : Bool?
    /** 是否允许横屏,来控制只有竖屏的状态*/
    var isAllowLandscape : Bool?
    var isStatusBarHidden : Bool?
    /** 是否是横屏状态 */
    var isLandscape : Bool?
    
    //MARK: - 私有属性
    fileprivate var backImage : UIImageView!
    fileprivate var title : UILabel!
    fileprivate var longView : UIView!
    fileprivate var tipArray : [UIImageView] = []
    fileprivate var orientationDidChange : Bool!
    
    //单例
    static let sharedBrightnessView = DLMBrightnessView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
