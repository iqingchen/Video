//
//  ˜.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SnapKit

let DLMPlayerAnimationTimeInterval : CGFloat = 7.0
let DLMPlayerControlBarAutoFadeOutTimeInterval : CGFloat = 0.35

class DLMPlayerControlView: UIView {
    var delegate : DLMPlayerControlViewDelegate?
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
        progressView.tintColor = UIColorFromRGB("#606060")
        progressView.trackTintColor = UIColorFromRGB("#1a1a1a")
        return progressView
    }()
    /** 滑杆 */
    lazy var videoSlider : ASValueTrackingSlider =   {
        let slider = ASValueTrackingSlider()
        slider.popUpViewCornerRadius = 0.0
        slider.popUpViewColor = RGBA(r: 19, g: 19, b: 9, a: 1)
        slider.popUpViewArrowLength = 8
        
        slider.setThumbImage(UIImage(named: "ZFPlayer_slider"), for: .normal)
        slider.maximumValue = 1
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        // slider开始滑动事件
        slider.addTarget(self, action: #selector(progressSliderTouchBegan(sender:)), for: .touchDown)
        // slider滑动中事件
        slider.addTarget(self, action: #selector(progressSliderValueChanged(sender:)), for: .valueChanged)
        // slider结束滑动事件
        slider.addTarget(self, action: #selector(progressSliderTouchEnded(sender:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(progressSliderTouchEnded(sender:)), for: .touchCancel)
        slider.addTarget(self, action: #selector(progressSliderTouchEnded(sender:)), for: .touchUpOutside)
//        slider.addTarget(self, action: #selector(progressSliderTouchEnded(sender:)), for: .touchUpInside | .touchCancel | .touchUpOutside)
        let sliderTap = UITapGestureRecognizer(target: self, action: #selector(tapSliderAction(tap:)))
        slider.addGestureRecognizer(sliderTap)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panRecognizer(sender:)))
        panRecognizer.delegate = self
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delaysTouchesBegan = true
        panRecognizer.delaysTouchesEnded = true
        panRecognizer.cancelsTouchesInView = true
        slider.addGestureRecognizer(panRecognizer)
        return slider
    }()
    /** 全屏按钮 */
    lazy var fullScreenBtn : UIButton = {
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
    var activity : NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let activity = NVActivityIndicatorView(frame: frame)
        return activity
    }()
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
    var resolutionBtn : UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.7)
        return btn
    }()
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
        btn.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.7)
        return btn
    }()
    /** 快进快退View*/
    var fastView : UIView = {
        let fastV = UIView()
        fastV.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.8)
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
    var resoultionCurrentBtn : UIButton!
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
    var isShowing : Bool!
    /** 小屏播放 */
    var isShrink : Bool = false
    /** 在cell上播放 */
    var cellVideo : Bool!
    /** 是否拖拽slider控制播放进度 */
    var dragged : Bool = false
    /** 是否播放结束 */
    var playeEnd : Bool = false
    /** 是否全屏播放 */
    var isFullScreen : Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        self.dlm_playerCancelAutoFadeOutControlView()
        if !self.isShrink && self.playeEnd {
            // 只要屏幕旋转就显示控制层
            self.dlm_playerShowControlView()
        }
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if currentOrientation == .portrait {
            self.setOrientationPortraitConstraint()
        }else {
            self.setOrientationLandscapeConstraint()
        }
    }
    
}

