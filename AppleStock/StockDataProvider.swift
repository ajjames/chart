//
//  DataProvider.swift
//  AppleStock
//
//  Created by Andrew James on 12/6/14.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

import Foundation

public class StockDataProvider
{
    public class func getStockData() -> [NSDate:Double]?
    {
        var result = [NSDate:Double]()
        var error: NSError?
        if let file = NSBundle.mainBundle().pathForResource("stockprices", ofType: "json")
        {
            let data = NSData(contentsOfFile:file)
            if let dictionary = data?.toJsonDictionary()!
            {
                if let stockDatas = dictionary["stockdata"] as? [NSDictionary]
                {
                    for stockData:NSDictionary in stockDatas
                    {
                        let dateString:String = stockData["date"] as? String ?? ""
                        let closeString:String = stockData["close"] as? String ?? ""
                        let possibleDate = NSDate.dateWithNaturalLanguageString(dateString) as? NSDate
                        if let date = possibleDate
                        {
                            let closeValue = NSString(string:closeString).doubleValue
                            result[date] = closeValue
                        }
                    }
                }
            }
        }
        return result
    }
}