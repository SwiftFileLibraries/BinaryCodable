//
//  BinaryDecoder.swift
//  BinaryCodable
//
//  Created by Brandon McQuilkin on 8/24/21.
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

open class BinaryDecoder {
    
    // MARK: - Options
    
    /// The strategy to use for decoding numerical values.
    public enum NumberDecodingStrategy {
        /**
         Numbers are stored with the least significant byte last.
         */
        case bigEndian
        /**
         Numbers are stored with the least-significant byte first.
         */
        case littleEndian
    }
    
    /// The strategy to use in decoding numbers. Defaults to `.littleEndian`.
    open var numberDecodingStrategy: NumberDecodingStrategy = .littleEndian
    
    /// A dictionary you use to customize the decoding process by providing contextual information.
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    
    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    struct _Options {
        let numberDecodingStrategy: NumberDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }
    
    /// The options set on the top-level decoder.
    var options: _Options {
        return _Options(numberDecodingStrategy: numberDecodingStrategy,
                        userInfo: userInfo)
    }
    
    // MARK: - Constructing a Binary Decoder
    
    /// Creates a new, reusable binary decoder with the default formatting settings and decoding strategies.
    public init() {
        
    }
    
    // MARK: - Decoding Values
    

    /// Returns a value of the type you specify, decoded from binary data.
    ///
    /// If a value within the data fails to decode, this method throws the corresponding error.
    ///
    /// - parameter type: The type of the value to decode from the supplied binary object.
    /// - parameter data: The binary object to decode.
    /// - returns: A value of the specified type, if the decoder can parse the data.
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        try T(from: BinaryDecoderImpl(userInfo: userInfo, from: data, codingPath: [], options: options, parentIndexModifier: nil))
    }
    
}
