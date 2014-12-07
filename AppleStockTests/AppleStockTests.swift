//
//  AppleStockTests.swift
//  AppleStockTests
//
//  Created by Andrew James on 12/6/14.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

import Cocoa
import XCTest
import AppleStock

class AppleStockTests: XCTestCase
{

    let expected = [
        "2014-09-08".toSimpleDate(): 95.36,
        "2014-09-09".toSimpleDate(): 97.99,
        "2014-09-10".toSimpleDate(): 93.00,
        "2014-09-11".toSimpleDate(): 101.43,
        "2014-09-12".toSimpleDate(): 102.66]

    func testGetStockData()
    {
        let possibleStockData = StockDataProvider.getStockData()
        XCTAssertNotNil(possibleStockData)
        if let stockData = possibleStockData
        {
            XCTAssertEqual(stockData, expected)
        }
    }

}


private extension String
{
    private func toSimpleDate() -> NSDate
    {
        return NSDate.dateWithNaturalLanguageString(self) as NSDate
    }
}