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
    
    @IBOutlet weak var playerFatherView: UIView!
    
    lazy var playerModel : DLMPlayerModel = {
        let playerM  = DLMPlayerModel()
        playerM.title = "这里设置视频标题"
        playerM.videoURL = NSURL(string: "http://baobab.wdjcdn.com/1456231710844S(24).mp4")
        playerM.placeholderImage = UIImage(named: "1.png")
        playerM.fatherView = self.playerFatherView
        return playerM
    }()
    
    lazy var playerView : DLMPlayerView = {
        let frame = self.playerFatherView.frame
        let playerV = DLMPlayerView(frame: frame)
        playerV.playerControlView(frame: frame, playerModel: self.playerModel)
        return playerV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        
        //加载视频播放器
        self.playerView.autoPlayTheVideo()
    }
}

