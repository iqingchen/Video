//
//  DLMPlayerView.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

enum DLMPlayerLayerGravity : Int{
    case Resize = 0        // 非均匀模式。两个维度完全填充至整个视图区域
    case Aspect = 1       // 等比例填充，直到一个维度到达区域边界
    case AspectFill = 2    // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
}
enum DLMPlayerState {
    case Failed     // 播放失败
    case Buffering  // 缓冲中
    case Playing    // 播放中
    case Stopped    // 停止播放
    case Pause      // 暂停播放
}
enum PanDirection : Int {
    case HorizontalMoved = 0
    case VerticalMoved = 1
}
class DLMPlayerView: UIView {
    //MARK: - 外部属性
    /** 视频model */
    /** 设置playerLayer的填充模式 */
    var playerLayerGravity : DLMPlayerLayerGravity?
    /** 是否有下载功能(默认是关闭) */
    var hasDownload : Bool!
    /** 是否开启预览图 */
    var hasPreviewView : Bool!
    /** 设置代理 */
    var delegate : DLMPlayerViewDelegate?
    /** 是否被用户暂停 */
    var isPauseByUser : Bool!
    /** 播发器的几种状态 */
    var state : DLMPlayerState?
    /** 静音（默认为NO）*/
    var mute : Bool = false
    /** 当cell划出屏幕的时候停止播放（默认为NO） */
    var stopPlayWhileCellNotVisable : Bool?
    /** 当cell播放视频由全屏变为小屏时候，是否回到中间位置(默认YES) */
    var cellPlayerOnCenter : Bool?
    
    //MARK: - 私有属性
    /** 播放属性 */
    var player : AVPlayer!
    var playerItem : AVPlayerItem?
    var urlAsset : AVURLAsset!
    lazy var imageGenerator : AVAssetImageGenerator = {
        let imageGeneratorT = AVAssetImageGenerator(asset: self.urlAsset)
        return imageGeneratorT
    }()
    /** playerLayer */
    var playerLayer : AVPlayerLayer?

    var timeObserve : Any?
    /** 滑杆 */
    var volumeViewSlider : UISlider!
    /** 用来保存快进的总时长 */
    var sumTime : CGFloat!
    /** 定义一个实例变量，保存枚举值 */
    var panDirection : PanDirection!
    /** 播发器的几种状态 */
//    var state : DLMPlayerState!
    /** 是否为全屏 */
    var isFullScreen : Bool = false
    /** 是否锁定屏幕方向 */
    var isLocked : Bool = false
    /** 是否在调节音量*/
    var isVolume : Bool = false
    /** 是否被用户暂停 */
//    var isPauseByUser : Bool!
    /** 是否播放本地文件 */
    var isLocalVideo : Bool!
    /** slider上次的值 */
    var sliderLastValue : Float = 0
    /** 是否再次设置URL播放视频 */
    var repeatToPlay : Bool!
    /** 播放完了*/
    var playDidEnd : Bool!
    /** 进入后台*/
    var didEnterBackground : Bool!
    /** 是否自动播放 */
    var isAutoPlay : Bool!
    /** 单击 */
    var singleTap : UITapGestureRecognizer!
    /** 双击 */
    var doubleTap : UITapGestureRecognizer!
    /** 视频URL的数组 */
    var videoURLArray : [String] = []
    /** slider预览图 */
    var thumbImg : UIImage!
    /** 亮度view */
    lazy var brightnessView : DLMBrightnessView = {
        let bv = DLMBrightnessView.sharedBrightnessView
        return bv
    }()
    /** 视频填充模式 */
    var videoGravity : String = AVLayerVideoGravityResizeAspect
    
//    #pragma mark - UITableViewCell PlayerView
//    
//    /** palyer加到tableView */
//    @property (nonatomic, strong) UITableView            *tableView;
//    /** player所在cell的indexPath */
//    @property (nonatomic, strong) NSIndexPath            *indexPath;
//    /** ViewController中页面是否消失 */
//    @property (nonatomic, assign) BOOL                   viewDisappear;
    /** 是否在cell上播放video */
    var isCellVideo : Bool = false
//    /** 是否缩小视频在底部 */
    var isBottomVideo : Bool = false
//    /** 是否切换分辨率*/
//    @property (nonatomic, assign) BOOL                   isChangeResolution;
//    /** 是否正在拖拽 */
//    @property (nonatomic, assign) BOOL                   isDragged;

