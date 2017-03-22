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
    var mute : Bool!
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
    var isFullScreen : Bool!
    /** 是否锁定屏幕方向 */
    var isLocked : Bool!
    /** 是否在调节音量*/
    var isVolume : Bool!
    /** 是否被用户暂停 */
//    var isPauseByUser : Bool!
    /** 是否播放本地文件 */
    var isLocalVideo : Bool!
    /** slider上次的值 */
    var sliderLastValue : Bool!
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
//    /** 是否在cell上播放video */
//    @property (nonatomic, assign) BOOL                   isCellVideo;
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
    
}

//MARK: - 初始化Player
extension DLMPlayerView {
    fileprivate func initializeThePlayer() {
        cellPlayerOnCenter = true
    }
    fileprivate func configDLMPlayer() {
        urlAsset = AVURLAsset(url: self.videoURL!)
        // 初始化playerItem
        self.playerItem = AVPlayerItem(asset: self.urlAsset)
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
            self.controlView?.delegate?.dlm_playerDownloadBtnState(state: false)
        }else {
            self.state = DLMPlayerState.Buffering
            self.isLocalVideo = false
            self.controlView?.delegate?.dlm_playerDownloadBtnState(state: true)
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
//
//        - (void)createGesture {
//            // 单击
//            self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
//            self.singleTap.delegate                = self;
//            self.singleTap.numberOfTouchesRequired = 1; //手指数
//            self.singleTap.numberOfTapsRequired    = 1;
//            [self addGestureRecognizer:self.singleTap];
//            
//            // 双击(播放/暂停)
//            self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
//            self.doubleTap.delegate                = self;
//            self.doubleTap.numberOfTouchesRequired = 1; //手指数
//            self.doubleTap.numberOfTapsRequired    = 2;
//            
//            [self addGestureRecognizer:self.doubleTap];
//            
//            // 解决点击当前view时候响应其他控件事件
//            [self.singleTap setDelaysTouchesBegan:YES];
//            [self.doubleTap setDelaysTouchesBegan:YES];
//            // 双击失败响应单击事件
//            [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
//        }
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
                        let value = CGFloat(CMTimeGetSeconds(currentItemTemp.currentTime())) / CGFloat(totalTime)
                        self?.controlView?.delegate?.dlm_playerCurrentTime(currentTime: currentTime, totalTime: totalTime, sliderValue: value)
                    }
                }
            }
        })
        
    }
    fileprivate func configureVolume() {
        
    }
    
    //播放
    fileprivate func play() {
        self.controlView?.dlm_playerPlayBtnState(state: true)
        if self.state == DLMPlayerState.Pause {
            self.state = DLMPlayerState.Playing
        }
        self.isPauseByUser = false
        player.play()
        if !self.isBottomVideo {
            // 显示控制层
            self.controlView?.dlm_playerCancelAutoFadeOutControlView()
            self.controlView?.dlm_playerShowControlView()
        }
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
    

}

//MARK: - 暴露给外界的方法
extension DLMPlayerView {
    //指定播放的控制层和模型
    //控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
    func playerControlView(frame: CGRect, playerModel: DLMPlayerModel) {
        //指定默认控制层
        let defaultControlView = DLMPlayerControlView(frame: frame)
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
}

//MARK: - 代理方法
protocol DLMPlayerViewDelegate {
    
}
