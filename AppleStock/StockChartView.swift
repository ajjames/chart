//
//  StockChartView.swift
//  AppleStock
//
//  Created by Andrew James on 12/6/14.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

import Cocoa

class StockChartView: NSView
{
    var stockData: [NSDate:Double]?
    //settings
    private let kChartTopPadding: CGFloat = 0.1 //% of plottable space
    private let kXIndent: CGFloat = 0.1 //% of plot space
    private let kBackgroundGradientStartingColor = NSColor(calibratedRed: 0.20, green: 0.20, blue: 0.25, alpha: 1.0)
    private let kBackgroundGradientEndingColor = NSColor(calibratedRed: 0.37, green: 0.42, blue: 0.49, alpha: 1.0)
    private let kFrameColor = NSColor.grayColor()
    private let kAxisColor = NSColor.whiteColor()
    private let kGridColor = NSColor.grayColor()
    private let kLineColor = NSColor.whiteColor()
    private let kPointColor = NSColor.whiteColor()
    private let kBackgroundGradientAngle:CGFloat = 270.0
    private let kChartPaddingX:CGFloat = 20.0
    private let kChartPaddingY:CGFloat = 10.0
    private let kPlotPaddingX:CGFloat = 60.0
    private let kPlotPaddingY:CGFloat = 40.0
    private let xAxisLabelPosition:CGFloat = 18.0
    private let yAxisLabelPosition:CGFloat = 26.0
    private let kAnimationDuration:CFTimeInterval = 1.0
    //ivars
    private var sortedDates:[NSDate]!
    private var sortedPrices = [Double]()
    private var priceLabels = [Double]()
    private var gridLabelXs:[CGFloat]!
    private var gridLabelYs:[CGFloat]!
    private var plotAreaRect:CGRect!
    private var dataPoints:[CGPoint]!
    private var plottableHeight:CGFloat!
    private var chartLayer:CAShapeLayer!
    private var labels = [CATextLayer]()

    override func viewDidMoveToSuperview()
    {
        wantsLayer = true
        if let data = stockData
        {
            sortedDates = Array(data.keys).sorted({ (date1:NSDate, date2:NSDate) -> Bool in
                return date1.compare(date2) == NSComparisonResult.OrderedAscending
            })

            for date in sortedDates
            {
                sortedPrices.append(data[date]!)
            }
        }
    }

    override func viewDidEndLiveResize()
    {
        needsDisplay = true
    }

    override func viewWillStartLiveResize()
    {
        if chartLayer != nil
        {
            chartLayer.removeFromSuperlayer()
            for label in labels
            {
                label.removeFromSuperlayer()
            }
            labels = [CATextLayer]()
        }
    }

    override func drawRect(dirtyRect: NSRect)
    {
        super.drawRect(dirtyRect)
        gridLabelXs = [CGFloat]()
        gridLabelYs = [CGFloat]()
        priceLabels = [Double]()
        plotAreaRect = CGRectZero
        dataPoints = [CGPoint]()
        drawChartWithGrid()
        if !inLiveResize
        {
            animateData()
        }
    }

    private func drawChartWithGrid()
    {
        //draw background gradient
        var gradient = NSGradient(startingColor: kBackgroundGradientStartingColor, endingColor: kBackgroundGradientEndingColor)
        let backgroundPath = NSBezierPath(rect:bounds)
        gradient.drawInBezierPath(backgroundPath, angle: kBackgroundGradientAngle)

        //draw chart frame
        kFrameColor.set()
        let chartFramePath = NSBezierPath(rect: bounds.rectByInsetting(dx: kChartPaddingX, dy: kChartPaddingY))
        chartFramePath.stroke()

        //set plot area frame
        plotAreaRect = bounds.rectByInsetting(dx: kPlotPaddingX, dy: kPlotPaddingY)
        kAxisColor.set()

        //draw chart x-axis
        let xAxis = NSBezierPath()
        let x0 = NSMinX(plotAreaRect)
        let x1 = NSMaxX(plotAreaRect)
        let y0 = NSMinY(plotAreaRect)
        xAxis.moveToPoint(CGPoint(x:x0, y:y0))
        xAxis.lineToPoint(CGPoint(x:x1, y:y0))
        xAxis.stroke()

        //draw chart y-axis
        let yAxis = NSBezierPath()
        yAxis.moveToPoint(CGPoint(x: x0, y: y0))
        yAxis.lineToPoint(CGPoint(x: x0, y: NSMaxY(plotAreaRect)))
        yAxis.stroke()

        //draw horizontal grid data lines
        kGridColor.set()
        plottableHeight = plotAreaRect.size.height - (plotAreaRect.size.height * kChartTopPadding)
        let quarterSpace = plottableHeight / 4.0
        for index in 1...4
        {
            let hLineY = y0 + quarterSpace * CGFloat(index)
            gridLabelYs.append(hLineY)
            let hLine25 = NSBezierPath()
            hLine25.lineWidth = 1.0
            hLine25.moveToPoint(CGPoint(x:x0, y:hLineY))
            hLine25.lineToPoint(CGPoint(x:x1, y:hLineY))
            hLine25.stroke()
        }
    }

