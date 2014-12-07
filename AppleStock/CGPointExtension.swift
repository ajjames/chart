//
//  CGPointExtension.swift
//  AppleStock
//
//  Created by Andrew James on 12/7/14.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

import Foundation

extension CGPoint
{
    func distanceFrom(destinationPoint:CGPoint) -> CGFloat
    {
        let deltaX = destinationPoint.x - self.x
        let deltaY = destinationPoint.y - self.y
        let segmentLength = sqrt((deltaX * deltaX) + (deltaY * deltaY))
        return segmentLength
    }
}