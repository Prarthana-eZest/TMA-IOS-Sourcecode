//
//  FormatterUtils.swift
//  Enrich_TMA
//
//  Created by Harshal on 27/10/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import Foundation

struct Utils
{
    static let calendar: Calendar =
    {
        var c = Calendar(identifier: .gregorian)
        return c
    }()
    
    static let dateFormatter: DateFormatter =
    {
        let df = DateFormatter()
        return df
    }()
}
