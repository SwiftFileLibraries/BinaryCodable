//
//  BinaryDecoderImpl+KeyedContainer.swift
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

import Foundation

extension BinaryDecoderImpl {
    
    struct KeyedContainer<K: CodingKey>: KeyedBinaryDecodingContainer {
        typealias Key = K
        
        // MARK: - Properties
        
        let impl: BinaryDecoderImpl
        let codingPath: [CodingKey]
        let data: Data
        
        var allKeys: [K] {
            return (0..<count!).map({ K(intValue: $0)! })
        }
        func contains(_ key: K) -> Bool {
            if let index = key.intValue {
                return index >= 0 && index < count!
            }
            return false
        }
        
        var count: Int? { self.data.count }
        var isAtEnd: Bool { currentIndex >= (count ?? 0) }
        func isBeyondEnd(_ position: Int, _ length: Int) -> Bool {
            return position + length > (self.count ?? 0)
        }
        
        var indexContainer: BinaryDecoderIndexContainer
        var currentIndex: Int { indexContainer.currentIndex }
        func incrementCurrentIndex(to position: Int) {
            if position > currentIndex {
                indexContainer.currentIndex = position
            }
        }
        
        // MARK: - Initialization
        
        init(impl: BinaryDecoderImpl, codingPath: [CodingKey], data: Data, parentIndexModifier: ParentIndexModifier?) {
            self.impl = impl
            self.codingPath = codingPath
            self.data = data
            self.indexContainer = BinaryDecoderIndexContainer(currentIndex: 0, onChange: parentIndexModifier)
        }
        
        // MARK: - Decoding
        
        func decodeNil(forKey key: K) throws -> Bool {
            let index = try index(for: key)
            let data = try getNextValue(ofType: Never.self, position: index, length: 1)
            incrementCurrentIndex(to: index + 1)
            return data[data.startIndex] == 0
        }
        
        func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
            let index = try index(for: key)
            let data = try getNextValue(ofType: UInt8.self, position: index, length: 1)
            incrementCurrentIndex(to: index + 1)
            
            // Not 100% on this implementation, this does make assumptions.
            switch data[data.startIndex] {
            case 0x01:
                return true
            case 0x00:
                return false
            default:
                return false
            }
        }
        
