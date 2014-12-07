//
//  ViewController.swift
//  AppleStock
//
//  Created by Andrew James on 12/6/14.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

import Cocoa

class StockViewController: NSViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.wantsLayer = true
        representedObject = StockDataProvider.getStockData()
//        var shapeLayer = CAShapeLayer()
//        shapeLayer.frame = view.bounds
//        shapeLayer.strokeColor = NSColor.redColor().CGColor
//        var path = NSBezierPath()
//        path.moveToPoint(NSPoint(x: NSMinX(view.bounds), y: NSMinY(view.bounds)))
//        path.lineToPoint(NSPoint(x: NSMaxX(view.bounds), y: NSMaxY(view.bounds)))
//        shapeLayer.path = path.CGPath
//
//        var animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = 0.0
//        animation.toValue = 1.0
//        animation.duration = 3.0
//        shapeLayer.addAnimation(animation, forKey: "stroke")
//        self.view.layer!.addSublayer(shapeLayer)
    }

    override var representedObject: AnyObject?
    {
        didSet
        {
            if let theView = view as? StockChartView
            {
                theView.stockData = representedObject as? [NSDate:Double]
                theView.needsDisplay = true
            }
        }
    }

}