    var controlView : DLMPlayerControlView?
    var playerModel : DLMPlayerModel?
    var seekTime : Int?
    var videoURL : URL?
    var resolutionDic : [String:String]?{
        didSet(newResolutionDic){
            resolutionDic = newResolutionDic
            self.videoURLArray = Array(resolutionDic!.values)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeThePlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        if let layer = playerLayer {
            layer.frame = self.bounds
        }
//        [UIApplication sharedApplication].statusBarHidden = NO;
    }
}

//MARK: - 初始化Player
extension DLMPlayerView {
    fileprivate func initializeThePlayer() {
        cellPlayerOnCenter = true
    }
    fileprivate func configDLMPlayer() {
        
        urlAsset = AVURLAsset(url: self.videoURL!)
        // 初始化playerItem
        setNewPlayerItem(newPlayerItem: AVPlayerItem(asset: self.urlAsset))
//        self.playerItem = AVPlayerItem(asset: self.urlAsset)
        // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
        self.player = AVPlayer(playerItem: playerItem)
        
        // 初始化playerLayer
        self.playerLayer = AVPlayerLayer(player: player)
        
        self.backgroundColor = UIColor.black
        // 此处为默认视频填充模式
        self.playerLayer?.videoGravity = self.videoGravity;
        
        // 自动播放
        self.isAutoPlay = true
        
        // 添加播放进度计时器
        createTimer()
        
        // 获取系统音量
        configureVolume()
        
        // 本地文件不设置ZFPlayerStateBuffering状态
        if self.videoURL?.scheme == "file" {
            self.state = DLMPlayerState.Playing
            self.isLocalVideo = true
//            self.controlView?.delegate?.dlm_playerDownloadBtnState(state: false)
        }else {
            self.state = DLMPlayerState.Buffering
            self.isLocalVideo = false
//            self.controlView?.delegate?.dlm_playerDownloadBtnState(state: true)
        }
        // 开始播放
        play()
        self.isPauseByUser = false
    }
}

//MARK: - 设置方法
extension DLMPlayerView {
    fileprivate func setNewLayerGravity(newLayerGravity: DLMPlayerLayerGravity) {
        playerLayerGravity = newLayerGravity
        if newLayerGravity == DLMPlayerLayerGravity.Resize {
            self.playerLayer?.videoGravity = AVLayerVideoGravityResize
            self.videoGravity = AVLayerVideoGravityResize
        }else if(newLayerGravity == DLMPlayerLayerGravity.Aspect){
            self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            self.videoGravity = AVLayerVideoGravityResizeAspect
        }else if(newLayerGravity == DLMPlayerLayerGravity.AspectFill){
            self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.videoGravity = AVLayerVideoGravityResizeAspectFill
        }
    }
    //设置播放状态
    fileprivate func setNewState(newState: DLMPlayerState) {
        state = newState
        // 控制菊花显示、隐藏
        self.controlView?.dlm_playerActivity(animated: newState == DLMPlayerState.Buffering)
        if newState == DLMPlayerState.Playing || newState == DLMPlayerState.Buffering {
            // 隐藏占位图
            self.controlView?.dlm_playerItemPlaying()
        }else if newState == DLMPlayerState.Failed {
            let error = self.playerItem?.error
            self.controlView?.dlm_playerItemStatusFailed(error: error!)
        }
    }
    fileprivate func setNewPlayerItem(newPlayerItem: AVPlayerItem) {
        //根据playerItem，来添加移除观察者
        if let item = playerItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "loadedTimeRanges")
            item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
        playerItem = newPlayerItem
        if let item = playerItem {
            NotificationCenter.default.addObserver(self, selector: #selector(self.moviePlayDidEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            // 缓冲区空了，需要等待数据
            item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            // 缓冲区有足够数据可以播放了
            item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    fileprivate func setNewControlView(newControlView: DLMPlayerControlView){
            controlView = newControlView
            //            controlView.delegate = self
            self.layoutIfNeeded()
            self.addSubview(newControlView)
            controlView?.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets.zero)
            })
    }
    fileprivate func setNewPlayerModel(newPlayerModel: DLMPlayerModel) {
        playerModel = newPlayerModel
        //            NSCAssert(playerModel.fatherView, @"请指定playerView的faterView");
        
        if ((playerModel?.seekTime) != nil) {
            self.seekTime = playerModel?.seekTime
        }
        //            [self.controlView zf_playerModel:playerModel];
        // 分辨率
        if ((playerModel?.resolutionDic) != nil) {
            self.resolutionDic = playerModel?.resolutionDic
        }
        //
        //            if (playerModel.tableView && playerModel.indexPath && playerModel.videoURL) {
        //                [self cellVideoWithTableView:playerModel.tableView AtIndexPath:playerModel.indexPath];
        //            }
        self.addPlayerToFatherView(view: newPlayerModel.fatherView)
        self.setNewVideoURL(newVideoURL: (playerModel?.videoURL)! as URL)
        //            [self addPlayerToFatherView:playerModel.fatherView];
        //            self.videoURL = playerModel.videoURL;
    }
    func setNewVideoURL(newVideoURL: URL) {
        videoURL = newVideoURL
        // 每次加载视频URL都设置重播为NO
        self.repeatToPlay = false
        self.playDidEnd   = false
        // 添加通知
        self.addNotifications()
        self.isPauseByUser = true
        // 添加手势
        self.createGesture()
    }
}

