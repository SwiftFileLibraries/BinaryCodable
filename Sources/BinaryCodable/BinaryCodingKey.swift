//
//  File.swift
//  File
//
//  Created by Brandon McQuilkin on 8/29/21.
//

/// A type that can be used as a key for encoding and decoding binary data.
public protocol BinaryCodingKey: CodingKey {
    
    /// The number of bytes to decode.
    var length: Int? { get }
    
}
