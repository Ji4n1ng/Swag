//
//  Opcode.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/11/26.
//

import Foundation

public enum Opcode: Byte {
    // MARK: Control Instructions
    case unreachable       = 0x00 // unreachable
    case nop               = 0x01 // nop
    case block             = 0x02 // block rt in* end
    case loop              = 0x03 // loop rt in* end
    case `if`              = 0x04 // if rt in* else in* end
    case `else`            = 0x05 // else
    case end               = 0x0B // end
    case br                = 0x0C // br l
    case brIf              = 0x0D // br_if l
    case brTable           = 0x0E // br_table l* lN
    case `return`          = 0x0F // return
    case call              = 0x10 // call x
    case callIndirect      = 0x11 // call_indirect x
    
    // MARK: Parametric Instructions
    case drop              = 0x1A // drop
    case select            = 0x1B // select
    
    // MARK: Variable Instructions
    case localGet          = 0x20 // local.get x
    case localSet          = 0x21 // local.set x
    case localTee          = 0x22 // local.tee x
    case globalGet         = 0x23 // global.get x
    case globalSet         = 0x24 // global.set x
    
    // MARK: Memory Instructions
    case i32Load           = 0x28 // i32.load m
    case i64Load           = 0x29 // i64.load m
    case f32Load           = 0x2A // f32.load m
    case f64Load           = 0x2B // f64.load m
    case i32Load8S         = 0x2C // i32.load8_s m
    case i32Load8U         = 0x2D // i32.load8_u m
    case i32Load16S        = 0x2E // i32.load16_s m
    case i32Load16U        = 0x2F // i32.load16_u m
    case i64Load8S         = 0x30 // i64.load8_s m
    case i64Load8U         = 0x31 // i64.load8_u m
    case i64Load16S        = 0x32 // i64.load16_s m
    case i64Load16U        = 0x33 // i64.load16_u m
    case i64Load32S        = 0x34 // i64.load32_s m
    case i64Load32U        = 0x35 // i64.load32_u m
    case i32Store          = 0x36 // i32.store m
    case i64Store          = 0x37 // i64.store m
    case f32Store          = 0x38 // f32.store m
    case f64Store          = 0x39 // f64.store m
    case i32Store8         = 0x3A // i32.store8 m
    case i32Store16        = 0x3B // i32.store16 m
    case i64Store8         = 0x3C // i64.store8 m
    case i64Store16        = 0x3D // i64.store16 m
    case i64Store32        = 0x3E // i64.store32 m
    case memorySize        = 0x3F // memory.size
    case memoryGrow        = 0x40 // memory.grow
    
