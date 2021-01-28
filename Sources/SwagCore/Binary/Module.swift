//
//  Module.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/11/9.
//

import Foundation

// Index:
// Function signature, Function, Table, Memory and Global variable have their own index space in module.
// Local variable and Label have their own index space in function.
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
    func getBlockType(bt: BlockType) -> FuncType? {
        if let bbt = BaseBlockType(rawValue: bt) {
            switch bbt {
            case .i32:
                // TODO: tag FUNC_TYPE_TAG???
                return FuncType(tag: FUNC_TYPE_TAG, paramTypes: [], resultTypes: [BaseValType.i32.rawValue])
            case .i64:
                return FuncType(tag: FUNC_TYPE_TAG, paramTypes: [], resultTypes: [BaseValType.i64.rawValue])
            case .f32:
                return FuncType(tag: FUNC_TYPE_TAG, paramTypes: [], resultTypes: [BaseValType.f32.rawValue])
            case .f64:
                return FuncType(tag: FUNC_TYPE_TAG, paramTypes: [], resultTypes: [BaseValType.f64.rawValue])
            case .empty:
                return FuncType(tag: FUNC_TYPE_TAG, paramTypes: [], resultTypes: [])
            }
        } else {
            return self.typeSec?[Int(bt)]
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

// MARK: - CustomSec
public struct CustomSec {
    public var name: String
    public var bytes: [Byte]
}

// MARK: - Import
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
}

public struct ImportDesc {
    public var tag: ImportTag
    public var funcType: TypeIdx?
    public var table: TableType?
    public var mem: MemType?
    public var global: GlobalType?
}

// MARK: - Global
public struct Global {
    public var type: GlobalType
    public var `init`: Expr
}

// MARK: - Export
public struct Export {
    public var name: String
    public var desc: ExportDesc
}

public enum ExportTag: Byte {
    case `func` = 0
    case table
    case mem
    case global
}

public struct ExportDesc {
    public var tag: ExportTag
    public var idx: UInt32
}

// MARK: - Elem
public struct Elem {
    public var table: TableIdx
    public var offset: Expr
    public var `init`: [FuncIdx]
}

// MARK: - Code
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

// MARK: - Data
public struct Data {
    public var mem: MemIdx
    public var offset: Expr
    public var `init`: [Byte]
}

