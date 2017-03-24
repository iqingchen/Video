//
//  DLMPlayerControlView+Delegate.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/21.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

//原来View的代理方法
extension DLMPlayerControlView {
    /**
     * 正常播放
     
     * @param currentTime 当前播放时长
     * @param totalTime   视频总时长
     * @param value       slider的value(0.0~1.0)
     */
    func dlm_playerCurrentTime(currentTime: Int, totalTime: Int, value: Float) {
        // 当前时长进度progress
        let proMin = currentTime / 60 //当前秒
        let proSec = currentTime % 60 //当前分钟
         // duration 总时长
        let durMin = totalTime / 60 //总秒
        let durSec = totalTime % 60 //总分钟
        if !self.dragged {
            // 更新slider
            self.videoSlider.value = value
            self.bottomProgressView.progress = value
            // 更新当前播放时间
            let proMins = String(format: "%02zd", proMin)
            let proSecs = String(format: "%02zd", proSec)
            self.currentTimeLabel.text = "\(proMins):\(proSecs)"
        }
        // 更新总时间
        let durMins = String(format: "%02zd", durMin)
        let durSecs = String(format: "%02zd", durSec)
        self.totalTimeLabel.text = "\(durMins):\(durSecs)"
    }
    /**
     * 拖拽快进 快退
     
     * @param draggedTime 拖拽的时长
     * @param totalTime   视频总时长
     * @param forawrd     是否是快进
     * @param preview     是否有预览图
     */
    func dlm_playerDraggedTime(draggedTime: Float, totalTime: Float, forawrd: Bool, preview: Bool) {
        // 快进快退时候停止菊花
        self.activity.stopAnimating()
        // 拖拽的时长
        let proMin = draggedTime / 60 //当前秒
        let proSec = Int(draggedTime) % 60 //当前分钟
        // duration 总时长
        let durMin = totalTime / 60 //总秒
        let durSec = Int(totalTime) % 60 //总分钟
        
        let proMins = String(format: "%02zd", proMin)
        let proSecs = String(format: "%02zd", proSec)
        let currentTimeStr = "\(proMins):\(proSecs)"
        let durMins = String(format: "%02zd", durMin)
        let durSecs = String(format: "%02zd", durSec)
        let totalTimeStr = "\(durMins):\(durSecs)"
        let draggedValue = draggedTime / totalTime
        let timeStr = "\(currentTimeStr) / \(totalTimeStr)"
        
        // 显示、隐藏预览窗
//        self.videoSlider.popUpView.hidden = !preview;
        // 更新slider的值
        self.videoSlider.value            = draggedValue
        // 更新bottomProgressView的值
        self.bottomProgressView.progress  = draggedValue
        // 更新当前时间
        self.currentTimeLabel.text        = currentTimeStr
        // 正在拖动控制播放进度
        self.dragged = true
        if forawrd {
            fastImageView.image = UIImage(named: "ZFPlayer_fast_forward")
        }else {
            fastImageView.image = UIImage(named: "ZFPlayer_fast_backward")
        }
        
        self.fastView.isHidden         = preview
        self.fastTimeLabel.text        = timeStr
        self.fastProgressView.progress = draggedValue
    }
    /**
     * 滑动调整进度结束结束
     */
    func dlm_playerDraggedEnd() {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 1.0 )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { 
            self.fastView.isHidden = true
        }
        self.dragged = false
        // 结束滑动时候把开始播放按钮改为播放状态
        self.startBtn.isSelected = true
        // 滑动结束延时隐藏controlView
        self.autoFadeOutControlView()
    }
    /** 重置ControlView */
    func dlm_playerResetControlView() {
        activity.stopAnimating()
        
        //        self.videoSlider.value           = 0
        self.bottomProgressView.progress = 0
        self.progressView.progress       = 0
        self.currentTimeLabel.text       = "00:00"
        self.totalTimeLabel.text         = "00:00"
        self.fastView.isHidden             = true
        self.repeatBtn.isHidden            = true
        self.playeBtn.isHidden             = true
        //        self.resolutionView.isHidden       = true
        self.failBtn.isHidden              = true
        self.backgroundColor             = UIColor.clear
        self.downLoadBtn.isEnabled         = true
        self.isShrink                      = false
        self.isShowing                     = false
        self.playeEnd                    = false
        //        self.lockBtn.isHidden              = !self.isFullScreen;
        self.failBtn.isHidden              = true
        self.placeholderImageView.alpha  = 1;
    }

}

protocol DLMPlayerControlViewDelegate {
    //需要移除
//    func dlm_playerDownloadBtnState(state: Bool)
    /**  返回按钮事件 */
    func dlm_controlViewBackAction(controlView: DLMPlayerControlView, btn: UIButton)
    /**  cell播放中小屏状态 关闭按钮事件 */
    func dlm_controlViewCloseAction(controlView: DLMPlayerControlView, btn: UIButton)
    /** 播放按钮事件 */
    func dlm_controlViewPlayAction(controlView: DLMPlayerControlView, btn: UIButton)
    /** 全屏按钮事件 */
    func dlm_controlViewFullScreenAction(controlView: DLMPlayerControlView, btn: UIButton)
    /** 锁定屏幕方向按钮时间 */
    func dlm_controlViewLockScreenAction(controlView: DLMPlayerControlView, btn: UIButton)
    /** 重播按钮事件 */
    func dlm_controlViewRepeatPlayAction(controlView: DLMPlayerControlView, btn: UIButton)
    /** 中间播放按钮事件 */
    func dlm_controlViewCenterPlayAction(controlView: DLMPlayerControlView, btn: UIButton)
    /** 加载失败按钮事件 */
    func dlm_controlViewFailAction(controlView: DLMPlayerControlView, btn: UIButton)

    /** slider的点击事件（点击slider控制进度） */
    func dlm_controlViewProgressSliderTap(controlView: DLMPlayerControlView, value: CGFloat)
    /** 开始触摸slider */
    func dlm_controlViewProgressSliderTouchBegan(controlView: DLMPlayerControlView, slider: UISlider)
    /** slider触摸中 */
    func dlm_controlViewProgressSliderValueChanged(controlView: DLMPlayerControlView, slider: UISlider)
    /** slider触摸结束 */
    func dlm_controlViewProgressSliderTouchEnded(controlView: DLMPlayerControlView, slider: UISlider)
}