    // MARK: Numeric Instructions
    case i32Const          = 0x41 // i32.const n
    case i64Const          = 0x42 // i64.const n
    case f32Const          = 0x43 // f32.const z
    case f64Const          = 0x44 // f64.const z
    case i32Eqz            = 0x45 // i32.eqz
    case i32Eq             = 0x46 // i32.eq
    case i32Ne             = 0x47 // i32.ne
    case i32LtS            = 0x48 // i32.lt_s
    case i32LtU            = 0x49 // i32.lt_u
    case i32GtS            = 0x4A // i32.gt_s
    case i32GtU            = 0x4B // i32.gt_u
    case i32LeS            = 0x4C // i32.le_s
    case i32LeU            = 0x4D // i32.le_u
    case i32GeS            = 0x4E // i32.ge_s
    case i32GeU            = 0x4F // i32.ge_u
    case i64Eqz            = 0x50 // i64.eqz
    case i64Eq             = 0x51 // i64.eq
    case i64Ne             = 0x52 // i64.ne
    case i64LtS            = 0x53 // i64.lt_s
    case i64LtU            = 0x54 // i64.lt_u
    case i64GtS            = 0x55 // i64.gt_s
    case i64GtU            = 0x56 // i64.gt_u
    case i64LeS            = 0x57 // i64.le_s
    case i64LeU            = 0x58 // i64.le_u
    case i64GeS            = 0x59 // i64.ge_s
    case i64GeU            = 0x5A // i64.ge_u
    case f32Eq             = 0x5B // f32.eq
    case f32Ne             = 0x5C // f32.ne
    case f32Lt             = 0x5D // f32.lt
    case f32Gt             = 0x5E // f32.gt
    case f32Le             = 0x5F // f32.le
    case f32Ge             = 0x60 // f32.ge
    case f64Eq             = 0x61 // f64.eq
    case f64Ne             = 0x62 // f64.ne
    case f64Lt             = 0x63 // f64.lt
    case f64Gt             = 0x64 // f64.gt
    case f64Le             = 0x65 // f64.le
    case f64Ge             = 0x66 // f64.ge
    case i32Clz            = 0x67 // i32.clz
    case i32Ctz            = 0x68 // i32.ctz
    case i32PopCnt         = 0x69 // i32.popcnt
    case i32Add            = 0x6A // i32.add
    case i32Sub            = 0x6B // i32.sub
    case i32Mul            = 0x6C // i32.mul
    case i32DivS           = 0x6D // i32.div_s
    case i32DivU           = 0x6E // i32.div_u
    case i32RemS           = 0x6F // i32.rem_s
    case i32RemU           = 0x70 // i32.rem_u
    case i32And            = 0x71 // i32.and
    case i32Or             = 0x72 // i32.or
    case i32Xor            = 0x73 // i32.xor
    case i32Shl            = 0x74 // i32.shl
    case i32ShrS           = 0x75 // i32.shr_s
    case i32ShrU           = 0x76 // i32.shr_u
    case i32Rotl           = 0x77 // i32.rotl
    case i32Rotr           = 0x78 // i32.rotr
    case i64Clz            = 0x79 // i64.clz
    case i64Ctz            = 0x7A // i64.ctz
    case i64PopCnt         = 0x7B // i64.popcnt
    case i64Add            = 0x7C // i64.add
    case i64Sub            = 0x7D // i64.sub
    case i64Mul            = 0x7E // i64.mul
    case i64DivS           = 0x7F // i64.div_s
    case i64DivU           = 0x80 // i64.div_u
    case i64RemS           = 0x81 // i64.rem_s
    case i64RemU           = 0x82 // i64.rem_u
    case i64And            = 0x83 // i64.and
    case i64Or             = 0x84 // i64.or
    case i64Xor            = 0x85 // i64.xor
    case i64Shl            = 0x86 // i64.shl
    case i64ShrS           = 0x87 // i64.shr_s
    case i64ShrU           = 0x88 // i64.shr_u
    case i64Rotl           = 0x89 // i64.rotl
    case i64Rotr           = 0x8A // i64.rotr
    case f32Abs            = 0x8B // f32.abs
    case f32Neg            = 0x8C // f32.neg
    case f32Ceil           = 0x8D // f32.ceil
    case f32Floor          = 0x8E // f32.floor
    case f32Trunc          = 0x8F // f32.trunc
    case f32Nearest        = 0x90 // f32.nearest
    case f32Sqrt           = 0x91 // f32.sqrt
    case f32Add            = 0x92 // f32.add
    case f32Sub            = 0x93 // f32.sub
    case f32Mul            = 0x94 // f32.mul
    case f32Div            = 0x95 // f32.div
    case f32Min            = 0x96 // f32.min
    case f32Max            = 0x97 // f32.max
    case f32CopySign       = 0x98 // f32.copysign
    case f64Abs            = 0x99 // f64.abs
    case f64Neg            = 0x9A // f64.neg
    case f64Ceil           = 0x9B // f64.ceil
    case f64Floor          = 0x9C // f64.floor
    case f64Trunc          = 0x9D // f64.trunc
    case f64Nearest        = 0x9E // f64.nearest
    case f64Sqrt           = 0x9F // f64.sqrt
    case f64Add            = 0xA0 // f64.add
    case f64Sub            = 0xA1 // f64.sub
    case f64Mul            = 0xA2 // f64.mul
    case f64Div            = 0xA3 // f64.div
    case f64Min            = 0xA4 // f64.min
    case f64Max            = 0xA5 // f64.max
    case f64CopySign       = 0xA6 // f64.copysign
    case i32WrapI64        = 0xA7 // i32.wrap_i64
    case i32TruncF32S      = 0xA8 // i32.trunc_f32_s
    case i32TruncF32U      = 0xA9 // i32.trunc_f32_u
    case i32TruncF64S      = 0xAA // i32.trunc_f64_s
    case i32TruncF64U      = 0xAB // i32.trunc_f64_u
    case i64ExtendI32S     = 0xAC // i64.extend_i32_s
    case i64ExtendI32U     = 0xAD // i64.extend_i32_u
    case i64TruncF32S      = 0xAE // i64.trunc_f32_s
    case i64TruncF32U      = 0xAF // i64.trunc_f32_u
    case i64TruncF64S      = 0xB0 // i64.trunc_f64_s
    case i64TruncF64U      = 0xB1 // i64.trunc_f64_u
    case f32ConvertI32S    = 0xB2 // f32.convert_i32_s
    case f32ConvertI32U    = 0xB3 // f32.convert_i32_u
    case f32ConvertI64S    = 0xB4 // f32.convert_i64_s
    case f32ConvertI64U    = 0xB5 // f32.convert_i64_u
    case f32DemoteF64      = 0xB6 // f32.demote_f64
    case f64ConvertI32S    = 0xB7 // f64.convert_i32_s
    case f64ConvertI32U    = 0xB8 // f64.convert_i32_u
    case f64ConvertI64S    = 0xB9 // f64.convert_i64_s
    case f64ConvertI64U    = 0xBA // f64.convert_i64_u
    case f64PromoteF32     = 0xBB // f64.promote_f32
    case i32ReinterpretF32 = 0xBC // i32.reinterpret_f32
    case i64ReinterpretF64 = 0xBD // i64.reinterpret_f64
    case f32ReinterpretI32 = 0xBE // f32.reinterpret_i32
    case f64ReinterpretI64 = 0xBF // f64.reinterpret_i64
    case i32Extend8S       = 0xC0 // i32.extend8_s
    case i32Extend16S      = 0xC1 // i32.extend16_s
    case i64Extend8S       = 0xC2 // i64.extend8_s
    case i64Extend16S      = 0xC3 // i64.extend16_s
    case i64Extend32S      = 0xC4 // i64.extend32_s
    case truncSat          = 0xFC // <i32|64>.trunc_sat_<f32|64>_<s|u>
    
