//
//  File.swift
//  File
//
//  Created by Brandon McQuilkin on 8/25/21.
//

import Foundation

typealias ParentIndexModifier = ((_ increment: Int) -> Void)

class BinaryDecoderIndexContainer {
    
    var currentIndex: Int {
        didSet {
            onChange?(currentIndex - oldValue)
        }
    }
    
    let onChange: ParentIndexModifier?
    
    init(currentIndex: Int, onChange: ParentIndexModifier?) {
        self.currentIndex = currentIndex
        self.onChange = onChange
    }
    
}

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
        
        func isBeyondEnd(_ position: Int, _ length: Int) -> Bool {
            return position + length > (self.count ?? 0)
        }
        
        var indexContainer: BinaryDecoderIndexContainer
        
        var currentIndex: Int { indexContainer.currentIndex }

        init(impl: BinaryDecoderImpl, codingPath: [CodingKey], data: Data, parentIndexModifier: ParentIndexModifier?) {
            self.impl = impl
            self.codingPath = codingPath
            self.data = data
            self.indexContainer = BinaryDecoderIndexContainer(currentIndex: 0, onChange: parentIndexModifier)
        }
        
        mutating func incrementIndex(by length: Int) throws {
            let _ = try getNextValue(ofType: Any.self, length: length)
            indexContainer.currentIndex += length
        }
        
        mutating func decode(_ type: Bool.Type) throws -> Bool {
            let data = try getNextValue(ofType: UInt8.self, length: 1)
            indexContainer.currentIndex += 1
            
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
                  indexContainer.currentIndex += decodedBytes + 1
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
                  indexContainer.currentIndex += length
                  return string
              case .error:
                  var path = self.codingPath
                  path.append(_BinaryKey(index: currentIndex))
                  
                  throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: path,
                                                                          debugDescription: "Unable to decode null terminated UTF8 String. An error occured during decoding"))
              }
            }
        }
        
        mutating func decode(_ type: Double.Type) throws -> Double {
            let data = try getNextValue(ofType: Double.self, length: 8)
            indexContainer.currentIndex += 8
            let uInt = UInt64(from: (data[data.startIndex], data[data.startIndex + 1], data[data.startIndex + 2], data[data.startIndex + 3], data[data.startIndex + 4], data[data.startIndex + 5], data[data.startIndex + 6], data[data.startIndex + 7]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
            return unsafeConversion(uInt)
        }
        
        mutating func decode(_ type: Float.Type) throws -> Float {
            let data = try getNextValue(ofType: Double.self, length: 4)
            indexContainer.currentIndex += 4
            let uInt = UInt32(from: (data[data.startIndex], data[data.startIndex + 1], data[data.startIndex + 2], data[data.startIndex + 3]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
            return unsafeConversion(uInt)
        }
        
        @available(macOS, unavailable)
        mutating func decode(_ type: Float16.Type) throws -> Float16 {
            let data = try getNextValue(ofType: Double.self, length: 2)
            indexContainer.currentIndex += 2
            let uInt = UInt16(from: (data[data.startIndex], data[data.startIndex + 1]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
            return unsafeConversion(uInt)
        }
        
        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            let data = try getNextValue(ofType: Int8.self, length: 1)
            indexContainer.currentIndex += 1
            return Int8(bitPattern: data[data.startIndex])
        }
        
        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            let data = try getNextValue(ofType: Int16.self, length: 2)
            indexContainer.currentIndex += 2
            let uInt = UInt16(from: (data[data.startIndex], data[data.startIndex + 1]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
            return Int16(bitPattern: uInt)
        }
        
        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            let data = try getNextValue(ofType: Int32.self, length: 4)
            indexContainer.currentIndex += 4
            let uInt = UInt32(from: (data[data.startIndex], data[data.startIndex + 1], data[data.startIndex + 2], data[data.startIndex + 3]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
            return Int32(bitPattern: uInt)
        }
        
        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            let data = try getNextValue(ofType: Int64.self, length: 8)
            indexContainer.currentIndex += 8
            let uInt = UInt64(from: (data[data.startIndex], data[data.startIndex + 1], data[data.startIndex + 2], data[data.startIndex + 3], data[data.startIndex + 4], data[data.startIndex + 5], data[data.startIndex + 6], data[data.startIndex + 7]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
            return Int64(bitPattern: uInt)
        }
        
        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            let data = try getNextValue(ofType: UInt8.self, length: 1)
            indexContainer.currentIndex += 1
            return data[data.startIndex]
        }
        
        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            let data = try getNextValue(ofType: UInt16.self, length: 2)
            indexContainer.currentIndex += 2
            return UInt16(from: (data[data.startIndex], data[data.startIndex + 1]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
        }
        
        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            let data = try getNextValue(ofType: UInt32.self, length: 4)
            indexContainer.currentIndex += 4
            return UInt32(from: (data[data.startIndex], data[data.startIndex + 1], data[data.startIndex + 2], data[data.startIndex + 3]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
        }
        
        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            let data = try getNextValue(ofType: UInt64.self, length: 8)
            indexContainer.currentIndex += 8
            return UInt64(from: (data[data.startIndex], data[data.startIndex + 1], data[data.startIndex + 2], data[data.startIndex + 3], data[data.startIndex + 4], data[data.startIndex + 5], data[data.startIndex + 6], data[data.startIndex + 7]), bigEndian: impl.options.numberDecodingStrategy == .bigEndian)
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
