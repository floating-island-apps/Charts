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
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    var barSpace: CGFloat { get set }
    
    
    /// the width of the bar in pixels.
    ///
    /// **default**: 1.5
    var barWidth: CGFloat { get set }
    
    /// the color of the bar
    var barColor: UIColor { get set }

}
