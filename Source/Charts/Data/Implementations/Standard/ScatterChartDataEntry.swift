//
//  ScatterChartDataEntry.swift
//  Charts
//
//  Created by race on 2022/3/14.
//

import Foundation
import CoreGraphics

open class ScatterChartDataEntry: ChartDataEntry
{
    /// color value
    @objc open var color: NSUIColor?
    
    public required init()
    {
        super.init()
    }
    
    @objc public init(x: Double, y: Double, color: NSUIColor? = nil)
    {
        super.init(x: x, y: y)
        
        self.color = color
    }

    @objc public convenience init(x: Double, y: Double, color: NSUIColor? = nil, icon: NSUIImage?)
    {
        self.init(x: x, y: y)
        self.color = color
        self.icon = icon
    }

    @objc public convenience init(x: Double, y: Double, color: NSUIColor? = nil, data: Any?)
    {
        self.init(x: x, y: y)
        self.color = color
        self.data = data
    }

    @objc public convenience init(x: Double, y: Double, color: NSUIColor? = nil, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, y: y)
        self.color = color
        self.icon = icon
        self.data = data
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! ScatterChartDataEntry
        copy.color = color
        return copy
    }
}