//MARK: - 一些私有方法
extension DLMPlayerView {
    /**  player添加到fatherView上*/
    fileprivate func addPlayerToFatherView(view: UIView) {
        // 这里应该添加判断，因为view有可能为空，当view为空时[view addSubview:self]会crash
        self.removeFromSuperview()
        view.addSubview(self)
        self.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        })
        
    }
    
    //创建手势
    fileprivate func createGesture() {
        // 单击
        self.singleTap = UITapGestureRecognizer(target: self, action: #selector(self.singleTapAction(tap:)))
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(singleTap)
        // 双击(播放/暂停)
        self.doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapAction(tap:)))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTap)
        // 解决点击当前view时候响应其他控件事件
        singleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        // 双击失败响应单击事件
        singleTap.require(toFail: doubleTap)
    }
    
    fileprivate func createTimer() {
        self.timeObserve = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: nil, using: {[weak self] (time) in
            let currentItem = self?.playerItem
            let loadRanges = currentItem?.seekableTimeRanges
            if let loadRangesTemp = loadRanges {
                if let currentItemTemp = currentItem {
                    if(loadRangesTemp.count > 0 && currentItemTemp.duration.timescale != 0){
                        let currentTime : Int = Int(CMTimeGetSeconds(currentItemTemp.currentTime()))
                        let totalTime = Int(Int64(currentItemTemp.duration.value) / Int64(currentItemTemp.duration.timescale))
                        let value = Float(CMTimeGetSeconds(currentItemTemp.currentTime())) / Float(totalTime)
                        self?.controlView?.dlm_playerCurrentTime(currentTime: currentTime, totalTime: totalTime, value: value)
                    }
                }
            }
        })
        
    }
    fileprivate func configureVolume() {
        
    }
    
    /**
     *  缓冲较差时候回调这里
     */
    func bufferingSomeSecond() {
        self.setNewState(newState: .Buffering)
        // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        var isBuffering = false
        if isBuffering {
            return
        }
        // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        self.player.pause()
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 1.0 )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            // 如果此时用户已经暂停了，则不再需要开启播放了
            if self.isPauseByUser == true {
                isBuffering = false
                return
            }
            self.play()
            // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
            isBuffering = false
            if let item = self.playerItem {
                if !item.isPlaybackLikelyToKeepUp {
                    self.bufferingSomeSecond()
                }
            }
        }

    }
    /**
     *  计算缓冲进度
     *
     *  @return 缓冲进度
     */
    func availableDuration() -> TimeInterval {
        let loadedTimeRanges = player.currentItem?.loadedTimeRanges
        let timeRange = loadedTimeRanges?.first?.timeRangeValue
        var result : TimeInterval = 0
        if let time = timeRange {
            let startSeconds = CMTimeGetSeconds(time.start)
            let durationSeconds = CMTimeGetSeconds(time.duration)
            result = startSeconds + durationSeconds
        }
        return result
    }
    /** 全屏 */
   
    func _fullScreenAction() {
//        - (void)_fullScreenAction {
//            if (ZFPlayerShared.isLockScreen) {
//                [self unLockTheScreen];
//                return;
//            }
//            if (self.isFullScreen) {
//                [self interfaceOrientation:UIInterfaceOrientationPortrait];
//                self.isFullScreen = NO;
//                return;
//            } else {
//                UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//                if (orientation == UIDeviceOrientationLandscapeRight) {
//                    [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
//                } else {
//                    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
//                }
//                self.isFullScreen = YES;
//            }
//        }
    }

}

