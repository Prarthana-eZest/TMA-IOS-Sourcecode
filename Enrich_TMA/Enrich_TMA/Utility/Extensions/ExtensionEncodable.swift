//
//  ExtensionEncodable.swift
//  Enrich_TMA
//
//  Created by Harshal on 10/11/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import Foundation

extension Encodable {

  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }

}
