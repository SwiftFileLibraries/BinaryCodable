//
//  Integer+DecoderTests.swift
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

final class IntegerDecoderTests: XCTestCase {
    
    func testLittleEndianUInt8() {
        let data: [UInt8] = [0x32]
        let integer = UInt8(littleEndianBytes: data)
        XCTAssertEqual(integer, 50)
    }
    
    func testBigEndianUInt8() {
        let data: [UInt8] = [0x32]
        let integer = UInt8(bigEndianBytes: data)
        XCTAssertEqual(integer, 50)
    }
    
    func testLittleEndianUInt16() {
        let data: [UInt8] = [0x32, 0xe6]
        let integer = UInt16(littleEndianBytes: data)
        XCTAssertEqual(integer, 58930)
    }
    
    func testBigEndianUInt16() {
        let data: [UInt8] = [0x32, 0xe6]
        let integer = UInt16(bigEndianBytes: data)
        XCTAssertEqual(integer, 13030)
    }
    
    func testLittleEndianUInt32() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff]
        let integer = UInt32(littleEndianBytes: data)
        XCTAssertEqual(integer, 4278249010)
    }
    
    func testBigEndianUInt32() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff]
        let integer = UInt32(bigEndianBytes: data)
        XCTAssertEqual(integer, 853934335)
    }
    
    func testLittleEndianUInt64() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = UInt64(littleEndianBytes: data)
        XCTAssertEqual(integer, 13205138467798967858)
    }
    
    func testBigEndianUInt64() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = UInt64(bigEndianBytes: data)
        XCTAssertEqual(integer, 3667620043771036343)
    }
    
    func testLittleEndianUInt() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = UInt(littleEndianBytes: data)
        XCTAssertEqual(integer, 13205138467798967858)
    }
    
    func testBigEndianUInt() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = UInt(bigEndianBytes: data)
        XCTAssertEqual(integer, 3667620043771036343)
    }
    
    func testLittleEndianInt8() {
        let data: [UInt8] = [0x32]
        let integer = Int8(littleEndianBytes: data)
        XCTAssertEqual(integer, 50)
    }
    
    func testBigEndianInt8() {
        let data: [UInt8] = [0x32]
        let integer = Int8(bigEndianBytes: data)
        XCTAssertEqual(integer, 50)
    }
    
    func testLittleEndianInt16() {
        let data: [UInt8] = [0x32, 0xe6]
        let integer = Int16(littleEndianBytes: data)
        XCTAssertEqual(integer, -6606)
    }
    
    func testBigEndianInt16() {
        let data: [UInt8] = [0x32, 0xe6]
        let integer = Int16(bigEndianBytes: data)
        XCTAssertEqual(integer, 13030)
    }
    
    func testLittleEndianInt32() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff]
        let integer = Int32(littleEndianBytes: data)
        XCTAssertEqual(integer, -16718286)
    }
    
    func testBigEndianInt32() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff]
        let integer = Int32(bigEndianBytes: data)
        XCTAssertEqual(integer, 853934335)
    }
    
    func testLittleEndianInt64() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = Int64(littleEndianBytes: data)
        XCTAssertEqual(integer, -5241605605910583758)
    }
    
    func testBigEndianInt64() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = Int64(bigEndianBytes: data)
        XCTAssertEqual(integer, 3667620043771036343)
    }
    
    func testLittleEndianInt() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = Int(littleEndianBytes: data)
        XCTAssertEqual(integer, -5241605605910583758)
    }
    
    func testBigEndianInt() {
        let data: [UInt8] = [0x32, 0xe6, 0x00, 0xff, 0x78, 0x13, 0x42, 0xb7]
        let integer = Int(bigEndianBytes: data)
        XCTAssertEqual(integer, 3667620043771036343)
    }
    
    func testLittleEndianFloat() {
        let data: [UInt8] = [0x00, 0x00, 0xc0, 0x3f]
        let integer = UInt32(littleEndianBytes: data)
        let float: Float = unsafeConversion(integer)
        XCTAssertEqual(float, Float(1.5))
    }
    
    func testBigEndianFloat() {
        let data: [UInt8] = [0x3f, 0xc0, 0x00, 0x00]
        let integer = UInt32(bigEndianBytes: data)
        let float: Float = unsafeConversion(integer)
        XCTAssertEqual(float, Float(1.5))
    }
    
    func testLitleEndianDouble() {
        let data: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xc0]
        let integer = UInt64(littleEndianBytes: data)
        let float: Double = unsafeConversion(integer)
        XCTAssertEqual(float, Double(-3))
    }
    
    func testBigEndianDouble() {
        let data: [UInt8] = [0xc0, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        let integer = UInt64(bigEndianBytes: data)
        let float: Double = unsafeConversion(integer)
        XCTAssertEqual(float, Double(-3))
    }
    
}
