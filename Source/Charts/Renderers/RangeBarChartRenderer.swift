//
//  RangeBarChartRenderer.swift
//  Charts
//
//  Created by race on 2022/3/13.
//

import CoreGraphics
import Foundation

open class RangeBarChartRenderer: LineScatterCandleRadarRenderer
{
    @objc open weak var dataProvider: RangeBarChartDataProvider?
    
    @objc public init(dataProvider: RangeBarChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }

    private var _barRect = CGRect()
    
    override open func drawData(context: CGContext)
    {
        guard let rangeBarData = dataProvider?.rangeBarData else { return }

        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()
        
        if let chart = dataProvider as? RangeBarChartView
        {
            // Make the chart header the first element in the accessible elements array
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: rangeBarData,
                                                 withDefaultDescription: "RangeBar Chart")
            accessibleChartElements.append(element)
        }

        // TODO: Due to the potential complexity of data presented in Scatter charts, a more usable way
        // for VO accessibility would be to use axis based traversal rather than by dataset.
        // Hence, accessibleChartElements is not populated below. (Individual renderers guard against dataSource being their respective views)
        let sets = rangeBarData.dataSets as? [RangeBarChartDataSet]
        assert(sets != nil, "Datasets for RangeBarChartRenderer must conform to IScatterChartDataSet")
        
        let drawDataSet = { self.drawDataSet(context: context, dataSet: $0) }
        sets!.lazy
            .filter(\.isVisible)
            .forEach(drawDataSet)
    }
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: RangeBarChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barWidth = dataSet.barWidth
        let barColor = dataSet.barColor
        
        let entryCount = dataSet.entryCount
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        context.saveGState()
            
        for j in 0 ..< Int(min(ceil(Double(entryCount) * animator.phaseX), Double(entryCount)))
        {
            guard let e = dataSet.entryForIndex(j) as? RangeBarChartDataEntry
            else { continue }
                
            point.x = CGFloat(e.x)
            point.y = CGFloat(e.y * phaseY)
            point = point.applying(valueToPixelMatrix)
            

            _barRect.origin.x = CGFloat(e.x)
            _barRect.origin.y = CGFloat(e.high * phaseY)
            _barRect.size.width = barWidth
            _barRect.size.height = CGFloat(abs(e.high - e.low) * phaseY)
            trans.rectValueToPixel(&_barRect)
                
            if !viewPortHandler.isInBoundsRight(point.x)
            {
                break
            }
                
            if !viewPortHandler.isInBoundsLeft(point.x) ||
                !viewPortHandler.isInBoundsY(point.y)
            {
                continue
            }
                
            //            trans.pointValuesToPixel(&_rangePoints)
            //            context.strokeLineSegments(between: _rangePoints)
            
            let colors = e.colors.count > 0 ? e.colors : [barColor, barColor]
            context.drawLinearGradient(in: _barRect, colors: colors)
        }
            
        context.restoreGState()
    }
    
    override open func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let rangeBarData = dataProvider.rangeBarData
        else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in rangeBarData.indices
            {
                guard let dataSet = rangeBarData[i] as? RangeBarChartDataSetProtocol,
                      shouldDrawValues(forDataSet: dataSet)
                else { continue }
                
                let valueFont = dataSet.valueFont
                
                let formatter = dataSet.valueFormatter
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                let angleRadians = dataSet.valueLabelAngle.DEG2RAD
                
                let shapeSize = dataSet.barWidth
                let lineHeight = valueFont.lineHeight
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in _xBounds
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if !viewPortHandler.isInBoundsRight(pt.x)
                    {
                        break
                    }
                    
                    // make sure the lines don't do shitty things outside bounds
                    if !viewPortHandler.isInBoundsLeft(pt.x)
                        || !viewPortHandler.isInBoundsY(pt.y)
                    {
                        continue
                    }
                    
                    let text = formatter.stringForValue(
                        e.y,
                        entry: e,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler
                    )
                    
                    if dataSet.isDrawValuesEnabled
                    {
                        context.drawText(text,
                                         at: CGPoint(x: pt.x,
                                                     y: pt.y - shapeSize - lineHeight),
                                         align: .center,
                                         angleRadians: angleRadians,
                                         attributes: [.font: valueFont,
                                                      .foregroundColor: dataSet.valueTextColorAt(j)])
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        context.drawImage(icon,
                                          atCenter: CGPoint(x: pt.x + iconsOffset.x,
                                                            y: pt.y + iconsOffset.y),
                                          size: icon.size)
                    }
                }
            }
        }
    }
    
    override open func drawExtras(context: CGContext)
    {}
    
    override open func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let scatterData = dataProvider.rangeBarData
        else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = scatterData[high.dataSetIndex] as? ScatterChartDataSetProtocol,
                set.isHighlightEnabled
            else { continue }
            
            guard let entry = set.entryForXValue(high.x, closestToY: high.y) else { continue }
            
            if !isInBoundsX(entry: entry, dataSet: set) { continue }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let x = entry.x // get the x-position
            let y = entry.y * Double(animator.phaseY)
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            let pt = trans.pixelForValues(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        context.restoreGState()
    }
}

extension CGContext
{
    func drawLinearGradient(in rect: CGRect, colors: [NSUIColor], roundCorner: Bool = true)
    {
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let locations: [CGFloat] = [0.0, 1.0]

        let colors = colors.map { $0.cgColor } as CFArray

        guard let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors,
            locations: locations
        ) else { return }
        
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)
            
        saveGState()
        
        let cornerRadius = roundCorner ? rect.size.width / 2 : 0
        let path = NSUIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        addPath(path.cgPath)
        clip()
        
        drawLinearGradient(
            gradient,
            start: startPoint,
            end: endPoint,
            options: CGGradientDrawingOptions()
        )

        restoreGState()
    }
}
