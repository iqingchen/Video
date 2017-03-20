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

enum DLMPlayerLayerGravity {
    case Resize         // 非均匀模式。两个维度完全填充至整个视图区域
    case Aspect         // 等比例填充，直到一个维度到达区域边界
    case AspectFill     // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
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
    var playerLayerGravity : DLMPlayerLayerGravity!
    /** 是否有下载功能(默认是关闭) */
    var hasDownload : Bool!
    /** 是否开启预览图 */
    var hasPreviewView : Bool!
    /** 设置代理 */
    var delegate : DLMPlayerViewDelegate?
    /** 是否被用户暂停 */
    var isPauseByUser : Bool!
    /** 播发器的几种状态 */
    var state : DLMPlayerState!
    /** 静音（默认为NO）*/
    var mute : Bool!
    /** 当cell划出屏幕的时候停止播放（默认为NO） */
    var stopPlayWhileCellNotVisable : Bool?
    /** 当cell播放视频由全屏变为小屏时候，是否回到中间位置(默认YES) */
    var cellPlayerOnCenter : Bool?
    
    //MARK: - 私有属性
    /** 播放属性 */
    var player : AVPlayer!
    var playerItem : AVPlayerItem!
    var urlAsset : AVURLAsset!
    var imageGenerator : AVAssetImageGenerator!
    /** playerLayer */
    var playerLayer : AVPlayerLayer!
    var timeObserve : AnyObject?
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
    var brightnessView : DLMBrightnessView!
    /** 视频填充模式 */
    var videoGravity : String!
    
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
//    @property (nonatomic, assign) BOOL                   isBottomVideo;
//    /** 是否切换分辨率*/
//    @property (nonatomic, assign) BOOL                   isChangeResolution;
//    /** 是否正在拖拽 */
//    @property (nonatomic, assign) BOOL                   isDragged;
//
//    @property (nonatomic, strong) UIView                 *controlView;
//    @property (nonatomic, strong) ZFPlayerModel          *playerModel;
//    @property (nonatomic, assign) NSInteger              seekTime;
//    @property (nonatomic, strong) NSURL                  *videoURL;
//    @property (nonatomic, strong) NSDictionary           *resolutionDic;
    
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
    func initializeThePlayer() {
        cellPlayerOnCenter = true
    }
}

//MARK: - 暴露给外界的方法
extension DLMPlayerView {
//    func <#name#>(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
    
    
    
//    - (void)playerControlView:(UIView *)controlView playerModel:(ZFPlayerModel *)playerModel {
//    if (!controlView) {
//    // 指定默认控制层
//    ZFPlayerControlView *defaultControlView = [[ZFPlayerControlView alloc] init];
//    self.controlView = defaultControlView;
//    } else {
//    self.controlView = controlView;
//    }
//    self.playerModel = playerModel;
//    }
}

//MARK: - 代理方法
protocol DLMPlayerViewDelegate {
    
}
