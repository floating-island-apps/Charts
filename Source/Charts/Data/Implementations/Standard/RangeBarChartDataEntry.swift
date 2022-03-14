//
//  RangeBarChartDataEntry.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import Foundation

open class RangeBarChartDataEntry: ChartDataEntry
{
    /// range-high value
    @objc open var high = Double(0.0)
    
    /// range-low value
    @objc open var low = Double(0.0)
    
    /// gradient color value
    @objc open var colors = [UIColor]()
    
    public required init()
    {
        super.init()
    }
    
    @objc public init(x: Double, high: Double, low: Double, colors: [NSUIColor] = [])
    {
        super.init(x: x, y: (high + low) / 2.0)
        self.high = high
        self.low = low
        self.colors = colors
    }

    @objc public convenience init(x: Double, high: Double, low: Double, icon: NSUIImage?)
    {
        self.init(x: x, high: high, low: low)
        self.icon = icon
    }

    @objc public convenience init(x: Double, high: Double, low: Double, data: Any?)
    {
        self.init(x: x, high: high, low: low)
        self.data = data
    }

    @objc public convenience init(x: Double, high: Double, low: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, high: high, low: low)
        self.icon = icon
        self.data = data
    }
    
    /// The overall range (difference) between range-high and range-low.
    @objc open var range: Double
    {
        return abs(high - low)
    }
    
    /// the center value of the candle. (Middle value between high and low)
    open override var y: Double
    {
        get
        {
            return super.y
        }
        set
        {
            super.y = (high + low) / 2.0
        }
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! RangeBarChartDataEntry
        copy.high = high
        copy.low = low
        return copy
    }
}