//MARK: - 设置UI
extension DLMPlayerControlView {
    fileprivate func setUpUI() {
        addSubViews()
        makeSubViewsConstraints()
        downLoadBtn.isHidden = true
        resolutionBtn.isHidden = true
        // 初始化时重置controlView
        dlm_playerResetControlView()
        //添加通知
        addNotification()
        listeningRotating()
        onDeviceOrientationChange()
        
        //添加按钮事件
        setBtnAction()
    }
    fileprivate func addSubViews()  {
        self.addSubview(placeholderImageView)
        self.addSubview(topImageView)
        self.addSubview(bottomImageView)
        
        bottomImageView.addSubview(startBtn)
        bottomImageView.addSubview(currentTimeLabel)
        bottomImageView.addSubview(progressView)
        bottomImageView.addSubview(videoSlider)
        bottomImageView.addSubview(fullScreenBtn)
        bottomImageView.addSubview(totalTimeLabel)
        
        topImageView.addSubview(downLoadBtn)
        self.addSubview(lockBtn)
        topImageView.addSubview(backBtn)
//        self.addSubview(activity)
        self.addSubview(repeatBtn)
        self.addSubview(playeBtn)
        self.addSubview(failBtn)
        
        self.addSubview(fastView)
        fastView.addSubview(fastImageView)
        fastView.addSubview(fastTimeLabel)
        fastView.addSubview(fastProgressView)
        
        topImageView.addSubview(resolutionBtn)
        topImageView.addSubview(titleLabel)
        self.addSubview(closeBtn)
        self.addSubview(bottomProgressView)
    }
    fileprivate func makeSubViewsConstraints() {
        self.layoutIfNeeded()
        placeholderImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        closeBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.snp.trailing).offset(7)
            make.top.equalTo(self).offset(-7)
            make.width.height.equalTo(20)
        }
        topImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(self.snp.top).offset(0)
            make.height.equalTo(50)
        }
        backBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.topImageView.snp.leading).offset(10)
            make.top.equalTo(self.topImageView.snp.top).offset(3)
            make.width.height.equalTo(40)
        }
        downLoadBtn.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(25)
            make.trailing.equalTo(topImageView.snp.trailing).offset(-10)
            make.centerY.equalTo(backBtn.snp.centerY)
        }
        resolutionBtn.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(25)
            make.trailing.equalTo(downLoadBtn.snp.leading).offset(-10)
            make.centerY.equalTo(resolutionBtn.snp.centerY)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.backBtn.snp.trailing).offset(5)
            make.centerY.equalTo(backBtn.snp.centerY)
            make.trailing.equalTo(resolutionBtn.snp.leading).offset(-10)
        }
        bottomImageView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        startBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(bottomImageView.snp.leading).offset(5)
            make.bottom.equalTo(bottomImageView.snp.bottom).offset(-5)
            make.width.height.equalTo(30)
        }
        currentTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(startBtn.snp.trailing).offset(-3)
            make.centerY.equalTo(startBtn.snp.centerY)
            make.width.equalTo(43)
        }
        fullScreenBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.trailing.equalTo(bottomImageView.snp.trailing).offset(-5)
            make.centerY.equalTo(startBtn.snp.centerY)
        }
        totalTimeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(fullScreenBtn.snp.leading).offset(3)
            make.centerY.equalTo(startBtn.snp.centerY)
            make.width.equalTo(43)
        }
        progressView.snp.makeConstraints { (make) in
            make.leading.equalTo(currentTimeLabel.snp.trailing).offset(4)
            make.trailing.equalTo(totalTimeLabel.snp.leading).offset(-4)
            make.centerY.equalTo(startBtn.snp.centerY).offset(-1)
        }
        videoSlider.snp.makeConstraints { (make) in
            make.leading.equalTo(currentTimeLabel.snp.trailing).offset(4)
            make.trailing.equalTo(totalTimeLabel.snp.leading).offset(-4)
            make.centerY.equalTo(currentTimeLabel.snp.centerY).offset(-1)
            make.height.equalTo(30)
        }
        lockBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leading).offset(15)
            make.centerY.equalTo(self.snp.centerY)
            make.width.height.equalTo(32)
        }
        repeatBtn.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
        playeBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.center.equalTo(self)
        }
//        activity.snp.makeConstraints { (make) in
//            make.center.equalTo(self)
//            make.width.height.equalTo(45)
//        }
//
//        [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//            make.width.with.height.mas_equalTo(45);
//            }];
        failBtn.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(130)
            make.height.equalTo(33)
        }
        fastView.snp.makeConstraints { (make) in
            make.width.equalTo(125)
            make.height.equalTo(80)
            make.center.equalTo(self)
        }
        fastImageView.snp.makeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.top.equalTo(5)
            make.centerX.equalTo(fastView.snp.centerX)
        }
        fastTimeLabel.snp.makeConstraints { (make) in
            make.leading.width.trailing.equalTo(0)
            make.top.equalTo(fastImageView.snp.bottom).offset(2)
        }
        fastProgressView.snp.makeConstraints { (make) in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.top.equalTo(fastTimeLabel.snp.bottom).offset(10)
        }
        bottomProgressView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(0)
            }
    }
    fileprivate func addNotification() {
        // app退到后台
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
        // app进入前台
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    /**
     *  监听设备旋转通知
     */
    func listeningRotating() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDeviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    /**
     *  屏幕方向发生变化会调用这里
     */
    func onDeviceOrientationChange() {
//        if (ZFPlayerShared.isLockScreen) { return; }
//        self.lockBtn.isHidden = !self.isFullScreen
//        self.fullScreenBtn.isSelected = self.isFullScreen
        let orientation = UIDevice.current.orientation
        if orientation == .faceUp || orientation == .faceDown || orientation == .unknown || orientation == .portraitUpsideDown {
            return
        }
        if DLMPlayerOrientationIsLandscape {
            setOrientationLandscapeConstraint()
        }else {
            setOrientationPortraitConstraint()
        }
        self.layoutIfNeeded()
    }
    func setOrientationLandscapeConstraint() {
    
    }
    func setOrientationPortraitConstraint() {
        
    }
}

