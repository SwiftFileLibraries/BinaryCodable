//
//  File.swift
//  File
//
//  Created by Brandon McQuilkin on 8/25/21.
//

import Foundation

typealias ParentIndexModifier = ((_ increment: Int) -> Void)

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
        throw DecodingError.typeMismatch(Data.self, DecodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Unable to decode keyed container from binary data."
        ))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch(Data.self, DecodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Unable to decode unkeyed container from binary data."
        ))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.typeMismatch(Data.self, DecodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Unable to decode single value container from binary data."
        ))
    }
    
    func binaryContainer() throws -> BinaryDecodingContainer {
        BinaryContainer(impl: self, codingPath: codingPath, data: data, parentIndexModifier: parentIndexModifier)
    }
    
}

extension BinaryDecoderImpl {
    
    struct BinaryContainer: BinaryDecodingContainer {
        
        let impl: BinaryDecoderImpl
        let codingPath: [CodingKey]
        let data: Data

        var count: Int? { self.data.count }
        
        var isAtEnd: Bool { currentIndex >= (count ?? 0) }
        
        func isAtEnd(_ position: Int, _ length: Int) -> Bool {
            return position + length >= (self.count ?? 0)
        }
        
        var currentIndex = 0 {
            didSet {
                parentIndexModifier?(currentIndex - oldValue)
            }
        }
        
        internal var parentIndexModifier: ((_ increment: Int) -> Void)?

        init(impl: BinaryDecoderImpl, codingPath: [CodingKey], data: Data, parentIndexModifier: ParentIndexModifier?) {
            self.impl = impl
            self.codingPath = codingPath
            self.data = data
            self.parentIndexModifier = parentIndexModifier
        }
        
        mutating func incrementIndex(by length: Int) throws {
            let _ = try getNextValue(ofType: Any.self, length: length)
            currentIndex += length
        }
        
        mutating func decode(_ type: Bool.Type) throws -> Bool {
            let data = try getNextValue(ofType: UInt8.self, length: 1)
            currentIndex += 1
            
            // Not 100% on this implementation, this does make assumptions.
            switch data[0] {
            case 0x01:
                return true
            case 0x00:
                return false
            default:
                return false
            }
        }
        
        mutating func decode(_ type: String.Type) throws -> String {
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
                  currentIndex += decodedBytes + 1
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
        
        mutating func decode(_ type: String.Type, length: Int) throws -> String {
            var utf8 = UTF8()
            var string = ""
            
            let data = try getNextValue(ofType: String.self, length: length)
            var generator = data.makeIterator()
            
            while true {
              switch utf8.decode(&generator) {
              case .scalarValue(let unicodeScalar):
                  string.append(String(unicodeScalar))
              case .emptyInput:
                  currentIndex += length
                  return string
              case .error:
                  var path = self.codingPath
                  path.append(_BinaryKey(index: currentIndex))
                  
                  throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: path,
                                                                          debugDescription: "Unable to decode null terminated UTF8 String. An error occured during decoding"))
              }
            }
        }
        
        mutating func decode(_ type: Double.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> Double {
            let data = try getNextValue(ofType: Double.self, length: 8)
            currentIndex += 8
            let uInt = UInt64(from: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
            return unsafeConversion(uInt)
        }
        
        mutating func decode(_ type: Float.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> Float {
            let data = try getNextValue(ofType: Double.self, length: 4)
            currentIndex += 4
            let uInt = UInt32(from: (data[0], data[1], data[2], data[3]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
            return unsafeConversion(uInt)
        }
        
        @available(macOS, unavailable)
        mutating func decode(_ type: Float16.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> Float16 {
            let data = try getNextValue(ofType: Double.self, length: 2)
            currentIndex += 2
            let uInt = UInt16(from: (data[0], data[1]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
            return unsafeConversion(uInt)
        }
        
        mutating func decode(_ type: Int8.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> Int8 {
            let data = try getNextValue(ofType: Int8.self, length: 1)
            currentIndex += 1
            return Int8(bitPattern: data[0])
        }
        
        mutating func decode(_ type: Int16.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> Int16 {
            let data = try getNextValue(ofType: Int16.self, length: 2)
            currentIndex += 2
            let uInt = UInt16(from: (data[0], data[1]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
            return Int16(bitPattern: uInt)
        }
        
        mutating func decode(_ type: Int32.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> Int32 {
            let data = try getNextValue(ofType: Int32.self, length: 4)
            currentIndex += 4
            let uInt = UInt32(from: (data[0], data[1], data[2], data[3]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
            return Int32(bitPattern: uInt)
        }
        
        mutating func decode(_ type: Int64.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> Int64 {
            let data = try getNextValue(ofType: Int64.self, length: 8)
            currentIndex += 8
            let uInt = UInt64(from: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
            return Int64(bitPattern: uInt)
        }
        
        mutating func decode(_ type: UInt8.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> UInt8 {
            let data = try getNextValue(ofType: UInt8.self, length: 1)
            currentIndex += 1
            return data[0]
        }
        
        mutating func decode(_ type: UInt16.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> UInt16 {
            let data = try getNextValue(ofType: UInt16.self, length: 2)
            currentIndex += 2
            return UInt16(from: (data[0], data[1]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
        }
        
        mutating func decode(_ type: UInt32.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> UInt32 {
            let data = try getNextValue(ofType: UInt32.self, length: 4)
            currentIndex += 4
            return UInt32(from: (data[0], data[1], data[2], data[3]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
        }
        
        mutating func decode(_ type: UInt64.Type, strategy: BinaryDecoder.NumberDecodingStrategy? = nil) throws -> UInt64 {
            let data = try getNextValue(ofType: UInt64.self, length: 8)
            currentIndex += 8
            return UInt64(from: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]), bigEndian: (strategy ?? impl.options.numberDecodingStrategy) == .bigEndian)
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let newDecoder = try decoderForNextElement(ofType: T.self)
            let object = try T(from: newDecoder)
            return object
        }
        
        mutating func nestedBinaryContainer() throws -> BinaryDecodingContainer {
            let decoder = try decoderForNextElement(ofType: BinaryDecodingContainer.self)
            let container = try decoder.binaryContainer()
            return container
        }
        
        private mutating func decoderForNextElement<T>(ofType: T.Type, length: Int? = nil) throws -> BinaryDecoderImpl {
            let value = try self.getNextValue(ofType: T.self, length: length ?? ((count ?? 0) - currentIndex))
            let newPath = self.codingPath + [_BinaryKey(index: currentIndex)]

            return BinaryDecoderImpl(
                userInfo: self.impl.userInfo,
                from: Data(value),
                codingPath: newPath,
                options: self.impl.options,
                parentIndexModifier: { (increment) in
                    self.currentIndex += increment
                }
            )
        }
        
        @inline(__always)
        private func getNextValue<T>(ofType: T.Type, length: Int) throws -> Data.SubSequence {
            guard !self.isAtEnd(currentIndex, length) else {
                var message = "Unkeyed container is at end."
                if T.self == BinaryContainer.self {
                    message = "Cannot get nested binary container -- binary container is at end."
                }
                if T.self == Decoder.self {
                    message = "Cannot get superDecoder() -- binary container is at end."
                }

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
