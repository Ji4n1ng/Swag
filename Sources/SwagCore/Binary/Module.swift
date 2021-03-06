//
//  Module.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/11/9.
//

import Foundation

public typealias TypeIdx = UInt32
public typealias FuncIdx = UInt32
public typealias TableIdx = UInt32
public typealias MemIdx = UInt32
public typealias GlobalIdx = UInt32
public typealias LocalIdx = UInt32
public typealias LabelIdx = UInt32

// MARK: - Module

public struct Module {
    public var magic: UInt32
    public var version: UInt32
    public var customSecs: [CustomSec]?
    public var typeSec: [FuncType]?
    public var importSec: [Import]?
    public var funcSec: [TypeIdx]?
    public var tableSec: [TableType]?
    public var memSec: [MemType]?
    public var globalSec: [Global]?
    public var exportSec: [Export]?
    public var startSec: FuncIdx?
    public var elemSec: [Elem]?
    public var codeSec: [Code]?
    public var dataSec: [Data]?
}

public extension Module {
    func getFuncType(bt: BlockType) -> FuncType {
        if let bbt = BasicBlockType(rawValue: bt) {
            switch bbt {
            case .i32:
                return FuncType(paramTypes: [], resultTypes: [ValType.i32])
            case .i64:
                return FuncType(paramTypes: [], resultTypes: [ValType.i64])
            case .f32:
                return FuncType(paramTypes: [], resultTypes: [ValType.f32])
            case .f64:
                return FuncType(paramTypes: [], resultTypes: [ValType.f64])
            case .empty:
                return FuncType(paramTypes: [], resultTypes: [])
            }
        } else {
            if let type = self.typeSec?[Int(bt)] {
                return type
            } else {
                fatalError()
            }
        }
    }
}

/// `\0asm`
public let MAGIC_NUMBER: UInt32 = 0x6D736100
/// 1
public let VERSION: UInt32 = 0x00000001

public let PAGE_SIZE = 65536
public let MAX_PAGE_COUNT = 65536

public enum SectionID: Byte {
    case custom = 0
    case type
    case `import`
    case `func`
    case table
    case mem
    case global
    case export
    case start
    case elem
    case code
    case data
}

// MARK: - Custom Section

public struct CustomSec {
    public var name: String
    public var bytes: [Byte]
}

// MARK: - Import Section

public struct Import {
    /// module name
    public var module: String
    /// member name
    public var name: String
    /// import desc
    public var desc: ImportDesc
}

public enum ImportTag: Byte {
    case `func` = 0
    case table
    case mem
    case global
    
    init(_ byte: Byte) throws {
        if let tag = ImportTag(rawValue: byte) {
            self = tag
        } else {
            throw ParseError.invalidImportTag(byte)
        }
    }
}

public struct ImportDesc {
    public var tag: ImportTag
    public var funcType: TypeIdx?
    public var table: TableType?
    public var mem: MemType?
    public var global: GlobalType?
}

// MARK: - Global Section

public struct Global {
    public var type: GlobalType
    public var `init`: Expr
}

// MARK: - Export Section

public struct Export {
    public var name: String
    public var desc: ExportDesc
}

public enum ExportTag: Byte {
    case `func` = 0
    case table
    case mem
    case global
    
    init(_ byte: Byte) throws {
        if let tag = ExportTag(rawValue: byte) {
            self = tag
        } else {
            throw ParseError.invalidExportTag(byte)
        }
    }
}

public struct ExportDesc {
    public var tag: ExportTag
    public var idx: UInt32
}

// MARK: - Elem Section

public struct Elem {
    public var table: TableIdx
    public var offset: Expr
    public var `init`: [FuncIdx]
}

// MARK: - Code Section

public struct Code {
    public var locals: [Locals]
    public var expr: Expr
}

public struct Locals {
    public var n: UInt32
    public var type: ValType
}

extension Code {
    public func getLocalCount() -> UInt64 {
        var n: UInt64 = 0
        for (_, locals) in self.locals.enumerated() {
            n += UInt64(locals.n)
        }
        return n
    }
}

// MARK: - Data Section

public struct Data {
    public var mem: MemIdx
    public var offset: Expr
    public var `init`: [Byte]
}