//MARK: - 按钮事件
extension DLMPlayerControlView {
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
    
    @objc func playBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        delegate?.dlm_controlViewPlayAction(controlView: self, btn: btn)
    }
    func backBtnClick(btn: UIButton) {
        // 状态条的方向旋转的方向,来判断当前屏幕的方向
        let orientation = UIApplication.shared.statusBarOrientation
        // 在cell上并且是竖屏时候响应关闭事件
        delegate?.dlm_controlViewBackAction(controlView: self, btn: btn)
//        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//        // 在cell上并且是竖屏时候响应关闭事件
//        if (self.isCellVideo && orientation == UIInterfaceOrientationPortrait) {
//            if ([self.delegate respondsToSelector:@selector(zf_controlView:closeAction:)]) {
//                [self.delegate zf_controlView:self closeAction:sender];
//            }
//        } else {
//            if ([self.delegate respondsToSelector:@selector(zf_controlView:backAction:)]) {
//                [self.delegate zf_controlView:self backAction:sender];
//            }
//        }
    }
    func lockScrrenBtnClick(btn: UIButton) {
        
    }
    func closeBtnClick(btn: UIButton)  {
        delegate?.dlm_controlViewCloseAction(controlView: self, btn: btn)
    }
    func fullScreenBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        delegate?.dlm_controlViewFullScreenAction(controlView: self, btn: btn)
    }
    func repeatBtnClick(btn: UIButton)  {
        // 重置控制层View
        self.dlm_playerResetControlView()
        self.dlm_playerShowControlView()
        self.delegate?.dlm_controlViewRepeatPlayAction(controlView: self, btn: btn)
    }
    func downloadBtnClick(btn: UIButton) {
        
    }
    func resolutionBtnClick(btn: UIButton)  {
        btn.isSelected = !btn.isSelected
    }
    func centerPlayBtnClick(btn: UIButton) {
    }
    func failBtnClick(btn: UIButton) {
        
    }
}

//MARK: - 私有方法
extension DLMPlayerControlView {
    fileprivate func hideControlView() {
        self.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0)
        self.topImageView.alpha = self.playeEnd == true ? 1 : 0
        self.bottomImageView.alpha = 0
        self.lockBtn.alpha = 0
        self.bottomProgressView.alpha = 1
        // 隐藏resolutionView
        resolutionBtn.isSelected = true
        self.resolutionBtnClick(btn: self.resolutionBtn)
//        if isFullScreen && !playeEnd && !isShrink {
//            ZFPlayerShared.isStatusBarHidden = YES;
//        }
    }
    fileprivate func showControlView() {
        if self.lockBtn.isSelected {
            self.topImageView.alpha = 0
            self.bottomImageView.alpha = 0
        }else {
            self.topImageView.alpha = 1
            self.bottomImageView.alpha = 1
        }
        self.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.3)
        self.lockBtn.alpha = 1
//        if (self.isCellVideo) {
            //    self.shrink                = NO;
            //    }
        self.bottomProgressView.alpha = 0
