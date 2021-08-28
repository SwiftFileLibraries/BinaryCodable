# BinaryCodable

An implementation of the `Decoder` protocol that can decode binary data. The goal of this library is to utilize Apple's existing `Codable` protocols and match the existing decoder implementations as closely as possible. 

## Features

- Decode swift types, structs, and classes from binary data.
- Supports little endian and big endian formats.
- Utilizes the existing `Decodable` protocols most projects already use.

## Usage

### Decoding Sequential Data

When decoding data where all the properties are stored in the binary data sequentially, just create an unkeyed container when decoding your object. The unkeyed container will decode all properties in order, managing the index to begin decoding each property/object from for you.

```swift
struct SomeObject: Decodable {

    var a: String
    var b: Int
    
    init(decoder: Decoder) {
        let container = try decoder.unkeyedContainer()
        self.a = try container.decode(String.self)
        self.b = try container.decode(Int.self)
    }
    
}

let decoder = BinaryDecoder()
let object = try decoder.decode(SomeObject.self, from: data)
```

### Decoding Non-Sequential Data

When decoding data where all the properties are stored in the binary data at arbitrary indices, just create an keyed container when decoding your object. The keyed container will allow you to specifiy what index to start at when decoding your property/object.

```swift
struct SomeObject: Decodable {

    var a: String
    var b: Int
    
    enum CodingKeys: Int, CodingKey {
        case a = 10
        case b = 147
    }
    
    init(decoder: Decoder) {
        let container = try decoder.keyedContainer()
        self.a = try container.decode(String.self, forKey: .a)
        self.b = try container.decode(Int.self, forKey: .b)
    }
    
}

let decoder = BinaryDecoder()
let object = try decoder.decode(SomeObject.self, from: data)
```

## Supported Platforms

- iOS 14+
- macOS 11+
- tvOS 14+,
- watchOS 7+
- Any other platform where `Foundation` is available.



 
