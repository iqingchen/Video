//
//  DLMPlayerControlView+Delegate.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/21.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

extension DLMPlayerControlView {
    
    
    
}

protocol DLMPlayerControlViewDelegate {
    func dlm_playerDownloadBtnState(state: Bool)
    /**
     * 正常播放
     
     * @param currentTime 当前播放时长
     * @param totalTime   视频总时长
     * @param value       slider的value(0.0~1.0)
     */
    func dlm_playerCurrentTime(currentTime: Int, totalTime: Int, sliderValue: CGFloat)
}