        func decode(_ type: String.Type, forKey key: K) throws -> String {
            let index = try index(for: key)
            var utf8Decoder = UTF8()
            var string = ""
            var decodedBytes = 0
            
            let data = try getNextValue(ofType: String.self, position: index, length: (count ?? 0) - index)
            var generator = data.makeIterator()
            
            while true {
                switch utf8Decoder.decode(&generator) {
                case .scalarValue(let unicodeScalar) where unicodeScalar.value > 0:
                    string.append(String(unicodeScalar))
                    decodedBytes += 1
                case .scalarValue(_): // End of string
                    incrementCurrentIndex(to: index + decodedBytes + 1)
                    return string
                case .emptyInput:
                    var path = self.codingPath
                    path.append(_BinaryKey(index: currentIndex))
                    
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: path,
                                                                            debugDescription: "Unable to decode null terminated UTF8 String. No more unicode characters are available."))
                case .error:
                    var path = self.codingPath
                    path.append(_BinaryKey(index: currentIndex))
                    
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: path,
                                                                            debugDescription: "Unable to decode null terminated UTF8 String. An error occured during decoding"))
                }
            }
        }
        
        func decode(_ type: String.Type, length: Int, forKey key: K) throws -> String {
            let index = try index(for: key)
            var utf8 = UTF8()
            var string = ""
            
            let data = try getNextValue(ofType: String.self, position: index, length: length)
            var generator = data.makeIterator()
            
            while true {
                switch utf8.decode(&generator) {
                case .scalarValue(let unicodeScalar):
                    string.append(String(unicodeScalar))
                case .emptyInput:
                    incrementCurrentIndex(to: index + length)
                    return string
                case .error:
                    var path = self.codingPath
                    path.append(_BinaryKey(index: currentIndex))
                    
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: path,
                                                                            debugDescription: "Unable to decode null terminated UTF8 String. An error occured during decoding"))
                }
            }
        }
        
        func decode(_ type: Double.Type, forKey key: K) throws -> Double {
            let index = try index(for: key)
            let data = try getNextValue(ofType: Double.self, position: index, length: 8)
            incrementCurrentIndex(to: index + 8)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt64(bigEndianBytes: data) : UInt64(littleEndianBytes: data)
            return unsafeConversion(uInt)
        }
        
        func decode(_ type: Float.Type, forKey key: K) throws -> Float {
            let index = try index(for: key)
            let data = try getNextValue(ofType: Double.self, position: index, length: 4)
            incrementCurrentIndex(to: index + 4)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt32(bigEndianBytes: data) : UInt32(littleEndianBytes: data)
            return unsafeConversion(uInt)
        }
        
        func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: Int8.self, position: index, length: 1)
            incrementCurrentIndex(to: index + 1)
            return Int8(bitPattern: data[data.startIndex])
        }
        
        func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: Int16.self, position: index, length: 2)
            incrementCurrentIndex(to: index + 2)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt16(bigEndianBytes: data) : UInt16(littleEndianBytes: data)
            return Int16(bitPattern: uInt)
        }
        
        func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: Int32.self, position: index, length: 4)
            incrementCurrentIndex(to: index + 4)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt32(bigEndianBytes: data) : UInt32(littleEndianBytes: data)
            return Int32(bitPattern: uInt)
        }
        
        func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: Int64.self, position: index, length: 8)
            incrementCurrentIndex(to: index + 8)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt64(bigEndianBytes: data) : UInt64(littleEndianBytes: data)
            return Int64(bitPattern: uInt)
        }
        
        func decode(_ type: Int.Type, forKey key: K) throws -> Int {
            let index = try index(for: key)
            let bytes = type.bitWidth / 8
            let data = try getNextValue(ofType: Int.self, position: index, length: bytes)
            incrementCurrentIndex(to: index + bytes)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt(bigEndianBytes: data) : UInt(littleEndianBytes: data)
            return Int(bitPattern: uInt)
        }
        
        func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: UInt8.self, position: index, length: 1)
            incrementCurrentIndex(to: index + 1)
            return data[data.startIndex]
        }
        
        func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: UInt16.self, position: index, length: 2)
            incrementCurrentIndex(to: index + 2)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt16(bigEndianBytes: data) : UInt16(littleEndianBytes: data)
        }
        
        func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: UInt32.self, position: index, length: 4)
            incrementCurrentIndex(to: index + 4)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt32(bigEndianBytes: data) : UInt32(littleEndianBytes: data)
        }
        
        func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
            let index = try index(for: key)
            let data = try getNextValue(ofType: UInt64.self, position: index, length: 8)
            incrementCurrentIndex(to: index + 8)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt64(bigEndianBytes: data) : UInt64(littleEndianBytes: data)
        }
        
        func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
            let index = try index(for: key)
            let bytes = type.bitWidth / 8
            let data = try getNextValue(ofType: Int.self, position: index, length: bytes)
            incrementCurrentIndex(to: index + bytes)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt(bigEndianBytes: data) : UInt(littleEndianBytes: data)
        }
        
        func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
            let newDecoder = try decoderForNextElement(ofType: T.self, forKey: key)
            let object = try T(from: newDecoder)
            return object
        }
        
        // MARK: - Containers
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let decoder = try decoderForNextElement(ofType: KeyedDecodingContainer<NestedKey>.self, forKey: key)
            let container = try decoder.container(keyedBy: type)
            return container
        }
        
        func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
            let decoder = try decoderForNextElement(ofType: UnkeyedDecodingContainer.self, forKey: key)
            let container = try decoder.unkeyedContainer()
            return container
        }
        
        func superDecoder() throws -> Decoder {
            let decoder = try decoderForNextElement(ofType: Decoder.self, forKey: K(stringValue: "super")!)
            return decoder
        }
        
        func superDecoder(forKey key: K) throws -> Decoder {
            let decoder = try decoderForNextElement(ofType: Decoder.self, forKey: key)
            return decoder
        }
        
        // MARK: - Utilities
        
        @inline(__always)
        private func index<K: CodingKey>(for key: K) throws -> Int {
            guard let int = key.intValue else {
                throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath,
                                                                           debugDescription: "The provided key does not exist.",
                                                                           underlyingError: nil))
            }
            return int
        }
        
        private func decoderForKey<T, LocalKey: CodingKey>(ofType: T.Type, forKey key: LocalKey, length: Int? = nil) throws -> BinaryDecoderImpl {
            let index = try index(for: key)
            let value = try self.getNextValue(ofType: T.self, position: index, length: length ?? ((count ?? 0) - index))
            let newPath = self.codingPath + [key]
            
            let indexContainer = self.indexContainer
            
            return BinaryDecoderImpl(
                userInfo: self.impl.userInfo,
                from: Data(value),
                codingPath: newPath,
                options: self.impl.options,
                parentIndexModifier: { (increment) in
                    indexContainer.currentIndex += increment
                }
            )
        }
        
        private func decoderForNextElement<T>(ofType: T.Type, forKey key: K, length: Int? = nil) throws -> BinaryDecoderImpl {
            let index = try index(for: key)
            let value = try self.getNextValue(ofType: T.self, position: index, length: length ?? ((count ?? 0) - currentIndex))
            let newPath = self.codingPath + [_BinaryKey(index: index)]
            
            let indexContainer = self.indexContainer
            
            return BinaryDecoderImpl(
                userInfo: self.impl.userInfo,
                from: Data(value),
                codingPath: newPath,
                options: self.impl.options,
                parentIndexModifier: { (increment) in
                    indexContainer.currentIndex += increment
                }
            )
        }
        
        @inline(__always)
        private func getNextValue<T>(ofType: T.Type, position: Int, length: Int) throws -> Data.SubSequence {
            guard !self.isBeyondEnd(position, length) else {
                var message = "Unkeyed container is at end."
                if T.self == UnkeyedContainer.self {
                    message = "Cannot get nested unkeyed container -- unkeyed container is at end."
                }
                if T.self == Decoder.self {
                    message = "Cannot get superDecoder() -- binary container is at end."
                }
                
                var path = self.codingPath
                path.append(_BinaryKey(index: position))
                
                throw DecodingError.valueNotFound(
                    T.self,
                    .init(codingPath: path,
                          debugDescription: message,
                          underlyingError: nil))
            }
            
            return self.data[position..<(position + length)]
        }
    }
    
}
