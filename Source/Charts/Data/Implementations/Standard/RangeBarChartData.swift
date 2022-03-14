//
//  RangeBarChartData.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import Foundation

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
    
    /// - Returns: The maximum shape-size across all DataSets.
    @objc open func getGreatestShapeSize() -> CGFloat
    {
        return (_dataSets as? [ScatterChartDataSetProtocol])?
            .max { $0.scatterShapeSize < $1.scatterShapeSize }?
            .scatterShapeSize ?? 0
    }
}
