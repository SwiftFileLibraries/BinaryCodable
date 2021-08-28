//
//  Integer+Decoder.swift
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

extension FixedWidthInteger {
    
    fileprivate init<I>(littleEndianBytes iterator: inout I) where I: IteratorProtocol, I.Element == UInt8 {
        self = stride(from: 0, to: Self.bitWidth, by: 8).reduce(into: 0) {
            $0 |= Self(truncatingIfNeeded: iterator.next()!) &<< $1
        }
    }
    
    init<C>(littleEndianBytes bytes: C) where C: Collection, C.Element == UInt8 {
        precondition(bytes.count == (Self.bitWidth + 7) / 8)
        var iter = bytes.makeIterator()
        self.init(littleEndianBytes: &iter)
    }
    
    init<C>(bigEndianBytes bytes: C) where C: Collection, C.Element == UInt8 {
        precondition(bytes.count == (Self.bitWidth + 7) / 8)
        var iter = bytes.reversed().makeIterator()
        self.init(littleEndianBytes: &iter)
    }
    
}

func unsafeConversion<F, T>(_ from: F) -> T {
    
    func ptr(_ fromPtr: UnsafePointer<F>) -> UnsafePointer<T> {
        return fromPtr.withMemoryRebound(to: T.self, capacity: 1, {  return $0 })
    }
    
    var fromVar = from
    return ptr(&fromVar).pointee
    
}
