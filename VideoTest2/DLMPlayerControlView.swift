//
//  DLMPlayerControlView.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

let DLMPlayerAnimationTimeInterval : CGFloat = 7.0
let DLMPlayerControlBarAutoFadeOutTimeInterval : CGFloat = 0.35

class DLMPlayerControlView: UIView {
    /** 标题 */
    var titleLabel : UILabel = {
        let title = UILabel()
        title.textColor = UIColor.white
        title.font = UIFont.systemFont(ofSize: 15)
        return title
    }()
    /** 开始播放按钮 */
    var startBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "ZFPlayer_unlock"), for: .normal)
        btn.setImage(UIImage(named: "ZFPlayer_pause"), for: .selected)
        btn.addTarget(self, action: #selector(self.playBtnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    /** 当前播放时长label */
    var currentTimeLabel : UILabel!
    /** 视频总时长label */
    var totalTimeLabel : UILabel!
    /** 缓冲进度条 */
    var progressView : UIProgressView!
    /** 滑杆 */
    var videoSlider : ASValueTrackingSlider!
    /** 全屏按钮 */
    var fullScreenBtn : UIButton!
    /** 锁定屏幕方向按钮 */
    var lockBtn : UIButton!
    /** 系统菊花 */
    var activity : NVActivityIndicatorView!
    /** 返回按钮*/
    var backBtn : UIButton!
    /** 关闭按钮*/
    var closeBtn : UIButton!
    /** 重播按钮 */
    var repeatBtn : UIButton!
    /** bottomView*/
    var bottomImageView : UIImageView!
    /** topView */
    var topImageView : UIImageView!
    /** 缓存按钮 */
    var downLoadBtn : UIButton!
    /** 切换分辨率按钮 */
    var resolutionBtn : UIButton!
    /** 分辨率的View */
    var resolutionView : UIView!
    /** 播放按钮 */
    var playeBtn : UIButton!
    /** 加载失败按钮 */
    var failBtn : UIButton!
    /** 快进快退View*/
    var fastView : UIView!
    /** 快进快退进度progress*/
    var fastProgressView : UIProgressView!
    /** 快进快退时间*/
    var fastTimeLabel : UILabel!
    /** 快进快退ImageView*/
    var fastImageView : UIImageView!
    /** 当前选中的分辨率btn按钮 */
    var resoultionCurrentBtn : UIButton!
    /** 占位图 */
    var placeholderImageView : UIImageView!
    /** 控制层消失时候在底部显示的播放进度progress */
    var bottomProgressView : UIProgressView!
    /** 分辨率的名称 */
    var resolutionArray : [String] = []
    
    /** 显示控制层 */
    var showing : Bool!
    /** 小屏播放 */
    var shrink : Bool!
    /** 在cell上播放 */
    var cellVideo : Bool!
    /** 是否拖拽slider控制播放进度 */
    var dragged : Bool!
    /** 是否播放结束 */
    var playeEnd : Bool!
    /** 是否全屏播放 */
    var fullScreen : Bool!
    
    override init(frame: CGRect) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - 按钮事件
extension DLMPlayerControlView {
    @objc func playBtnClick(btn: UIButton) {
        
    }
}
