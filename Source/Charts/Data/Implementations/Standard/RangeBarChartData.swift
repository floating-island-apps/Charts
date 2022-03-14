//
//  RangeBarChartData.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import Foundation
import CoreGraphics

open class RangeBarChartData: BarLineScatterCandleBubbleChartData
{
    public required init()
    {
        super.init()
    }
    
    public override init(dataSets: [ChartDataSetProtocol])
    {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSetProtocol...)
    {
        super.init(dataSets: elements)
    }
}
