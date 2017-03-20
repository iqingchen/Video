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

    lazy var playerView : DLMPlayerView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let playerV = DLMPlayerView(frame: frame)
        return playerV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载视频播放器
        
    }
}

