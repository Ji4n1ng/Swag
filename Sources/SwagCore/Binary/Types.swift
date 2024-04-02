//
//  Types.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/11/9.
//

import Foundation

// MARK: - Byte

public typealias Byte = UInt8

public extension Byte {
    var hex: String {
        return String(format: "%02X", self)
    }
}

// MARK: - Value Types

/// *Value types* classify the individual values that WebAssembly
/// code can compute with and the values that a variable accepts.
public enum ValType: Byte {
    case i32 = 0x7F
    case i64 = 0x7E
    case f32 = 0x7D
    case f64 = 0x7C
    
    public init(_ byte: Byte) throws {
        if let vt = ValType(rawValue: byte) {
            self = vt
        } else {
            throw ParseError.invalidValType(byte)
        }
    }
}

extension ValType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .i32:
            return "i32"
        case .i64:
            return "i64"
        case .f32:
            return "f32"
        case .f64:
            return "f64"
        }
    }
}

// MARK: - FuncType

/// *Function types* classify the signature of functions,
/// mapping a vector of parameters to a vector of results.
/// They are also used to classify the inputs and outputs
/// of instructions.
public struct FuncType {
    public var paramTypes: [ValType]
    public var resultTypes: [ValType]
}

public let FUNC_TYPE_TAG: Byte = 0x60
public let FUNC_REF: Byte = 0x70

extension FuncType: Equatable {
    public static func == (lhs: FuncType, rhs: FuncType) -> Bool {
        guard lhs.paramTypes.count == rhs.paramTypes.count &&
                lhs.resultTypes.count == rhs.resultTypes.count else {
            return false
        }
        for (i, vt) in lhs.paramTypes.enumerated() {
            if vt != rhs.paramTypes[i] {
                return false
            }
        }
        for (i, vt) in lhs.resultTypes.enumerated() {
            if vt != rhs.resultTypes[i] {
                return false
            }
        }
        return true
    }
}

public extension FuncType {
    func signature() -> String {
        var sig = "("
        for (i, vt) in self.paramTypes.enumerated() {
            if i > 0 {
                sig += ","
            }
            sig += vt.description
        }
        sig += ")->("
        for (i, vt) in self.resultTypes.enumerated() {
            if i > 0 {
                sig += ","
            }
            sig += vt.description
        }
        sig += ")"
        return sig
    }
}

extension FuncType: CustomStringConvertible {
    public var description: String {
        return self.signature()
    }
}

// MARK: - Limits

/// *Limits* classify the size range of resizeable storage
/// associated with memory types and table types.
/// If no maximum is given, the respective storage can
/// grow to any size.
public struct Limits {
    public var tag: LimitsTag
    public var min: UInt32
    public var max: UInt32?
    
    public init(tag: LimitsTag, min: UInt32, max: UInt32? = nil) {
        self.tag = tag
        self.min = min
        self.max = max
    }
}

extension Limits: CustomStringConvertible {
    public var description: String {
        switch self.tag {
        case .min:
            return "{min: \(self.min)}"
        case .minMax:
            if let max = self.max {
                return "{min: \(self.min), max: \(max)}"
            } else {
                return "{min: \(self.min), max: nil}"
            }
        }
    }
}

extension Limits: Equatable {
    public static func == (lhs: Limits, rhs: Limits) -> Bool {
        return lhs.tag == rhs.tag && lhs.min == rhs.min && lhs.max == rhs.max
    }
}

public enum LimitsTag: Byte {
    case min = 0
    case minMax = 1
    
    public init(_ byte: Byte) throws {
        if let lt = LimitsTag(rawValue: byte) {
            self = lt
        } else {
            throw ParseError.invalidValType(byte)
        }
    }
}

// MARK: - Memory Type

/// *Memory types* classify linear memories and their size range.
/// The limits constrain the minimum and optionally the maximum
/// size of a memory. The limits are given in units of page size.
public typealias MemType = Limits

// MARK: - TableType

/// *Table types* classify tables over elements of element types
/// within a size range.
public struct TableType {
    /// In future versions of WebAssembly, additional element
    /// types may be introduced. Currently this can only be
    /// FUNC_REF (0x70)
    public var elemType: Byte
    /// Like memories, tables are constrained by limits for
    /// their minimum and optionally maximum size. The limits are
    /// given in numbers of entries.
    public var limits: Limits
    
    public init(elemType: Byte = FUNC_REF, limits: Limits) {
        self.elemType = elemType
        self.limits = limits
    }
}

// MARK: - GlobalType

/// *Global types* classify global variables, which hold a value
/// and can either be mutable or immutable.
public struct GlobalType {
    public var valType: ValType
    public var mut: MutType
}

extension GlobalType: CustomStringConvertible {
    public var description: String {
        return "{type: \(self.valType.description), mut: \(self.mut.description)}"
    }
}

/// mutable or immutable
public enum MutType: Byte {
    case const = 0
    case `var` = 1
    
    public init(_ byte: Byte) throws {
        if let mut = MutType(rawValue: byte) {
            self = mut
        } else {
            throw ParseError.invalidMutType(byte)
        }
    }
}

extension MutType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .const:
            return "const(immutable)"
        case .var:
            return "var(mutable)"
        }
    }
}