//        ZFPlayerShared.isStatusBarHidden = NO;
    }
    
    func autoFadeOutControlView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.dlm_playerHideControlView), object: nil)
        self.perform(#selector(self.dlm_playerHideControlView), with: nil, afterDelay: TimeInterval(DLMPlayerAnimationTimeInterval))
    }
    
    //关于slider
    @objc fileprivate func progressSliderTouchBegan(sender: ASValueTrackingSlider) {
        self.dlm_playerCancelAutoFadeOutControlView()
        self.delegate?.dlm_controlViewProgressSliderTouchBegan(controlView: self, slider: sender)
    }
    @objc fileprivate func progressSliderValueChanged(sender: ASValueTrackingSlider) {
        self.delegate?.dlm_controlViewProgressSliderValueChanged(controlView: self, slider: sender)
    }
    @objc fileprivate func progressSliderTouchEnded(sender: ASValueTrackingSlider) {
        self.isShowing = true
        self.delegate?.dlm_controlViewProgressSliderTouchEnded(controlView: self, slider: sender)
    }
    /**
     *  UISlider TapAction
     */
    @objc fileprivate func tapSliderAction(tap: UITapGestureRecognizer) {
        if let tapVeiw = tap.view, tapVeiw.isKind(of: UISlider.self) {
            let slider = tapVeiw as! UISlider
            let point = tap.location(in: slider)
            let length = slider.frame.size.width
            //// 视频跳转的value
            let tapValue = point.x / length
            delegate?.dlm_controlViewProgressSliderTap(controlView: self, value: tapValue)
        }
    }
    // 不做处理，只是为了滑动slider其他地方不响应其他手势
    @objc fileprivate func panRecognizer(sender: UIPanGestureRecognizer) {}
    
    /**
     slider滑块的bounds
     */
    func thumbRect() -> CGRect {
        return videoSlider.thumbRect(forBounds: videoSlider.bounds, trackRect: videoSlider.trackRect(forBounds: videoSlider.bounds), value: self.videoSlider.value)
    }

}

//MARK: - UIGestureRecognizer Delegate
extension DLMPlayerControlView : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let rect = self.thumbRect()
        let point = touch.location(in: self.videoSlider)
        if let touchView = touch.view, touchView.isKind(of: UISlider.self) {
            // 如果在滑块上点击就不响应pan手势
            if point.x <= rect.origin.x + rect.size.width && point.x >= rect.origin.x {
                return false
            }
        }
        return true
    }
}

//MARK: - 暴露给外界的方法
extension DLMPlayerControlView {
    /**  取消延时隐藏controlView的方法*/
    func dlm_playerCancelAutoFadeOutControlView() {
        self.isShowing = false
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    /** 显示控制层*/
    func dlm_playerShowControlView() {
        if isShowing == true {
            self.dlm_playerHideControlView()
            return
        }
        self.dlm_playerCancelAutoFadeOutControlView()
        UIView.animate(withDuration: TimeInterval(DLMPlayerControlBarAutoFadeOutTimeInterval), animations: {
            self.showControlView()
        }) { (finished) in
            self.isShowing = true
            self.autoFadeOutControlView()
        }
    }
    /** 隐藏控制层 */
    func dlm_playerHideControlView() {
        if !isShowing {
            return
        }
        self.dlm_playerCancelAutoFadeOutControlView()
        UIView.animate(withDuration: TimeInterval(DLMPlayerControlBarAutoFadeOutTimeInterval), animations: { 
            self.hideControlView()
        }) { (finished) in
            self.isShowing = false
        }
    }

    /** 正在播放（隐藏placeholderImageView） */
    func dlm_playerItemPlaying() {
        UIView.animate(withDuration: 1.0) { 
            self.placeholderImageView.alpha = 0
        }
    }
    /** progress显示缓冲进度 */
    func dlm_playerSetProgress(progress: Float) {
        self.progressView.setProgress(progress, animated: false)
    }

    /** 视频加载失败 */
    func dlm_playerItemStatusFailed(error: Error) {
        failBtn.isHidden = false
    }
    /** 加载的菊花 */
    func dlm_playerActivity(animated: Bool) {
        if animated == true {
            self.activity.startAnimating()
            self.fastView.isHidden = true
        }else {
            self.activity.stopAnimating()
        }
    }
    /** 播放完了 */
    func dlm_playerPlayEnd() {
        repeatBtn.isHidden = false
        playeEnd = true
        isShowing = false
        // 隐藏controlView
        hideControlView()
        self.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.3)
//        ZFPlayerShared.isStatusBarHidden = NO;
        self.bottomProgressView.alpha = 0
    }
    /** 播放按钮状态 */
    func dlm_playerPlayBtnState(state: Bool) {
        startBtn.isSelected = state
    }
}
