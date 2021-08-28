//
//  SingleValueBinaryDecodingContainer.swift
//  BinaryCodable
//
//  Created by Brandon McQuilkin on 8/27/21.
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

public protocol SingleValueBinaryDecodingContainer: SingleValueDecodingContainer {
    
    /// Increments the current index by the given length.
    /// - parameter length: The number of bytes to skip.
    /// - throws: `DecodingError.valueNotFound` if there are no more values to
    ///   decode.
    mutating func incrementIndex(by length: Int) throws
    
    /// Decodes a value of the given type.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter length: The length of the string to decode in bytes.
    /// - returns: A value of the requested type, if present for the given key
    ///   and convertible to the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value
    ///   is null, or of there are no more values to decode.
    mutating func decode(_ type: String.Type, length: Int) throws -> String
    
}