    init(_ byte: Byte) throws {
        if let opcode = Opcode(rawValue: byte) {
            self = opcode
        } else {
            throw ParseError.invalidOpcode(byte)
        }
    }
}

extension Opcode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unreachable: return "unreachable"
        case .nop: return "nop"
        case .block: return "block"
        case .loop: return "loop"
        case .if: return "if"
        case .else: return "else"
        case .end: return "end"
        case .br: return "br"
        case .brIf: return "br_if"
        case .brTable: return "br_table"
        case .return: return "return"
        case .call: return "call"
        case .callIndirect: return "call_indirect"
        case .drop: return "drop"
        case .select: return "select"
        case .localGet: return "local.get"
        case .localSet: return "local.set"
        case .localTee: return "local.tee"
        case .globalGet: return "global.get"
        case .globalSet: return "global.set"
        case .i32Load: return "i32.load"
        case .i64Load: return "i64.load"
        case .f32Load: return "f32.load"
        case .f64Load: return "f64.load"
        case .i32Load8S: return "i32.load8_s"
        case .i32Load8U: return "i32.load8_u"
        case .i32Load16S: return "i32.load16_s"
        case .i32Load16U: return "i32.load16_u"
        case .i64Load8S: return "i64.load8_s"
        case .i64Load8U: return "i64.load8_u"
        case .i64Load16S: return "i64.load16_s"
        case .i64Load16U: return "i64.load16_u"
        case .i64Load32S: return "i64.load32_s"
        case .i64Load32U: return "i64.load32_u"
        case .i32Store: return "i32.store"
        case .i64Store: return "i64.store"
        case .f32Store: return "f32.store"
        case .f64Store: return "f64.store"
        case .i32Store8: return "i32.store8"
        case .i32Store16: return "i32.store16"
        case .i64Store8: return "i64.store8"
        case .i64Store16: return "i64.store16"
        case .i64Store32: return "i64.store32"
        case .memorySize: return "memory.size"
        case .memoryGrow: return "memory.grow"
        case .i32Const: return "i32.const"
        case .i64Const: return "i64.const"
        case .f32Const: return "f32.const"
        case .f64Const: return "f64.const"
        case .i32Eqz: return "i32.eqz"
        case .i32Eq: return "i32.eq"
        case .i32Ne: return "i32.ne"
        case .i32LtS: return "i32.lt_s"
        case .i32LtU: return "i32.lt_u"
        case .i32GtS: return "i32.gt_s"
        case .i32GtU: return "i32.gt_u"
        case .i32LeS: return "i32.le_s"
        case .i32LeU: return "i32.le_u"
        case .i32GeS: return "i32.ge_s"
        case .i32GeU: return "i32.ge_u"
        case .i64Eqz: return "i64.eqz"
        case .i64Eq: return "i64.eq"
        case .i64Ne: return "i64.ne"
        case .i64LtS: return "i64.lt_s"
        case .i64LtU: return "i64.lt_u"
        case .i64GtS: return "i64.gt_s"
        case .i64GtU: return "i64.gt_u"
        case .i64LeS: return "i64.le_s"
        case .i64LeU: return "i64.le_u"
        case .i64GeS: return "i64.ge_s"
        case .i64GeU: return "i64.ge_u"
        case .f32Eq: return "f32.eq"
        case .f32Ne: return "f32.ne"
        case .f32Lt: return "f32.lt"
        case .f32Gt: return "f32.gt"
        case .f32Le: return "f32.le"
        case .f32Ge: return "f32.ge"
        case .f64Eq: return "f64.eq"
        case .f64Ne: return "f64.ne"
        case .f64Lt: return "f64.lt"
        case .f64Gt: return "f64.gt"
        case .f64Le: return "f64.le"
        case .f64Ge: return "f64.ge"
        case .i32Clz: return "i32.clz"
        case .i32Ctz: return "i32.ctz"
        case .i32PopCnt: return "i32.popcnt"
        case .i32Add: return "i32.add"
        case .i32Sub: return "i32.sub"
        case .i32Mul: return "i32.mul"
        case .i32DivS: return "i32.div_s"
        case .i32DivU: return "i32.div_u"
        case .i32RemS: return "i32.rem_s"
        case .i32RemU: return "i32.rem_u"
        case .i32And: return "i32.and"
        case .i32Or: return "i32.or"
        case .i32Xor: return "i32.xor"
        case .i32Shl: return "i32.shl"
        case .i32ShrS: return "i32.shr_s"
        case .i32ShrU: return "i32.shr_u"
        case .i32Rotl: return "i32.rotl"
        case .i32Rotr: return "i32.rotr"
        case .i64Clz: return "i64.clz"
        case .i64Ctz: return "i64.ctz"
        case .i64PopCnt: return "i64.popcnt"
        case .i64Add: return "i64.add"
        case .i64Sub: return "i64.sub"
        case .i64Mul: return "i64.mul"
        case .i64DivS: return "i64.div_s"
        case .i64DivU: return "i64.div_u"
        case .i64RemS: return "i64.rem_s"
        case .i64RemU: return "i64.rem_u"
        case .i64And: return "i64.and"
        case .i64Or: return "i64.or"
        case .i64Xor: return "i64.xor"
        case .i64Shl: return "i64.shl"
        case .i64ShrS: return "i64.shr_s"
        case .i64ShrU: return "i64.shr_u"
        case .i64Rotl: return "i64.rotl"
        case .i64Rotr: return "i64.rotr"
        case .f32Abs: return "f32.abs"
        case .f32Neg: return "f32.neg"
        case .f32Ceil: return "f32.ceil"
        case .f32Floor: return "f32.floor"
        case .f32Trunc: return "f32.trunc"
        case .f32Nearest: return "f32.nearest"
        case .f32Sqrt: return "f32.sqrt"
        case .f32Add: return "f32.add"
        case .f32Sub: return "f32.sub"
        case .f32Mul: return "f32.mul"
        case .f32Div: return "f32.div"
        case .f32Min: return "f32.min"
        case .f32Max: return "f32.max"
        case .f32CopySign: return "f32.copysign"
        case .f64Abs: return "f64.abs"
        case .f64Neg: return "f64.neg"
        case .f64Ceil: return "f64.ceil"
        case .f64Floor: return "f64.floor"
        case .f64Trunc: return "f64.trunc"
        case .f64Nearest: return "f64.nearest"
        case .f64Sqrt: return "f64.sqrt"
        case .f64Add: return "f64.add"
        case .f64Sub: return "f64.sub"
        case .f64Mul: return "f64.mul"
        case .f64Div: return "f64.div"
        case .f64Min: return "f64.min"
        case .f64Max: return "f64.max"
        case .f64CopySign: return "f64.copysign"
        case .i32WrapI64: return "i32.wrap_i64"
        case .i32TruncF32S: return "i32.trunc_f32_s"
        case .i32TruncF32U: return "i32.trunc_f32_u"
        case .i32TruncF64S: return "i32.trunc_f64_s"
        case .i32TruncF64U: return "i32.trunc_f64_u"
        case .i64ExtendI32S: return "i64.extend_i32_s"
        case .i64ExtendI32U: return "i64.extend_i32_u"
        case .i64TruncF32S: return "i64.trunc_f32_s"
        case .i64TruncF32U: return "i64.trunc_f32_u"
        case .i64TruncF64S: return "i64.trunc_f64_s"
        case .i64TruncF64U: return "i64.trunc_f64_u"
        case .f32ConvertI32S: return "f32.convert_i32_s"
        case .f32ConvertI32U: return "f32.convert_i32_u"
        case .f32ConvertI64S: return "f32.convert_i64_s"
        case .f32ConvertI64U: return "f32.convert_i64_u"
        case .f32DemoteF64: return "f32.demote_f64"
        case .f64ConvertI32S: return "f64.convert_i32_s"
        case .f64ConvertI32U: return "f64.convert_i32_u"
        case .f64ConvertI64S: return "f64.convert_i64_s"
        case .f64ConvertI64U: return "f64.convert_i64_u"
        case .f64PromoteF32: return "f64.promote_f32"
        case .i32ReinterpretF32: return "i32.reinterpret_f32"
        case .i64ReinterpretF64: return "i64.reinterpret_f64"
        case .f32ReinterpretI32: return "f32.reinterpret_i32"
        case .f64ReinterpretI64: return "f64.reinterpret_i64"
        case .i32Extend8S: return "i32.extend8_s"
        case .i32Extend16S: return "i32.extend16_s"
        case .i64Extend8S: return "i64.extend8_s"
        case .i64Extend16S: return "i64.extend16_s"
        case .i64Extend32S: return "i64.extend32_s"
        case .truncSat: return "trunc_sat"
        }
    }
}
