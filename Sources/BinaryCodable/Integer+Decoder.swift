//
//  File.swift
//  File
//
//  Created by Brandon McQuilkin on 8/25/21.
//

import Foundation

func unsafeConversion<F, T>(_ from: F) -> T {
    
  func ptr(_ fromPtr: UnsafePointer<F>) -> UnsafePointer<T> {
    return fromPtr.withMemoryRebound(to: T.self, capacity: 1, {  return $0 })
  }
    
  var fromVar = from
  return ptr(&fromVar).pointee
}


fileprivate func orderBytes<T>(_ tuple: (T, T), _ bigEndian: Bool) -> (T, T) {
  return bigEndian ? (tuple.1, tuple.0) : tuple
}

fileprivate func orderBytes<T>(_ tuple: (T, T, T, T), _ bigEndian: Bool) -> (T, T, T, T) {
  return bigEndian ? (tuple.3, tuple.2, tuple.1, tuple.0) : tuple
}

fileprivate func orderBytes<T>(_ tuple: (T, T, T, T, T, T, T, T), _ bigEndian: Bool) -> (T, T, T, T, T, T, T, T) {
  return bigEndian ? (tuple.7, tuple.6, tuple.5, tuple.4, tuple.3, tuple.2, tuple.1, tuple.0) : tuple
}

extension UInt16 {
    
    init(from bytes: (UInt8, UInt8), bigEndian: Bool) {
        let parts = orderBytes((UInt16(bytes.0), UInt16(bytes.1)), bigEndian)
        self = (UInt16(parts.1) << 8) | UInt16(parts.0)
    }
    
}

extension UInt32 {
    
    init(from bytes: (UInt8, UInt8, UInt8, UInt8), bigEndian: Bool) {
        let parts = orderBytes((UInt32(bytes.0), UInt32(bytes.1), UInt32(bytes.2), UInt32(bytes.3)), bigEndian)
        self = (parts.3 << 24) | (parts.2 << 16) | (parts.1 << 8) | parts.0
    }
    
}

extension UInt64 {
    
    init(from bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8), bigEndian: Bool) {
        let parts = orderBytes((UInt64(bytes.0), UInt64(bytes.1), UInt64(bytes.2), UInt64(bytes.3), UInt64(bytes.4), UInt64(bytes.5), UInt64(bytes.6), UInt64(bytes.7)), bigEndian)
        self = (parts.7 << 56) | (parts.6 << 48) | (parts.5 << 40) | (parts.4 << 32) | (parts.3 << 24) | (parts.2 << 16) | (parts.1 << 8) | parts.0
    }
    
}
