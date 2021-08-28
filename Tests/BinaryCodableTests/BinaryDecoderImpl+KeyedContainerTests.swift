//
//  BinaryDecoderImpl+KeyedContainerTests.swift
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

import XCTest
@testable import BinaryCodable

final class KeyedContainerTests: XCTestCase {
    
    let intData = Data([0xf3, 0x22, 0x01, 0xd4, 0xa9, 0x30, 0x7b, 0xff])
    
    enum IntCodingKeys: Int, RawRepresentable, CodingKey {
        case integer = 0
    }
    
    func keyedContainer<K: CodingKey>(for data: Data) -> KeyedDecodingContainer<K> {
        KeyedDecodingContainer(BinaryDecoderImpl.KeyedContainer(
            impl: BinaryDecoderImpl(
                userInfo: [:],
                from: data,
                codingPath: [],
                options: BinaryDecoder._Options(
                    numberDecodingStrategy: .bigEndian,
                    userInfo: [:]),
                parentIndexModifier: nil),
            codingPath: [],
            data: data,
            parentIndexModifier: nil))
    }
    
    func binaryDecoder(for data: Data) -> BinaryDecoderImpl {
        BinaryDecoderImpl(
            userInfo: [:],
            from: data,
            codingPath: [],
            options: BinaryDecoder._Options(
                numberDecodingStrategy: .bigEndian,
                userInfo: [:]),
            parentIndexModifier: nil)
    }
    
    // MARK: - Test Container
    
    func testUnkeyedContainer() {
        let decoder = binaryDecoder(for: intData)
        
        do {
            let container = try decoder.unkeyedContainer()
            XCTAssertNotNil(container)
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Test Decode
    
    func testDecodeNil() {
        
        enum CodingKeys: Int, CodingKey {
            case isNil = 0
            case isNotNil = 1
        }
        
        let container: KeyedDecodingContainer<CodingKeys> = keyedContainer(for: Data([0x00, 0x01]))
        do {
            let trueOutput = try container.decodeNil(forKey: .isNil)
            let falseOutput = try? container.decodeNil(forKey: .isNotNil)
            XCTAssertEqual(trueOutput, true)
            XCTAssertEqual(falseOutput, false)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeBool() {
        
        enum CodingKeys: Int, CodingKey {
            case isFalse = 0
            case isTrue = 1
            case isIncorrect = 2
        }
        
        let container: KeyedDecodingContainer<CodingKeys> = keyedContainer(for: Data([0x00, 0x01, 0x02]))
        do {
            let falseOutput = try container.decode(Bool.self, forKey: .isFalse)
            let trueOutput = try container.decode(Bool.self, forKey: .isTrue)
            let incorrectOutput = try container.decode(Bool.self, forKey: .isIncorrect)
            XCTAssertEqual(falseOutput, false)
            XCTAssertEqual(trueOutput, true)
            XCTAssertEqual(incorrectOutput, false)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt8() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(UInt8.self, forKey: .integer)
            XCTAssertEqual(output, 243)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt16() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(UInt16.self, forKey: .integer)
            XCTAssertEqual(output, 62242)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt32() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(UInt32.self, forKey: .integer)
            XCTAssertEqual(output, 4079092180)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt64() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(UInt64.self, forKey: .integer)
            XCTAssertEqual(output, 17519567513307872255)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(UInt.self, forKey: .integer)
            XCTAssertEqual(output, 17519567513307872255)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt8() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(Int8.self, forKey: .integer)
            XCTAssertEqual(output, -13)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt16() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(Int16.self, forKey: .integer)
            XCTAssertEqual(output, -3294)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt32() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(Int32.self, forKey: .integer)
            XCTAssertEqual(output, -215875116)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt64() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(Int64.self, forKey: .integer)
            XCTAssertEqual(output, -927176560401679361)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt() {
        let container: KeyedDecodingContainer<IntCodingKeys> = keyedContainer(for: intData)
        do {
            let output = try container.decode(Int.self, forKey: .integer)
            XCTAssertEqual(output, -927176560401679361)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeFloat() {
        
        enum FloatCodingKeys: Int, RawRepresentable, CodingKey {
            case float = 0
        }
        
        let container: KeyedDecodingContainer<FloatCodingKeys> = keyedContainer(for: Data([0x40, 0x20, 0x00, 0x00]))
        do {
            let output = try container.decode(Float32.self, forKey: .float)
            XCTAssertEqual(output, 2.5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeDouble() {
        
        enum FloatCodingKeys: Int, RawRepresentable, CodingKey {
            case float = 0
        }
        
        let container: KeyedDecodingContainer<FloatCodingKeys> = keyedContainer(for: Data([0x40, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
        do {
            let output = try container.decode(Float64.self, forKey: .float)
            XCTAssertEqual(output, 8)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeNullTerminatedString() {
        
        enum StringCodingKeys: Int, RawRepresentable, CodingKey {
            case string = 0
        }
        
        let initialString = "MyString!"
        let bytes = initialString.utf8CString.map { UInt8($0) }
        let data = Data(bytes + bytes)
        
        let container: KeyedDecodingContainer<StringCodingKeys> = keyedContainer(for: data)
        do {
            let output = try container.decode(String.self, forKey: .string)
            XCTAssertEqual(output, initialString)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // MARK: - Test Special Decode Cases
    
    func testDecodeObject() {
        
        struct TestObject: Decodable {
            var int: UInt8
            var string: String
            var double: Double
            
            enum CodingKeys: Int, CodingKey {
                case int = 0
                case string = 1
                case double = 6
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.int = try container.decode(UInt8.self, forKey: .int)
                self.string = try container.decode(String.self, forKey: .string)
                self.double = try container.decode(Double.self, forKey: .double)
            }
            
        }
        
        enum ObjectCodingKeys: Int, CodingKey {
            case object = 0
        }
        
        let container: KeyedDecodingContainer<ObjectCodingKeys> = keyedContainer(for: Data([0xf3, 0x24, 0x56, 0x56, 0x57, 0x00, 0x40, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
        do {
            let output = try container.decode(TestObject.self, forKey: .object)
            XCTAssertEqual(output.int, 243)
            XCTAssertEqual(output.string, "$VVW")
            XCTAssertEqual(output.double, 8)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    
}