//MARK: - 添加通知
extension DLMPlayerView {
    //添加观察者、通知
    fileprivate func addNotifications() {
        // app退到后台
        NotificationCenter.default.addObserver(self, selector:#selector(self.appDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
         // app进入前台
        NotificationCenter.default.addObserver(self, selector:#selector(self.appDidEnterPlayground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
         // 监测设备方向
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector:#selector(self.onDeviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.onStatusBarOrientationChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
    }
}

//MARK: - 通知
extension DLMPlayerView {
    // app退到后台
    @objc fileprivate func appDidEnterBackground() {
        
    }
    // app进入前台
    @objc fileprivate func appDidEnterPlayground() {
    
    }
    /**
     *  从xx秒开始播放视频跳转
     *
     *  @param dragedSeconds 视频跳转的秒数
     */
    func seekToTime(dragedSeconds: Int, completionHandler: (()->Void)?) {
        if let item = self.player.currentItem, item.status == .readyToPlay {
            // seekTime:completionHandler:不能精确定位
            // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
            // 转换成CMTime才能给player来控制播放进度
            self.controlView?.dlm_playerActivity(animated: true)
            self.player.pause()
            let dragedCMTime = CMTimeMake(Int64(dragedSeconds), 1)

//            self.player.seek(to: CMTime(dragedSeconds), toleranceBefore: CMTime(value: 1, timescale: 1), toleranceAfter: CMTime(value: 1, timescale: 1), completionHandler: { (finished) in
//                self.controlView?.dlm_playerActivity(animated: false)
//                //视频跳转回调
////                completionHandler
//                self.player.play()
//                self.seekTime = 0
////                self
//            })
        }
//        completionHandler{[weak self] ()->()in
//        
//        }
    }
//    - (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler {
//    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
//    // seekTime:completionHandler:不能精确定位
//    // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
//    // 转换成CMTime才能给player来控制播放进度
//    [self.controlView zf_playerActivity:YES];
//    [self.player pause];
//    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
//    __weak typeof(self) weakSelf = self;
//    [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
//    [weakSelf.controlView zf_playerActivity:NO];
//    // 视频跳转回调
//    if (completionHandler) { completionHandler(finished); }
//    [weakSelf.player play];
//    weakSelf.seekTime = 0;
//    weakSelf.isDragged = NO;
//    // 结束滑动
//    [weakSelf.controlView zf_playerDraggedEnd];
//    if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !weakSelf.isLocalVideo) { weakSelf.state = ZFPlayerStateBuffering; }
//    
//    }];
//    }
//    }

    // 屏幕转屏
    func interfaceOrientation(orientation: UIInterfaceOrientation) {
        if orientation == .landscapeRight || orientation == .landscapeLeft {
            // 设置横屏
            
        }
    }
//    - (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
//    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
//    // 设置横屏
//    [self setOrientationLandscapeConstraint:orientation];
//    } else if (orientation == UIInterfaceOrientationPortrait) {
//    // 设置竖屏
//    [self setOrientationPortraitConstraint];
//    }
//    }

    //屏幕方向发生变化会调用这里
    @objc fileprivate func onDeviceOrientationChange() {
        
    }
    // 状态条变化通知（在前台播放才去处理）
    @objc fileprivate func onStatusBarOrientationChange() {
        
    }
    //播放完了
    @objc fileprivate func moviePlayDidEnd(notification: NSNotification) {
        if self.state == DLMPlayerState.Stopped {
            playDidEnd = true
//            self.controlView
//            self.state = ZFPlayerStateStopped;
            //    if (self.isBottomVideo && !self.isFullScreen) { // 播放完了，如果是在小屏模式 && 在bottom位置，直接关闭播放器
            //    self.repeatToPlay = NO;
            //    self.playDidEnd   = NO;
            //    [self resetPlayer];
            //    } else {
            //    if (!self.isDragged) { // 如果不是拖拽中，直接结束播放
            //    self.playDidEnd = YES;
            //    [self.controlView zf_playerPlayEnd];
            //    }

        }
    }
    
    //kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? AVPlayerItem == self.player.currentItem {
            if let item = self.player.currentItem {
                if keyPath == "status" {
                    if item.status == .readyToPlay {
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
                        // 添加playerLayer到self.layer
                        self.layer.insertSublayer(self.playerLayer!, at: 0)
                        self.setNewState(newState: .Playing)
                        // 加载完成后，再添加平移手势
                        // 添加平移手势，用来控制音量、亮度、快进快退
                        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panDirection(pan:)))
                        panRecognizer.delegate = self
                        panRecognizer.maximumNumberOfTouches = 1
                        panRecognizer.delaysTouchesBegan = true
                        panRecognizer.delaysTouchesEnded = true
                        panRecognizer.cancelsTouchesInView = true
                        self.addGestureRecognizer(panRecognizer)
                        //跳到xx秒播放视频
                        if (self.seekTime != nil) {
//                            self.
                        }
                        self.player.isMuted = self.mute
                    }else if item.status == .failed {
                        self.setNewState(newState: .Failed)
                    }
                }else if keyPath == "loadedTimeRanges" {
                    //计算缓冲进度
                    let timeInterval = self.availableDuration()
                    let duration = playerItem?.duration
                    let totalDuration = CMTimeGetSeconds(duration!)
                    self.controlView?.dlm_playerSetProgress(progress: Float(timeInterval) / Float(totalDuration))
                }else if keyPath == "playbackBufferEmpty" {
                    // 当缓冲是空的时候
                    if let item = self.playerItem, item.isPlaybackBufferEmpty {
                        self.setNewState(newState: .Buffering)
                        self.bufferingSomeSecond()
                    }
                }else if keyPath == "playbackLikelyToKeepUp" {
                    // 当缓冲好的时候
                    if let item = self.playerItem {
                        if item.isPlaybackLikelyToKeepUp && self.state == DLMPlayerState.Buffering {
                            self.setNewState(newState: .Playing)
                        }
                    }
                }
            }
            
        }

    }

}

