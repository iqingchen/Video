//
//  ASValueTrackingSlider.swift
//  VideoTest2
//
//  Created by zhang on 2017/3/20.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

class ASValueTrackingSlider: UISlider {
    var numberFormatter : NumberFormatter!
    var popUpViewColor : UIColor!
    var keyTimes : [String] = []
    var valueRange : CGFloat!

    var popUpViewCornerRadius : CGFloat!
    var popUpViewArrowLength : CGFloat!
}
