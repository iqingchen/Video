//
//  Common.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

let kScreenWidth : CGFloat = UIScreen.main.bounds.size.width
let kScreenHeight : CGFloat = UIScreen.main.bounds.size.height

let DLMPlayerOrientationIsLandscape = UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
let DLMPlayerOrientationIsPortrait = UIDeviceOrientationIsPortrait(UIDevice.current.orientation)

func RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)-> UIColor {
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

