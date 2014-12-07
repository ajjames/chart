//
//  NSBezierPathExtension.swift
//  AppleStock
//
//  Created by Andrew James on 12/6/14.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//
//

import Foundation
import Cocoa

extension NSBezierPath
{

    var CGPath: CGPathRef
    {
        get
        {
            return self.transformToCGPath()
        }
    }

    /// Transforms the NSBezierPath into a CGPathRef
    ///
    /// :returns: The transformed NSBezierPath
    private func transformToCGPath() -> CGPathRef {

        // Create path
        var path = CGPathCreateMutable()
        var points = UnsafeMutablePointer<NSPoint>.alloc(3)
        let numElements = self.elementCount

        if numElements > 0 {

            var didClosePath = true

            for index in 0..<numElements {

                let pathType = self.elementAtIndex(index, associatedPoints: points)

                switch pathType {

                case .MoveToBezierPathElement:
                    CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                case .LineToBezierPathElement:
                    CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                    didClosePath = false
                case .CurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
                    didClosePath = false
                case .ClosePathBezierPathElement:
                    CGPathCloseSubpath(path)
                    didClosePath = true
                }
            }

            if !didClosePath { CGPathCloseSubpath(path) }
        }
        
        points.dealloc(3)
        return path
    }
}