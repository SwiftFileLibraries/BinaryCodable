//
//  BinaryDecoderImpl+SingleValueContainerTests.swift
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

final class SingleValueContainerTests: XCTestCase {
    
    let intData = Data([0xf3, 0x22, 0x01, 0xd4, 0xa9, 0x30, 0x7b, 0xff])
    
    func singleValueContainer(for data: Data) -> SingleValueBinaryDecodingContainer {
        BinaryDecoderImpl.SingleValueContainter(
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
            parentIndexModifier: nil)
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
    
    func testSingleValueContainer() {
        let decoder = binaryDecoder(for: intData)
        
        do {
            let container = try decoder.singleValueContainer()
            XCTAssertNotNil(container)
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Test Decode
    
    func testIncrementIndex() {
        var container = singleValueContainer(for: intData)
        do {
            try container.incrementIndex(by: 1)
            let output = try container.decode(UInt8.self)
            XCTAssertEqual(output, 34)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeNil() {
        let container = singleValueContainer(for: Data([0x00, 0x01]))
        let trueOutput = container.decodeNil()
        let falseOutput = container.decodeNil()
        XCTAssertEqual(trueOutput, true)
        XCTAssertEqual(falseOutput, false)
    }
    
    func testDecodeBool() {
        let container = singleValueContainer(for: Data([0x00, 0x01, 0x02]))
        do {
            let falseOutput = try container.decode(Bool.self)
            let trueOutput = try container.decode(Bool.self)
            let incorrectOutput = try container.decode(Bool.self)
            XCTAssertEqual(falseOutput, false)
            XCTAssertEqual(trueOutput, true)
            XCTAssertEqual(incorrectOutput, false)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt8() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(UInt8.self)
            XCTAssertEqual(output, 243)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt16() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(UInt16.self)
            XCTAssertEqual(output, 62242)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt32() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(UInt32.self)
            XCTAssertEqual(output, 4079092180)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt64() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(UInt64.self)
            XCTAssertEqual(output, 17519567513307872255)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(UInt.self)
            XCTAssertEqual(output, 17519567513307872255)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt8() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(Int8.self)
            XCTAssertEqual(output, -13)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt16() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(Int16.self)
            XCTAssertEqual(output, -3294)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt32() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(Int32.self)
            XCTAssertEqual(output, -215875116)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt64() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(Int64.self)
            XCTAssertEqual(output, -927176560401679361)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt() {
        let container = singleValueContainer(for: intData)
        do {
            let output = try container.decode(Int.self)
            XCTAssertEqual(output, -927176560401679361)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeFloat() {
        let container = singleValueContainer(for: Data([0x40, 0x20, 0x00, 0x00]))
        do {
            let output = try container.decode(Float32.self)
            XCTAssertEqual(output, 2.5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeDouble() {
        let container = singleValueContainer(for: Data([0x40, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
        do {
            let output = try container.decode(Float64.self)
            XCTAssertEqual(output, 8)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeNullTerminatedString() {
        let initialString = "MyString!"
        let bytes = initialString.utf8CString.map { UInt8($0) }
        let data = Data(bytes + bytes)
        
        let container = singleValueContainer(for: data)
        do {
            let output = try container.decode(String.self)
            XCTAssertEqual(output, initialString)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeString() {
        let initialString = "MyString!"
        let bytes = initialString.utf8CString.map { UInt8($0) }
        let data = Data(bytes + bytes)
        
        var container = singleValueContainer(for: data)
        do {
            let output = try container.decode(String.self, length: 9)
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
            
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer() as! UnkeyedBinaryDecodingContainer
                self.int = try container.decode(UInt8.self)
                self.string = try container.decode(String.self, length: 4)
                self.double = try container.decode(Double.self)
            }
        }
        
        let container = singleValueContainer(for: Data([0xf3, 0x24, 0x56, 0x56, 0x57, 0x40, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
        do {
            let output = try container.decode(TestObject.self)
            XCTAssertEqual(output.int, 243)
            XCTAssertEqual(output.string, "$VVW")
            XCTAssertEqual(output.double, 8)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testDecodeData() {
        var container = singleValueContainer(for: Data([0x00, 0x01, 0x02, 0x03]))
        do {
            let output = try container.decode(Data.self, length: 2)
            XCTAssertEqual(output.count, 2)
            XCTAssertEqual(output.first, 0x00)
            XCTAssertEqual(output.last, 0x01)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testEnum() {
        
        enum TestEnum: UInt16, RawRepresentable, Decodable {
            case testCase = 0x14c
        }
        
        var container = singleValueContainer(for: Data([0x00, 0x01, 0x4c, 0x00]))
        do {
            try container.incrementIndex(by: 1)
            let output = try container.decode(TestEnum.self)
            XCTAssertEqual(output, .testCase)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    
}

