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

// MARK: - ValType
public typealias ValType = Byte

/// 4 basic valtypes
public enum BaseValType: ValType {
    case i32 = 0x7F
    case i64 = 0x7E
    case f32 = 0x7D
    case f64 = 0x7C
}

extension BaseValType: CustomStringConvertible {
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

public extension ValType {
    var description: String {
        if let baseValType = BaseValType(rawValue: self) {
            return baseValType.description
        } else {
            return "invalid valType: \(self.hex)"
        }
    }
}

public typealias MemType = Limits

// MARK: - Limits
public struct Limits {
    public var tag: LimitsTag
    public var min: UInt32
    public var max: UInt32?
}

public enum LimitsTag: Byte {
    case min = 0
    case minMax = 1
}

//extension Limits: CustomStringConvertible {
//    public var description: String {
//        return "{min: \(self.min.hex), mut: \(self.max.hex)}"
//    }
//}

// MARK: - FuncType
public struct FuncType {
    public var tag: Byte
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

// MARK: - TableType
public struct TableType {
    /// currently this can only be 0x70
    public var elemType: Byte
    public var limits: Limits
}

// MARK: - GlobalType
public struct GlobalType {
    public var valType: ValType
    public var mut: MutType
}

public enum MutType: Byte {
    case const = 0
    case `var` = 1
}

extension GlobalType: CustomStringConvertible {
    public var description: String {
        return "{type: \(self.valType.description), mut: \(self.mut)}"
    }
}
