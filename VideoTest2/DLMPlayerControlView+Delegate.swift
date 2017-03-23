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
            self.currentTimeLabel.text = "\(proMin):\(proSec)"
        }
        // 更新总时间
        self.totalTimeLabel.text = "\(durMin):\(durSec)"
    }
    /**
     * 拖拽快进 快退
     
     * @param draggedTime 拖拽的时长
     * @param totalTime   视频总时长
     * @param forawrd     是否是快进
     * @param preview     是否有预览图
     */
    func dlm_playerDraggedTime(draggedTime: Int, totalTime: Int, forawrd: Bool, preview: Bool) {
        
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
