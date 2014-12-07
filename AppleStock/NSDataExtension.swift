//
//  NSDataExtension.swift
//  AppleStock
//
//  Created by Andrew James on 12/6/14.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

import Foundation

public extension NSData
{
    public class func dataWith(string:String) -> NSData
    {
        return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    }

    public func toJsonDictionary() -> NSDictionary?
    {
        var error:NSError?
        return NSJSONSerialization.JSONObjectWithData(self, options:.AllowFragments, error: &error) as? NSDictionary
    }
    
}
