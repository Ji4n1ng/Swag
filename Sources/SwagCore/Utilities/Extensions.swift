//
//  Extensions.swift
//  SwagCore
//
//  Created by Jianing Wang on 2021/2/13.
//

import Foundation

extension Array where Element == Byte {
    
    var hex: String {
        let hex = self.map { $0.hex }.joined(separator: ", ")
        return hex
    }
    
    /// bytes array to T
    func littleEndianValue<T>(_ T: T.Type) -> T {
        let littleEndianValue = self.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) { $0 })
        }.pointee
        return littleEndianValue
    }
    
}


// MARK: - LEB128

/// https://en.wikipedia.org/wiki/LEB128#Decode_unsigned_integer
func decodeVarUInt(data: [Byte], size: Int) throws -> (UInt64, Int) {
    var result = UInt64(0)
    for (i, b) in data.enumerated() {
        if i == size / 7 {
            // 1000 0000
            if b & 0x80 != 0 {
                throw ParseError.leb128IntTooLong
            }
            if b >> (size - i*7) > 0 {
                throw ParseError.leb128IntTooLarge
            }
        }
        result |= (UInt64(b) & 0x7f) << (i * 7)
        if b & 0x80 == 0 {
            return (result, i + 1)
        }
    }
    throw ParseError.leb128UnexpectedEnd
}

/// https://en.wikipedia.org/wiki/LEB128#Decode_signed_integer
func decodeVarInt(data: [Byte], size: Int) throws -> (Int64, Int) {
    var result = Int64(0)
    for (i, b) in data.enumerated() {
        if i == size / 7 {
            if b & 0x80 != 0 {
                throw ParseError.leb128IntTooLong
            }
            if (b & 0x40 == 0) && (b >> (size - i * 7 - 1) != 0) ||
                (b & 0x40 != 0) && (Int8(b | 0x80) >> (size - i * 7 - 1) != -1) {
                throw ParseError.leb128IntTooLarge
            }
        }
        result |= (Int64(b) & 0x7f) << (i * 7)
        if b & 0x80 == 0 {
            if (i * 7 < size) && (b & 0x40 != 0) {
                result = result | (-1 << ((i + 1) * 7))
            }
            return (result, i + 1)
        }
    }
    throw ParseError.leb128UnexpectedEnd
}
