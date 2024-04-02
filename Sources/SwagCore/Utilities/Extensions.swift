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
public func decodeVarUInt(data: [Byte], size: Int) throws -> (UInt64, Int) {
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
public func decodeVarInt(data: [Byte], size: Int) throws -> (Int64, Int) {
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

public func encodeVarUInt(_ value: UInt64) -> [Byte] {
    var value = value
    var bytes: [Byte] = []
    repeat {
        var byte = Byte(value & 0x7f) // Extract the 7 least significant bits
        value >>= 7
        if value != 0 { // If more bytes to encode, set continuation bit
            byte |= 0x80
        }
        bytes.append(byte)
    } while value != 0
    return bytes
}

public func encodeVarUInt(_ value: UInt32) -> [Byte] {
    return encodeVarUInt(UInt64(value))
}

public func encodeVarInt(_ value: Int64) -> [Byte] {
    var value = value
    var bytes: [Byte] = []
    var more = true
    while more {
        var byte = Byte(value & 0x7f) // Extract the 7 least significant bits
        value >>= 7
        // Determine if more bytes are needed
        more = !(((value == 0) && ((byte & 0x40) == 0)) || ((value == -1) && ((byte & 0x40) != 0)))
        if more {
            byte |= 0x80 // Set continuation bit if more bytes are to follow
        }
        bytes.append(byte)
    }
    return bytes
}

public func encodeVarInt(_ value: Int32) -> [Byte] {
    return encodeVarInt(Int64(value))
}
