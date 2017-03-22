//
//  ViewController.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController {
    lazy var playerModel : DLMPlayerModel = {
        let playerM  = DLMPlayerModel()
        playerM.title = "这里设置视频标题"
        playerM.videoURL = NSURL(string: "")
        playerM.placeholderImage = UIImage(named: "")
        playerM.fatherView = self.view
        return playerM
    }()
    
    lazy var playerView : DLMPlayerView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let playerV = DLMPlayerView(frame: frame)
        playerV.playerControlView(controlView: nil, playerModel: self.playerModel)
        return playerV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载视频播放器
        self.playerView.autoPlayTheVideo()
    }
}

