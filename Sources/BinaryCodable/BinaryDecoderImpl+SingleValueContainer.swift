//
//  BinaryDecoderImpl+SingleValueContainer.swift
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
    
    struct SingleValueContainter: SingleValueBinaryDecodingContainer {
        
        // MARK: - Properties
        
        let impl: BinaryDecoderImpl
        let codingPath: [CodingKey]
        let data: Data
        
        var count: Int? { self.data.count }
        var isAtEnd: Bool {
            currentIndex >= (count ?? 0)
        }
        func isBeyondEnd(_ position: Int, _ length: Int) -> Bool {
            return position + length > (self.count ?? 0)
        }
        
        var indexContainer: BinaryDecoderIndexContainer
        var currentIndex: Int { indexContainer.currentIndex }
        func incrementCurrentIndex(by length: Int) {
            indexContainer.currentIndex += length
        }
        
        // MARK: - Initialization
        
        init(impl: BinaryDecoderImpl, codingPath: [CodingKey], data: Data, parentIndexModifier: ParentIndexModifier?) {
            self.impl = impl
            self.codingPath = codingPath
            self.data = data
            self.indexContainer = BinaryDecoderIndexContainer(currentIndex: 0, onChange: parentIndexModifier)
        }
        
        // MARK: - Decoding
        
        func incrementIndex(by length: Int) throws {
            if (length > 0) {
                let _ = try getNextValue(ofType: Any.self, length: length)
            }
            incrementCurrentIndex(by: length)
        }
        
        func decodeNil() -> Bool {
            do {
                let data = try getNextValue(ofType: Never.self, length: 1)
                incrementCurrentIndex(by: 1)
                return data[data.startIndex] == 0 
            } catch {
                return false
            }
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            let data = try getNextValue(ofType: UInt8.self, length: 1)
            incrementCurrentIndex(by: 1)
            
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
        
        func decode(_ type: String.Type) throws -> String {
            var utf8Decoder = UTF8()
            var string = ""
            var decodedBytes = 0
            
            let data = try getNextValue(ofType: String.self, length: (count ?? 0) - currentIndex)
            var generator = data.makeIterator()
            
            while true {
                switch utf8Decoder.decode(&generator) {
                case .scalarValue(let unicodeScalar) where unicodeScalar.value > 0:
                    string.append(String(unicodeScalar))
                    decodedBytes += 1
                case .scalarValue(_): // End of string
                    incrementCurrentIndex(by: decodedBytes + 1)
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
        
        func decode(_ type: String.Type, length: Int) throws -> String {
            var utf8 = UTF8()
            var string = ""
            
            let data = try getNextValue(ofType: String.self, length: length)
            var generator = data.makeIterator()
            
            while true {
                switch utf8.decode(&generator) {
                case .scalarValue(let unicodeScalar):
                    string.append(String(unicodeScalar))
                case .emptyInput:
                    incrementCurrentIndex(by: length)
                    return string
                case .error:
                    var path = self.codingPath
                    path.append(_BinaryKey(index: currentIndex))
                    
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: path,
                                                                            debugDescription: "Unable to decode null terminated UTF8 String. An error occured during decoding"))
                }
            }
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            let data = try getNextValue(ofType: Double.self, length: 8)
            incrementCurrentIndex(by: 8)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt64(bigEndianBytes: data) : UInt64(littleEndianBytes: data)
            return unsafeConversion(uInt)
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            let data = try getNextValue(ofType: Double.self, length: 4)
            incrementCurrentIndex(by: 4)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt32(bigEndianBytes: data) : UInt32(littleEndianBytes: data)
            return unsafeConversion(uInt)
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            let data = try getNextValue(ofType: Int8.self, length: 1)
            incrementCurrentIndex(by: 1)
            return Int8(bitPattern: data[data.startIndex])
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            let data = try getNextValue(ofType: Int16.self, length: 2)
            incrementCurrentIndex(by: 2)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt16(bigEndianBytes: data) : UInt16(littleEndianBytes: data)
            return Int16(bitPattern: uInt)
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            let data = try getNextValue(ofType: Int32.self, length: 4)
            incrementCurrentIndex(by: 4)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt32(bigEndianBytes: data) : UInt32(littleEndianBytes: data)
            return Int32(bitPattern: uInt)
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            let data = try getNextValue(ofType: Int64.self, length: 8)
            incrementCurrentIndex(by: 8)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt64(bigEndianBytes: data) : UInt64(littleEndianBytes: data)
            return Int64(bitPattern: uInt)
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            let bytes = type.bitWidth / 8
            let data = try getNextValue(ofType: Int.self, length: bytes)
            incrementCurrentIndex(by: bytes)
            let uInt = impl.options.numberDecodingStrategy == .bigEndian ? UInt(bigEndianBytes: data) : UInt(littleEndianBytes: data)
            return Int(bitPattern: uInt)
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            let data = try getNextValue(ofType: UInt8.self, length: 1)
            incrementCurrentIndex(by: 1)
            return data[data.startIndex]
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            let data = try getNextValue(ofType: UInt16.self, length: 2)
            incrementCurrentIndex(by: 2)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt16(bigEndianBytes: data) : UInt16(littleEndianBytes: data)
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            let data = try getNextValue(ofType: UInt32.self, length: 4)
            incrementCurrentIndex(by: 4)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt32(bigEndianBytes: data) : UInt32(littleEndianBytes: data)
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            let data = try getNextValue(ofType: UInt64.self, length: 8)
            incrementCurrentIndex(by: 8)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt64(bigEndianBytes: data) : UInt64(littleEndianBytes: data)
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            let bytes = type.bitWidth / 8
            let data = try getNextValue(ofType: Int.self, length: bytes)
            incrementCurrentIndex(by: bytes)
            return impl.options.numberDecodingStrategy == .bigEndian ? UInt(bigEndianBytes: data) : UInt(littleEndianBytes: data)
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let newDecoder = try decoderForNextElement(ofType: T.self)
            let object = try T(from: newDecoder)
            return object
        }
        
        func decode<T>(_ type: T.Type, length: Int) throws -> T where T : Decodable {
            let newDecoder = try decoderForNextElement(ofType: T.self, length: length)
            let object = try T(from: newDecoder)
            return object
        }
        
        // MARK: - Utilities
        
        private func decoderForNextElement<T>(ofType: T.Type, length: Int? = nil) throws -> BinaryDecoderImpl {
            let value = try self.getNextValue(ofType: T.self, length: length ?? ((count ?? 0) - currentIndex))
            let newPath = self.codingPath + [_BinaryKey(index: currentIndex)]
            
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
        private func getNextValue<T>(ofType: T.Type, length: Int) throws -> Data.SubSequence {
            guard !self.isBeyondEnd(currentIndex, length) else {
                let message = "Single value container is at end."
                var path = self.codingPath
                path.append(_BinaryKey(index: currentIndex))
                
                throw DecodingError.valueNotFound(
                    T.self,
                    .init(codingPath: path,
                          debugDescription: message,
                          underlyingError: nil))
            }
            
            return self.data[currentIndex..<(currentIndex + length)]
        }
        
    }
    
}
