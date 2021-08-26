//
//  File.swift
//  File
//
//  Created by Brandon McQuilkin on 8/25/21.
//

extension Decoder {
    
    public func binaryContainer() throws -> BinaryDecodingContainer {
        if let self = self as? BinaryDecoderImpl {
            return BinaryDecoderImpl.BinaryContainer(impl: self, codingPath: codingPath, data: self.data, parentIndexModifier: self.parentIndexModifier)
        }
        
        throw DecodingError.typeMismatch(BinaryDecodingContainer.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Binary containers are not available for use with this decoder.", underlyingError: nil))
    }
    
}