//MARK: - UIPanGestureRecognizer手势方法
extension DLMPlayerView {
    //调节声音和亮度
    @objc fileprivate func panDirection(pan: UIPanGestureRecognizer) {
        
    }
    //轻拍方法
    @objc fileprivate func singleTapAction(tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            if self.isBottomVideo && !self.isFullScreen {
                _fullScreenAction()
            }else {
                if self.playDidEnd == true {
                    return
                }else {
                    self.controlView?.dlm_playerShowControlView()
                }
            }
        }
    }
    //双击播放／暂停
    @objc fileprivate func doubleTapAction(tap: UITapGestureRecognizer) {
        if playDidEnd == true {
            return
        }
        //显示控制层
        self.controlView?.dlm_playerCancelAutoFadeOutControlView()
        self.controlView?.dlm_playerShowControlView()
        if self.isPauseByUser == true {
            self.play()
        }else {
            self.pause()
        }
        if !isAutoPlay {
            isAutoPlay = true
            self.configDLMPlayer()
        }
    }
}
//MARK: - UIGestureRecognizer Delegate代理
extension DLMPlayerView : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            if (isCellVideo && !isFullScreen) || playDidEnd || isLocked {
                return false
            }
        }
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            if isBottomVideo && !isFullScreen {
                return false
            }
        }
        if let tView = touch.view, tView.isKind(of: UISlider.self) {
            return false
        }
        return true
    }

}
//MARK: - 暴露给外界的方法
extension DLMPlayerView {
    //指定播放的控制层和模型
    //控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
    func playerControlView(frame: CGRect, playerModel: DLMPlayerModel) {
        //指定默认控制层
        let defaultControlView = DLMPlayerControlView(frame: frame)
        defaultControlView.delegate = self
        self.setNewControlView(newControlView: defaultControlView)
        self.setNewPlayerModel(newPlayerModel: playerModel)
    }
    //使用自带的控制层时候可使用此API
    func playerModel(playModel: DLMPlayerModel) {
        // 指定默认控制层
        let defaultControlView = DLMPlayerControlView()
        self.controlView = defaultControlView
        self.playerModel = playModel
    }
    //自动播放，默认不自动播放
    func autoPlayTheVideo() {
        configDLMPlayer()
    }
    //播放
    func play() {
        self.controlView?.dlm_playerPlayBtnState(state: true)
        if self.state == DLMPlayerState.Pause {
            setNewState(newState: .Playing)
//            self.state = DLMPlayerState.Playing
        }
        self.isPauseByUser = false
        player.play()
        if !self.isBottomVideo {
            // 显示控制层
            self.controlView?.dlm_playerCancelAutoFadeOutControlView()
            self.controlView?.dlm_playerShowControlView()
        }
    }
    
    //暂停
    func pause() {
        self.controlView?.dlm_playerPlayBtnState(state: false)
        if self.state == DLMPlayerState.Playing {
            self.setNewState(newState: .Pause)
        }
        self.isPauseByUser = true
        player.pause()
    }
}

