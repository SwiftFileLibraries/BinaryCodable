//
//  File.swift
//  File
//
//  Created by Brandon McQuilkin on 8/25/21.
//

import Foundation

import XCTest
@testable import BinaryCodable

final class BinaryDecodingContainerTests: XCTestCase {
    
    let intData = Data([0xf3, 0x22, 0x01, 0xd4, 0xa9, 0x30, 0x7b, 0xff])
    
    func binaryContainer(for data: Data) -> BinaryDecodingContainer {
        BinaryDecoderImpl.BinaryContainer(
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
    
    func testKeyedContainer() {
        enum CodingKeys: CodingKey {
            case test
        }
        
        let decoder = binaryDecoder(for: intData)
        
        do {
            let _ = try decoder.container(keyedBy: CodingKeys.self)
            XCTFail("The decoded is expected to throw an error.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testUnkeyedContainer() {
        let decoder = binaryDecoder(for: intData)
        
        do {
            let _ = try decoder.unkeyedContainer()
            XCTFail("The decoded is expected to throw an error.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testSingleValueContainer() {
        let decoder = binaryDecoder(for: intData)
        
        do {
            let _ = try decoder.singleValueContainer()
            XCTFail("The decoded is expected to throw an error.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testBinaryContainer() {
        let decoder = binaryDecoder(for: intData)
        
        do {
            let container = try decoder.binaryContainer()
            XCTAssertNotNil(container)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    
    // MARK: - Test Decode
    
    func testIncrementIndex() {
        var container = binaryContainer(for: intData)
        do {
            try container.incrementIndex(by: 1)
            let output = try container.decode(UInt8.self)
            XCTAssertEqual(output, 34)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeBool() {
        var container = binaryContainer(for: Data([0x00, 0x01]))
        do {
            let falseOutput = try container.decode(Bool.self)
            let trueOutput = try container.decode(Bool.self)
            XCTAssertEqual(falseOutput, false)
            XCTAssertEqual(trueOutput, true)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt8() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(UInt8.self)
            XCTAssertEqual(output, 243)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt16() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(UInt16.self)
            XCTAssertEqual(output, 62242)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt32() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(UInt32.self)
            XCTAssertEqual(output, 4079092180)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeUInt64() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(UInt64.self)
            XCTAssertEqual(output, 17519567513307872255)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt8() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(Int8.self)
            XCTAssertEqual(output, -13)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt16() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(Int16.self)
            XCTAssertEqual(output, -3294)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt32() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(Int32.self)
            XCTAssertEqual(output, -215875116)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeInt64() {
        var container = binaryContainer(for: intData)
        do {
            let output = try container.decode(Int64.self)
            XCTAssertEqual(output, -927176560401679361)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeFloat() {
        var container = binaryContainer(for: Data([0x40, 0x20, 0x00, 0x00]))
        do {
            let output = try container.decode(Float32.self)
            XCTAssertEqual(output, 2.5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeDouble() {
        var container = binaryContainer(for: Data([0x40, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
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
        
        var container = binaryContainer(for: data)
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
        
        var container = binaryContainer(for: data)
        do {
            let output = try container.decode(String.self, length: 9)
            XCTAssertEqual(output, initialString)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodeObject() {
        
        struct TestObject: Decodable {
            var int: UInt8
            var string: String
            var double: Double
            
            init(from decoder: Decoder) throws {
                var container = try decoder.binaryContainer()
                self.int = try container.decode(UInt8.self)
                self.string = try container.decode(String.self, length: 4)
                self.double = try container.decode(Double.self)
            }
        }
        
        var container = binaryContainer(for: Data([0xf3, 0x24, 0x56, 0x56, 0x57, 0x40, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
        do {
            let output = try container.decode(TestObject.self)
            XCTAssertEqual(output.int, 243)
            XCTAssertEqual(output.string, "$VVW")
            XCTAssertEqual(output.double, 8)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
    
}