    private func animateData()
    {
        calculatePoints()
        drawPoints()
        drawLabels()
    }

    private func calculatePoints()
    {
        if let data = stockData
        {
            let priceValues = data.values.array
            let maxPrice = maxElement(priceValues)
            let minPrice = minElement(priceValues)
            let minValueY = CGFloat(minPrice)
            let maxValueY = CGFloat(maxPrice)
            let yRange = maxValueY - minValueY

            //calculate price labels
            priceLabels.append(minPrice)
            priceLabels.append(minPrice + Double(yRange * 0.333))
            priceLabels.append(minPrice + Double(yRange * 0.666))
            priceLabels.append(maxPrice)

            let count = data.count
            let xSpacing = NSMaxX(plotAreaRect) / CGFloat(count)
            var startingX = xSpacing * kXIndent
            for price in sortedPrices
            {
                //convert value to a point on the y axis
                let valueDelta = CGFloat(price) - minValueY
                let plotY = ((valueDelta * (plottableHeight * 0.75)) / yRange) + (plottableHeight / 4.0)
                dataPoints.append(CGPoint(x: startingX, y: plotY))
                gridLabelXs.append(startingX)
                startingX += xSpacing
            }
        }
    }

    private func drawPoints()
    {
        if chartLayer != nil
        {
            chartLayer.removeFromSuperlayer()
        }
        chartLayer = CAShapeLayer()
        chartLayer.frame = plotAreaRect
        chartLayer.strokeColor = kLineColor.CGColor
        let zeroPath = NSBezierPath()
        zeroPath.moveToPoint(dataPoints.first!)
        var path = NSBezierPath()
        var previousPoint:CGPoint!
        var finalPoint:CGPoint!
        var lineLength:CGFloat = 0.0
        var fullStrokeLength:CGFloat = 0.0
        for index in 0..<dataPoints.count
        {
            let currentPoint = dataPoints[index]
            if index == 0
            {
                path.moveToPoint(currentPoint)
            }
            else
            {
                path.lineToPoint(currentPoint)
            }
            if previousPoint != nil
            {
                fullStrokeLength += currentPoint.distanceFrom(previousPoint)
                if currentPoint == dataPoints.last
                {
                    lineLength = fullStrokeLength
                    fullStrokeLength += dataPoints.last!.distanceFrom(dataPoints.first!)
                }
            }
            previousPoint = currentPoint
        }
        chartLayer.lineCap = kCALineCapRound
        chartLayer.fillColor = NSColor.clearColor().CGColor
        chartLayer.path = path.CGPath
        chartLayer.strokeEnd = lineLength / fullStrokeLength

        var animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = kAnimationDuration
        animation.fromValue = 0.0
        animation.toValue = chartLayer.strokeEnd
        chartLayer.addAnimation(animation, forKey: nil)
        self.layer?.addSublayer(chartLayer)
    }

    private func drawLabels()
    {
        var yLabelLayer = CATextLayer()

        let minX = NSMinX(plotAreaRect)
        for index in 0..<sortedDates.count
        {
            let date = sortedDates[index]
            let x = gridLabelXs[index] + minX
            let y = xAxisLabelPosition
            var formatter = NSDateFormatter()
            formatter.dateFormat = "M/d"
            drawLabel(formatter.stringFromDate(date), point: CGPoint(x:x,y:y), isXAxis:false)
        }

        for index in 0..<priceLabels.count
        {
            let x = yAxisLabelPosition
            let y = gridLabelYs[index] - 6.0
            var label = NSString(format: "$%.0f", priceLabels[index])
            drawLabel(label, point: CGPoint(x:x,y:y), isXAxis:true)
        }
    }

    private func drawLabel(text:String, point:CGPoint, isXAxis:Bool)
    {
        var textLayer = CATextLayer(layer: layer)
        textLayer.string = text
        textLayer.anchorPoint = isXAxis ? CGPoint(x: 0.5, y: 0.5) : CGPoint(x: 1.0, y: 1.0)
        textLayer.frame.origin = point
        textLayer.fontSize = 12.0
        textLayer.frame.size = CGSize(width: 30.0, height: 15.0)
        textLayer.alignmentMode = kCAAlignmentCenter

        var animation = CABasicAnimation(keyPath: (isXAxis) ? "position.x" : "position.y")
        animation.duration = kAnimationDuration
        animation.fromValue = -20.0
        animation.toValue = isXAxis ? point.x : point.y
        textLayer.addAnimation(animation, forKey: nil)
        self.layer?.addSublayer(textLayer)

        labels.append(textLayer)
    }
    
}
