//
//  BinaryDecoderImpl.swift
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

/// The standard type for the block that will update the parent decoder object's current index.
typealias ParentIndexModifier = ((_ increment: Int) -> Void)

/// The container that maintains the current location that the decoder is decoding from in the data.
///
/// Child decoders need to share the final location that they read data from back to the parent decoder. That way the parent can start reading data from where the child decoder left off.
///
/// - note: Not all decoder protocols use mutating methods. This is a class to get around that limitation. If there is a better way to do this, please open an issue or pull request. I just wanted something that works at this point.
class BinaryDecoderIndexContainer {
    
    /// The index of the next byte to be decoded.
    var currentIndex: Int {
        didSet {
            onChange?(currentIndex - oldValue)
        }
    }
    
    /// The block to call when the current index is updated to update the parent.
    let onChange: ParentIndexModifier?
    
    /// Create a new current index container.
    /// - parameter currentIndex: The index of the next byte to be decoded.
    /// - parameter onChange: The block to call when the current index is updated to update the parent.
    /// - returns: A new `BinaryDecoderIndexContainer`.
    init(currentIndex: Int, onChange: ParentIndexModifier?) {
        self.currentIndex = currentIndex
        self.onChange = onChange
    }
    
}

/// The actual impelentation of the decoder that supports binary data.
struct BinaryDecoderImpl {
    
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    let data: Data
    let options: BinaryDecoder._Options
    internal var parentIndexModifier: ParentIndexModifier?
    
    init(userInfo: [CodingUserInfoKey: Any], from data: Data, codingPath: [CodingKey], options: BinaryDecoder._Options, parentIndexModifier: ParentIndexModifier?) {
        self.userInfo = userInfo
        self.codingPath = codingPath
        self.data = data
        self.options = options
        self.parentIndexModifier = parentIndexModifier
    }
    
}

extension BinaryDecoderImpl: Decoder {
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        KeyedDecodingContainer<Key>(
            KeyedContainer<Key>(impl: self,
                                codingPath: codingPath,
                                data: data,
                                parentIndexModifier: parentIndexModifier)
        )
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        UnkeyedContainer(impl: self, codingPath: codingPath, data: data, parentIndexModifier: parentIndexModifier)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueContainter(impl: self, codingPath: codingPath, data: data, parentIndexModifier: parentIndexModifier)
    }
    
}
