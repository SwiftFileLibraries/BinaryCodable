//
//  _BinaryKey.swift
//  BinaryCodable
//
//  Created by Brandon McQuilkin on 8/25/21.
//  Copyright (c) 2021 Brandon McQuilkin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//

import Foundation

/// The internal coding key for the binary decoders.
internal struct _BinaryKey: CodingKey {
    
    internal var stringValue: String
    internal var intValue: Int?

    internal init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    internal init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    internal init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    internal init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    internal static let `super` = _BinaryKey(stringValue: "super")!
}
