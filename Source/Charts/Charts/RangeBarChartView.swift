//
//  RangeBarChartView.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import Foundation
import CoreGraphics

/// Fitness chart type that draws ranges.
open class RangeBarChartView: BarLineChartViewBase, RangeBarChartDataProvider
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = RangeBarChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        
        self.xAxis.spaceMin = 0.5
        self.xAxis.spaceMax = 0.5
    }
    
    // MARK: - RangeBarChartDataProvider
    
    open var rangeBarData: RangeBarChartData?
    {
        return data as? RangeBarChartData
    }
}