//MARK: - DLMPlayerControlViewDelegate代理方法
extension DLMPlayerView : DLMPlayerControlViewDelegate {
    func dlm_controlViewPlayAction(controlView: DLMPlayerControlView, btn: UIButton) {
        self.isPauseByUser = !self.isPauseByUser
        if isPauseByUser == true {
            self.pause()
            if state == DLMPlayerState.Playing {
                setNewState(newState: .Pause)
            }
        }else {
            self.play()
            if state == DLMPlayerState.Pause {
                setNewState(newState: .Playing)
            }
        }
        if !self.isAutoPlay {
            self.isAutoPlay = true
            self.configDLMPlayer()
        }
    }
    
    func dlm_controlViewBackAction(controlView: DLMPlayerControlView, btn: UIButton) {
        if !self.isFullScreen {
            // player加到控制器上，只有一个player时候
            self.pause()
            delegate?.dlm_playerBackAction()
        }else {
            self.interfaceOrientation(orientation: .portrait)
        }
    }
    
    func dlm_controlViewCloseAction(controlView: DLMPlayerControlView, btn: UIButton) {
        
    }
    func dlm_controlViewFullScreenAction(controlView: DLMPlayerControlView, btn: UIButton) {
        
    }
    func dlm_controlViewLockScreenAction(controlView: DLMPlayerControlView, btn: UIButton) {
        
    }
    func dlm_controlViewCenterPlayAction(controlView: DLMPlayerControlView, btn: UIButton) {
        
    }
    func dlm_controlViewRepeatPlayAction(controlView: DLMPlayerControlView, btn: UIButton) {
        
    }
    func dlm_controlViewFailAction(controlView: DLMPlayerControlView, btn: UIButton) {
        
    }
    
    //关于slider
    func dlm_controlViewProgressSliderTap(controlView: DLMPlayerControlView, value: CGFloat) {
        // 视频总时间长度
        if let item = playerItem {
            let total = Int(item.duration.value) / Int(item.duration.timescale)
             //计算出拖动的当前秒数
            
            let dragedSeconds = floorf(Float(total) * Float(value))
            self.controlView?.dlm_playerPlayBtnState(state: true)
            self.seekToTime(dragedSeconds: Int(dragedSeconds), completionHandler: nil)
        }
//        [self seekToTime:dragedSeconds completionHandler:^(BOOL finished) {}];
    }
    func dlm_controlViewProgressSliderTouchBegan(controlView: DLMPlayerControlView, slider: UISlider) {
        
    }
    func dlm_controlViewProgressSliderValueChanged(controlView: DLMPlayerControlView, slider: UISlider) {
        // 拖动改变视频播放进度
        if let item = player.currentItem, item.status == AVPlayerItemStatus.readyToPlay {
            var style = false
            let value = slider.value - self.sliderLastValue
            if value > 0 {
                style = true
            }
            if value < 0 {
                style = false
            }
            if value == 0 {
                return
            }
            self.sliderLastValue = slider.value
            let totalTime = Int(item.duration.value) / Int(item.duration.timescale)
            
            ////计算出拖动的当前秒数
            let dragedSeconds = floorf(Float(totalTime) * slider.value)
            //转换成CMTime才能给player来控制播放进度
//            let dragedCMTime = CMTimeMake(Int64(dragedSeconds), 1)
            controlView.dlm_playerDraggedTime(draggedTime: Int(dragedSeconds), totalTime: totalTime, forawrd: style, preview: false)
            
            if totalTime > 0 {
                // 当总时长 > 0时候才能拖动slider
                if self.isFullScreen && self.hasPreviewView {
                    
                }
            }else {
                // 此时设置slider值为0
                slider.value = 0;
            }
        }else {
            // player状态加载失败
            // 此时设置slider值为0
            slider.value = 0
        }
    }
    
    func dlm_controlViewProgressSliderTouchEnded(controlView: DLMPlayerControlView, slider: UISlider) {
        if let item = player.currentItem, item.status == AVPlayerItemStatus.readyToPlay {
            self.isPauseByUser = false
//            self.isDragged = NO;
            // 视频总时间长度
            let total = Int(item.duration.value) / Int(item.duration.timescale)
            //计算出拖动的当前秒数
            
            let dragedSeconds = floorf(Float(total) * Float(slider.value))
            self.seekToTime(dragedSeconds: Int(dragedSeconds), completionHandler: nil)
        }
    }
    
}

//
protocol DLMPlayerViewDelegate {
    func dlm_playerBackAction()
}
