//
//  RangeBarChartDataProvider.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import Foundation
import CoreGraphics

@objc
public protocol RangeBarChartDataProvider: BarLineScatterCandleBubbleChartDataProvider
{
    var rangeBarData: RangeBarChartData? { get }
}
