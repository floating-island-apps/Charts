//
//  RangeBarChartDataSet.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import Foundation
import CoreGraphics
import UIKit


open class RangeBarChartDataSet: LineScatterCandleRadarChartDataSet, RangeBarChartDataSetProtocol
{
    
    public required init()
    {
        super.init()
    }
    
    public override init(entries: [ChartDataEntry], label: String)
    {
        super.init(entries: entries, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    open override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? RangeBarChartDataEntry
            else { return }

        _yMin = Swift.min(e.low, _yMin)
        _yMax = Swift.max(e.high, _yMax)

        calcMinMaxX(entry: e)
    }
    
    open override func calcMinMaxY(entry e: ChartDataEntry)
    {
        guard let e = e as? RangeBarChartDataEntry
            else { return }

        _yMin = Swift.min(e.low, _yMin)
        _yMax = Swift.max(e.high, _yMin)

        _yMin = Swift.min(e.low, _yMax)
        _yMax = Swift.max(e.high, _yMax)
    }
    
    // MARK: - Styling functions and accessors
    
    /// the space between the candle entries
    ///
    /// **default**: 0.1 (10%)
    private var _barSpace: CGFloat = 0.1

    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    open var barSpace: CGFloat
    {
        get
        {
            return _barSpace
        }
        set
        {
            _barSpace = newValue.clamped(to: 0...0.45)
        }
    }
    
    
    /// the width of the bar in pixels.
    ///
    /// **default**: 1.5
    open var barWidth = CGFloat(1.5)
    
    /// the color of the bar
    open var barColor: NSUIColor = .red
    
}

