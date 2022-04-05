//
//  RangeBarChartDataSetProtocol.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import Foundation
import CoreGraphics

@objc
public protocol RangeBarChartDataSetProtocol: LineScatterCandleRadarChartDataSetProtocol
{
    
    /// the width of the bar in pixels.
    ///
    /// **default**: 1.5
    var barWidth: CGFloat { get set }
    
    /// the color of the bar
    var barColor: NSUIColor { get set }

}
