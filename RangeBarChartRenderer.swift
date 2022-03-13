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
    
    open override func drawData(context: CGContext)
    {
        guard let dataProvider = dataProvider, let rangeBarData = dataProvider.rangeBarData else { return }

        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()

        // Make the chart header the first element in the accessible elements array
        if let chart = dataProvider as? RangeBarChartView {
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: rangeBarData,
                                                 withDefaultDescription: "CandleStick Chart")
            accessibleChartElements.append(element)
        }

        for case let set as RangeBarChartDataSetProtocol in rangeBarData where set.isVisible
        {
            drawDataSet(context: context, dataSet: set)
        }
    }
    
    private var _rangePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: RangeBarChartDataSetProtocol)
    {
        guard
            let dataProvider = dataProvider
            else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        let barColor = dataSet.barColor.cgColor
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        
        context.setLineWidth(dataSet.barWidth)

        for j in _xBounds
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? RangeBarChartDataEntry else { continue }
            
            let xPos = e.x
             
            let high = e.high
            let low = e.low
            
            let doesContainMultipleDataSets = (dataProvider.rangeBarData?.count ?? 1) > 1

            var accessibilityRect = CGRect(x: CGFloat(xPos) + 0.5 - barSpace,
                                           y: CGFloat(low * phaseY),
                                           width: (2 * barSpace) - 1.0,
                                           height: (CGFloat(abs(high - low) * phaseY)))
            trans.rectValueToPixel(&accessibilityRect)


            _rangePoints[0].x = CGFloat(xPos)
            _rangePoints[0].y = CGFloat(high * phaseY)
            _rangePoints[1].x = CGFloat(xPos)
            _rangePoints[1].y = CGFloat(low * phaseY)

                
            trans.pointValuesToPixel(&_rangePoints)
            context.setLineCap(.round)
            context.setStrokeColor(barColor)
            context.setFillColor(barColor)
            context.strokeLineSegments(between: _rangePoints)
            
           
            let axElement = createAccessibleElement(withIndex: j,
                                                    container: dataProvider,
                                                    dataSet: dataSet)
            { (element) in
                element.accessibilityLabel = "\(doesContainMultipleDataSets ? "\(dataSet.label ?? "Dataset")" : "") " + "low: \(low), high: \(high)"
                element.accessibilityFrame = accessibilityRect
            }

            accessibleChartElements.append(axElement)

        }

        // Post this notification to let VoiceOver account for the redrawn frames
        accessibilityPostLayoutChangedNotification()

        context.restoreGState()
    }
    
    open override func drawValues(context: CGContext)
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
                guard let
                    dataSet = rangeBarData[i] as? BarLineScatterCandleBubbleChartDataSetProtocol,
                    shouldDrawValues(forDataSet: dataSet)
                    else { continue }
                
                let valueFont = dataSet.valueFont
                
                let formatter = dataSet.valueFormatter
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                let angleRadians = dataSet.valueLabelAngle.DEG2RAD
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                let lineHeight = valueFont.lineHeight
                let yOffset: CGFloat = lineHeight + 5.0
                
                for j in _xBounds
                {
                    guard let e = dataSet.entryForIndex(j) as? RangeBarChartDataEntry else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.high * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    if dataSet.isDrawValuesEnabled
                    {
                        context.drawText(formatter.stringForValue(e.high,
                                                                  entry: e,
                                                                  dataSetIndex: i,
                                                                  viewPortHandler: viewPortHandler),
                                         at: CGPoint(x: pt.x,
                                                     y: pt.y - yOffset),
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
    
    open override func drawExtras(context: CGContext)
    {
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let rangeBarData = dataProvider.rangeBarData
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            guard
                let set = rangeBarData[high.dataSetIndex] as? RangeBarChartDataSetProtocol,
                set.isHighlightEnabled
                else { continue }
            
            guard let e = set.entryForXValue(high.x, closestToY: high.y) as? RangeBarChartDataEntry else { continue }
            
            if !isInBoundsX(entry: e, dataSet: set)
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
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
            
            let lowValue = e.low * Double(animator.phaseY)
            let highValue = e.high * Double(animator.phaseY)
            let y = (lowValue + highValue) / 2.0
            
            let pt = trans.pixelForValues(x: e.x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        context.restoreGState()
    }

    private func createAccessibleElement(withIndex idx: Int,
                                         container: RangeBarChartDataProvider,
                                         dataSet:  RangeBarChartDataSetProtocol,
                                         modifier: (NSUIAccessibilityElement) -> ()) -> NSUIAccessibilityElement {

        let element = NSUIAccessibilityElement(accessibilityContainer: container)

        // The modifier allows changing of traits and frame depending on highlight, rotation, etc
        modifier(element)

        return element
    }
}
