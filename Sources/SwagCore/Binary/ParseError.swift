//
//  ParseError.swift
//  SwagCore
//
//  Created by Jianing Wang on 2021/2/13.
//

import Foundation

public enum ParseError: Error {
    case invalidValType(_ byte: Byte)
    case invalidLimitsTag(_ byte: Byte)
    case stringEncodeError(_ bytes: [Byte])
    case invalidModule(_ message: String)
    case invalidImportTag(_ byte: Byte)
    case invalidExportTag(_ byte: Byte)
    case invalidCode(_ idx: Int)
    case invalidCodeTooManyLocals(_ count: UInt64)
    case invalidArgs(_ message: String)
    case invalidOpcode(_ byte: Byte)
    case invalidExprEnd(_ opcode: Opcode)
    case invalidMutType(_ byte: Byte)
    case invalidBasicBlockType(_ raw: BlockType)
    case unexpectedEnd
    case leb128IntTooLong
    case leb128IntTooLarge
    case leb128UnexpectedEnd
    
    public var description: String {
        switch self {
        case let .invalidValType(byte):
            return "Invalid ValType: \(byte.hex)"
        case let .invalidLimitsTag(byte):
            return "Invalid LimitsTag: \(byte.hex)"
        case .unexpectedEnd:
            return "unexpected end"
        case .leb128IntTooLong:
            return "LEB128 Decode Integer Error: int too long"
        case .leb128IntTooLarge:
            return "LEB128 Decode Integer Error: int too large"
        case .leb128UnexpectedEnd:
            return "LEB128 Decode Integer Error: unexpected end"
        case let .stringEncodeError(bytes):
            return "String Encode Error: \(bytes.hex)"
        case let .invalidModule(message):
            return "Invalid Module: \(message)"
        case let .invalidImportTag(byte):
            return "Invalid ImportTag: \(byte.hex)"
        case let .invalidExportTag(byte):
            return "Invalid ExportTag: \(byte.hex)"
        case let .invalidCode(idx):
            return "Invalid Code: idx: \(idx)"
        case let .invalidCodeTooManyLocals(count):
            return "Invalid Code: too many locals: \(count)"
        case let .invalidArgs(message):
            return "Invalid Args: \(message)"
        case let .invalidOpcode(byte):
            return "Invalid Opcode: \(byte.hex)"
        case let .invalidExprEnd(opcode):
            return "Invalid Expr end: \(opcode)"
        case let .invalidMutType(byte):
            return "Invalid MutType: \(byte.hex)"
        case let .invalidBasicBlockType(raw):
            return "Invalid BasicBlockType: \(raw)"
        }
    }
}
