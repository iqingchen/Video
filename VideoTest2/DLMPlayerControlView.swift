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
        btn.setImage(UIImage(named: "ZFPlayer_play"), for: .normal)
        btn.setImage(UIImage(named: "ZFPlayer_pause"), for: .selected)
        return btn
    }()
    /** 当前播放时长label */
    var currentTimeLabel : UILabel = {
        let currentTime = UILabel()
        currentTime.textColor = UIColor.white
        currentTime.font = UIFont.systemFont(ofSize: 12)
        currentTime.textAlignment = .center
        return currentTime
    }()
    /** 视频总时长label */
    var totalTimeLabel : UILabel = {
        let currentTime = UILabel()
        currentTime.textColor = UIColor.white
        currentTime.font = UIFont.systemFont(ofSize: 12)
        currentTime.textAlignment = .center
        return currentTime
    }()
    /** 缓冲进度条 */
    var progressView : UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        progressView.trackTintColor = UIColor.clear
        return progressView
    }()
    /** 滑杆 */
    var videoSlider : ASValueTrackingSlider!
    /** 全屏按钮 */
    var fullScreenBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "ZFPlayer_fullscreen"), for: .normal)
        btn.setImage(UIImage(named: "ZFPlayer_shrinkscreen"), for: .selected)
        return btn
    }()
    /** 锁定屏幕方向按钮 */
    var lockBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "ZFPlayer_unlock-nor"), for: .normal)
        btn.setImage(UIImage(named: "ZFPlayer_lock-nor"), for: .selected)
        return btn
    }()
    /** 系统菊花 */
    var activity : NVActivityIndicatorView!
    /** 返回按钮*/
    var backBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "ZFPlayer_back_full"), for: .normal)
        return btn
    }()
    /** 关闭按钮*/
    var closeBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "ZFPlayer_close"), for: .normal)
        return btn
    }()
    /** 重播按钮 */
    var repeatBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ZFPlayer_repeat_video"), for: .normal)
        return btn
    }()
    /** bottomView*/
    var bottomImageView : UIImageView = {
        let imageV = UIImageView()
        imageV.isUserInteractionEnabled = true
        imageV.image = UIImage(named: "ZFPlayer_bottom_shadow")
        return imageV
    }()
    /** topView */
    var topImageView : UIImageView = {
        let imageV = UIImageView()
        imageV.isUserInteractionEnabled = true
        imageV.image = UIImage(named: "ZFPlayer_top_shadow")
        return imageV
    }()
    /** 缓存按钮 */
    var downLoadBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "ZFPlayer_download"), for: .normal)
        btn.setImage(UIImage(named: "ZFPlayer_not_download"), for: .selected)
        return btn
    }()
    /** 切换分辨率按钮 */
    var resolutionBtn : UIButton!
    /** 分辨率的View */
    var resolutionView : UIView!
    /** 播放按钮 */
    var playeBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named: "ZFPlayer_play_btn"), for: .normal)
        return btn
    }()
    /** 加载失败按钮 */
    var failBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.system)
        btn.setTitle("加载失败,点击重试", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        return btn
    }()
    /** 快进快退View*/
    var fastView : UIView = {
        let fastV = UIView()
        fastV.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        fastV.layer.cornerRadius = 4
        fastV.layer.masksToBounds = true
        return fastV
    }()
    /** 快进快退进度progress*/
    var fastProgressView : UIProgressView = {
        let fastProgressV = UIProgressView()
        fastProgressV.progressTintColor = UIColor.white
        fastProgressV.trackTintColor = UIColor.lightGray.withAlphaComponent(0.4)
        return fastProgressV
    }()
    /** 快进快退时间*/
    var fastTimeLabel : UILabel = {
        let fastTime = UILabel()
        fastTime.textColor = UIColor.white
        fastTime.font = UIFont.systemFont(ofSize: 14)
        fastTime.textAlignment = .center
        return fastTime
    }()
    /** 快进快退ImageView*/
    var fastImageView : UIImageView = {
        let fastImageV = UIImageView()
        return fastImageV
    }()
    /** 当前选中的分辨率btn按钮 */
    var resoultionCurrentBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        return btn
    }()
    /** 占位图 */
    var placeholderImageView : UIImageView = {
        let placeholderImageV = UIImageView()
        placeholderImageV.isUserInteractionEnabled = true
        return placeholderImageV
    }()
    /** 控制层消失时候在底部显示的播放进度progress */
    var bottomProgressView : UIProgressView = {
        let bottomProgressV = UIProgressView()
        bottomProgressV.progressTintColor = UIColor.white
        bottomProgressV.trackTintColor = UIColor.clear
        return bottomProgressV
    }()
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
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBtnAction() {
        startBtn.addTarget(self, action: #selector(self.playBtnClick(btn:)), for: .touchUpInside)
        backBtn.addTarget(self, action: #selector(self.backBtnClick(btn:)), for: .touchUpInside)
        lockBtn.addTarget(self, action: #selector(self.lockScrrenBtnClick(btn:)), for: .touchUpInside)
        closeBtn.addTarget(self, action: #selector(self.closeBtnClick(btn:)), for: .touchUpInside)
        fullScreenBtn.addTarget(self, action: #selector(self.fullScreenBtnClick(btn:)), for: .touchUpInside)
        repeatBtn.addTarget(self, action: #selector(self.repeatBtnClick(btn:)), for: .touchUpInside)
        downLoadBtn.addTarget(self, action: #selector(self.downloadBtnClick(btn:)), for: .touchUpInside)
        resolutionBtn.addTarget(self, action: #selector(self.resolutionBtnClick(btn:)), for: .touchUpInside)
        playeBtn.addTarget(self, action: #selector(self.centerPlayBtnClick(btn:)), for: .touchUpInside)
        failBtn.addTarget(self, action: #selector(self.failBtnClick(btn:)), for: .touchUpInside)
    }
    
}

//MARK: - 按钮事件
extension DLMPlayerControlView {
    @objc func playBtnClick(btn: UIButton) {
        
    }
    func backBtnClick(btn: UIButton) {
        
    }
    func lockScrrenBtnClick(btn: UIButton) {
        
    }
    func closeBtnClick(btn: UIButton)  {
        
    }
    func fullScreenBtnClick(btn: UIButton) {
        
    }
    func repeatBtnClick(btn: UIButton)  {
        
    }
    func downloadBtnClick(btn: UIButton) {
        
    }
    func resolutionBtnClick(btn: UIButton)  {
        
    }
    func centerPlayBtnClick(btn: UIButton) {
    }
    func failBtnClick(btn: UIButton) {
        
    }
}
