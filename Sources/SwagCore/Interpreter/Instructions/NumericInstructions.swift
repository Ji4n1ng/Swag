//
//  NumericInstructions.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/20.
//

import Foundation

extension VM {
    
    // MARK: - Numeric Instructions
    
    // const
    func i32Const(_ arg: Int32) {
        operandStack.pushS32(arg)
    }
    func i64Const(_ arg: Int64) {
        operandStack.pushS64(arg)
    }
    func f32Const(_ arg: Float32) {
        operandStack.pushF32(arg)
    }
    func f64Const(_ arg: Float64) {
        operandStack.pushF64(arg)
    }
    
    // i32 test
    func i32Eqz() {
        let val = operandStack.popU32() == 0
        operandStack.pushBool(val)
    }
    func i32Eq() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushBool(v1 == v2)
    }
    func i32Ne() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushBool(v1 != v2)
    }
    func i32LtS() {
        let v2 = operandStack.popS32()
        let v1 = operandStack.popS32()
        operandStack.pushBool(v1 < v2)
    }
    func i32LtU() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushBool(v1 < v2)
    }
    func i32GtS() {
        let v2 = operandStack.popS32()
        let v1 = operandStack.popS32()
        operandStack.pushBool(v1 > v2)
    }
    func i32GtU() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushBool(v1 > v2)
    }
    func i32LeS() {
        let v2 = operandStack.popS32()
        let v1 = operandStack.popS32()
        operandStack.pushBool(v1 <= v2)
    }
    func i32LeU() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushBool(v1 <= v2)
    }
    func i32GeS() {
        let v2 = operandStack.popS32()
        let v1 = operandStack.popS32()
        operandStack.pushBool(v1 >= v2)
    }
    func i32GeU() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushBool(v1 >= v2)
    }
    
    // i64
    func i64Eqz() {
        let val = operandStack.popU64() == 0
        operandStack.pushBool(val)
    }
    func i64Eq() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushBool(v1 == v2)
    }
    func i64Ne() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushBool(v1 != v2)
    }
    func i64LtS() {
        let v2 = operandStack.popS64()
        let v1 = operandStack.popS64()
        operandStack.pushBool(v1 < v2)
    }
    func i64LtU() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushBool(v1 < v2)
    }
    func i64GtS() {
        let v2 = operandStack.popS64()
        let v1 = operandStack.popS64()
        operandStack.pushBool(v1 > v2)
    }
    func i64GtU() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushBool(v1 > v2)
    }
    func i64LeS() {
        let v2 = operandStack.popS64()
        let v1 = operandStack.popS64()
        operandStack.pushBool(v1 <= v2)
    }
    func i64LeU() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushBool(v1 <= v2)
    }
    func i64GeS() {
        let v2 = operandStack.popS64()
        let v1 = operandStack.popS64()
        operandStack.pushBool(v1 >= v2)
    }
    func i64GeU() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushBool(v1 >= v2)
    }
    
    // f32
    func f32Eq() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushBool(v1 == v2)
    }
    func f32Ne() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushBool(v1 != v2)
    }
    func f32Lt() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushBool(v1 < v2)
    }
    func f32Gt() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushBool(v1 > v2)
    }
    func f32Le() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushBool(v1 <= v2)
    }
    func f32Ge() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushBool(v1 >= v2)
    }
    
    // f64
    func f64Eq() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushBool(v1 == v2)
    }
    func f64Ne() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushBool(v1 != v2)
    }
    func f64Lt() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushBool(v1 < v2)
    }
    func f64Gt() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushBool(v1 > v2)
    }
    func f64Le() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushBool(v1 <= v2)
    }
    func f64Ge() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushBool(v1 >= v2)
    }
    
    // i32 arithmetic & bitwise
    /// Count Leading Zeros
    func i32Clz() {
        let val = operandStack.popU32()
        let count = val.leadingZeroBitCount
        operandStack.pushU32(UInt32(count))
    }
    /// Count Trailing Zeros
    func i32Ctz() {
        let val = operandStack.popU32()
        let count = val.trailingZeroBitCount
        operandStack.pushU32(UInt32(count))
    }
    /// Population Count
    func i32PopCnt() {
        let val = operandStack.popU32()
        let count = val.nonzeroBitCount
        operandStack.pushU32(UInt32(count))
    }
    func i32Add() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 + v2)
    }
    func i32Sub() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 - v2)
    }
    func i32Mul() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 * v2)
    }
    func i32DivS() {
        let v2 = operandStack.popS32()
        let v1 = operandStack.popS32()
        if v1 == .min && v2 == -1 {
            fatalError("IntOverflow")
        }
        operandStack.pushS32(v1 / v2)
    }
    func i32DivU() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 / v2)
    }
    func i32RemS() {
        let v2 = operandStack.popS32()
        let v1 = operandStack.popS32()
        operandStack.pushS32(v1 % v2)
    }
    func i32RemU() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 % v2)
    }
    func i32And() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 & v2)
    }
    func i32Or() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 | v2)
    }
    func i32Xor() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 ^ v2)
    }
    func i32Shl() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 << (v2 % 32))
    }
    func i32ShrS() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popS32()
        operandStack.pushS32(v1 >> (v2 % 32))
    }
    func i32ShrU() {
        let v2 = operandStack.popU32()
        let v1 = operandStack.popU32()
        operandStack.pushU32(v1 >> (v2 % 32))
    }
    /// bitwise rotate left
    /// [stackoverflow](https://stackoverflow.com/questions/10134805/bitwise-rotate-left-function)
    func i32Rotl() {
        let shift = operandStack.popU32()
        let value = operandStack.popU32()
        let result = (value << shift) | (value >> (32 - shift))
        operandStack.pushU32(result)
    }
    /// bitwise rotate right
    /// [stackoverflow](https://stackoverflow.com/questions/10134805/bitwise-rotate-left-function)
    func i32Rotr() {
        let shift = operandStack.popU32()
        let value = operandStack.popU32()
        let result = (value >> shift) | (value << (32 - shift))
        operandStack.pushU32(result)
    }
    
    // i64 arithmetic & bitwise
    /// Count Leading Zeros
    func i64Clz() {
        let val = operandStack.popU64()
        let count = val.leadingZeroBitCount
        operandStack.pushU64(UInt64(count))
    }
    /// Count Trailing Zeros
    func i64Ctz() {
        let val = operandStack.popU64()
        let count = val.trailingZeroBitCount
        operandStack.pushU64(UInt64(count))
    }
    /// Population Count
    func i64PopCnt() {
        let val = operandStack.popU64()
        let count = val.nonzeroBitCount
        operandStack.pushU64(UInt64(count))
    }
    func i64Add() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 + v2)
    }
    func i64Sub() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 - v2)
    }
    func i64Mul() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 * v2)
    }
    func i64DivS() {
        let v2 = operandStack.popS64()
        let v1 = operandStack.popS64()
        if v1 == .min && v2 == -1 {
            fatalError("IntOverflow")
        }
        operandStack.pushS64(v1 / v2)
    }
    func i64DivU() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 / v2)
    }
    func i64RemS() {
        let v2 = operandStack.popS64()
        let v1 = operandStack.popS64()
        operandStack.pushS64(v1 % v2)
    }
    func i64RemU() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 % v2)
    }
    func i64And() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 & v2)
    }
    func i64Or() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 | v2)
    }
    func i64Xor() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 ^ v2)
    }
    func i64Shl() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 << (v2 % 64))
    }
    func i64ShrS() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popS64()
        operandStack.pushS64(v1 >> (v2 % 64))
    }
    func i64ShrU() {
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        operandStack.pushU64(v1 >> (v2 % 64))
    }
    /// bitwise rotate left
    /// [stackoverflow](https://stackoverflow.com/questions/10134805/bitwise-rotate-left-function)
    func i64Rotl() {
        let shift = operandStack.popU64()
        let value = operandStack.popU64()
        let result = (value << shift) | (value >> (64 - shift))
        operandStack.pushU64(result)
    }
    /// bitwise rotate right
    /// [stackoverflow](https://stackoverflow.com/questions/10134805/bitwise-rotate-left-function)
    func i64Rotr() {
        let shift = operandStack.popU64()
        let value = operandStack.popU64()
        let result = (value >> shift) | (value << (64 - shift))
        operandStack.pushU64(result)
    }
    
    // f32 arithmetic
    func f32Abs() {
        let value = operandStack.popF32()
        operandStack.pushF32(abs(value))
    }
    func f32Neg() {
        let value = operandStack.popF32()
        operandStack.pushF32(-value)
    }
    func f32Ceil() {
        let value = operandStack.popF32()
        operandStack.pushF32(ceil(value))
    }
    func f32Floor() {
        let value = operandStack.popF32()
        operandStack.pushF32(floor(value))
    }
    func f32Trunc() {
        let value = operandStack.popF32()
        operandStack.pushF32(trunc(value))
    }
    func f32Nearest() {
        let value = operandStack.popF32()
        operandStack.pushF32(round(value))
    }
    func f32Sqrt() {
        let value = operandStack.popF32()
        operandStack.pushF32(sqrt(value))
    }
    func f32Add() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushF32(v1 + v2)
    }
    func f32Sub() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushF32(v1 - v2)
    }
    func f32Mul() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushF32(v1 * v2)
    }
    func f32Div() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushF32(v1 / v2)
    }
    func f32Min() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        if v1.isNaN && !v2.isNaN {
            operandStack.pushF32(v1)
        } else if v2.isNaN && !v1.isNaN {
            operandStack.pushF32(v2)
        } else {
            operandStack.pushF32(min(v1, v2))
        }
    }
    func f32Max() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        if v1.isNaN && !v2.isNaN {
            operandStack.pushF32(v1)
        } else if v2.isNaN && !v1.isNaN {
            operandStack.pushF32(v2)
        } else {
            operandStack.pushF32(max(v1, v2))
        }
    }
    func f32CopySign() {
        let v2 = operandStack.popF32()
        let v1 = operandStack.popF32()
        operandStack.pushF32(copysign(v1, v2))
    }
    
    // f64 arithmetic
    func f64Abs() {
        let value = operandStack.popF64()
        operandStack.pushF64(abs(value))
    }
    func f64Neg() {
        let value = operandStack.popF64()
        operandStack.pushF64(-value)
    }
    func f64Ceil() {
        let value = operandStack.popF64()
        operandStack.pushF64(ceil(value))
    }
    func f64Floor() {
        let value = operandStack.popF64()
        operandStack.pushF64(floor(value))
    }
    func f64Trunc() {
        let value = operandStack.popF64()
        operandStack.pushF64(trunc(value))
    }
    func f64Nearest() {
        let value = operandStack.popF64()
        operandStack.pushF64(round(value))
    }
    func f64Sqrt() {
        let value = operandStack.popF64()
        operandStack.pushF64(sqrt(value))
    }
    func f64Add() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushF64(v1 + v2)
    }
    func f64Sub() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushF64(v1 - v2)
    }
    func f64Mul() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushF64(v1 * v2)
    }
    func f64Div() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushF64(v1 / v2)
    }
    func f64Min() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        if v1.isNaN && !v2.isNaN {
            operandStack.pushF64(v1)
        } else if v2.isNaN && !v1.isNaN {
            operandStack.pushF64(v2)
        } else {
            operandStack.pushF64(min(v1, v2))
        }
    }
    func f64Max() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        if v1.isNaN && !v2.isNaN {
            operandStack.pushF64(v1)
        } else if v2.isNaN && !v1.isNaN {
            operandStack.pushF64(v2)
        } else {
            operandStack.pushF64(max(v1, v2))
        }
    }
    func f64CopySign() {
        let v2 = operandStack.popF64()
        let v1 = operandStack.popF64()
        operandStack.pushF64(copysign(v1, v2))
    }
    
    // MARK: comversions
    /// 64 bits int to 32 bits
    func i32WrapI64() {
        let v = operandStack.popU64()
        let n = UInt32(truncatingIfNeeded: v)
        operandStack.pushU32(n)
    }
    func i32TruncF32S() {
        let v = trunc(operandStack.popF32())
        let n = Int32(v)
        if n > Int32.max || n < Int32.min {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushS32(n)
    }
    func i32TruncF32U() {
        let v = trunc(operandStack.popF32())
        let n = UInt32(v)
        if n > UInt32.max || v < 0 {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushU32(n)
    }
    func i32TruncF64S() {
        let v = trunc(operandStack.popF64())
        let n = Int32(v)
        if n > Int32.max || n < Int32.min {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushS32(n)
    }
    func i32TruncF64U() {
        let v = trunc(operandStack.popF64())
        let n = UInt32(v)
        if n > UInt32.max || v < 0 {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushU32(n)
    }
    func i64ExtendI32S() {
        let v = operandStack.popS32()
        operandStack.pushS64(Int64(v))
    }
    func i64ExtendI32U() {
        let v = operandStack.popU32()
        operandStack.pushU64(UInt64(v))
    }
    func i64TruncF32S() {
        let v = trunc(operandStack.popF32())
        let n = Int64(v)
        if n > Int64.max || n < Int64.min {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushS64(n)
    }
    func i64TruncF32U() {
        let v = trunc(operandStack.popF32())
        let n = UInt64(v)
        if n > UInt64.max || v < 0 {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushU64(n)
    }
    func i64TruncF64S() {
        let v = trunc(operandStack.popF64())
        let n = Int64(v)
        if n > Int64.max || n < Int64.min {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushS64(n)
    }
    func i64TruncF64U() {
        let v = trunc(operandStack.popF64())
        let n = UInt64(v)
        if n > UInt64.max || v < 0 {
            fatalError("Int Overflow")
        }
        if v.isNaN {
            fatalError("Error when convert to int")
        }
        operandStack.pushU64(n)
    }
    func f32ConvertI32S() {
        let v = operandStack.popS32()
        operandStack.pushF32(Float32(v))
    }
    func f32ConvertI32U() {
        let v = operandStack.popU32()
        operandStack.pushF32(Float32(v))
    }
    func f32ConvertI64S() {
        let v = operandStack.popS64()
        operandStack.pushF32(Float32(v))
    }
    func f32ConvertI64U() {
        let v = operandStack.popU64()
        operandStack.pushF32(Float32(v))
    }
    func f32DemoteF64() {
        let v = operandStack.popF64()
        operandStack.pushF32(Float32(v))
    }
    func f64ConvertI32S() {
        let v = operandStack.popS32()
        operandStack.pushF64(Float64(v))
    }
    func f64ConvertI32U() {
        let v = operandStack.popU32()
        operandStack.pushF64(Float64(v))
    }
    func f64ConvertI64S() {
        let v = operandStack.popS64()
        operandStack.pushF64(Float64(v))
    }
    func f64ConvertI64U() {
        let v = operandStack.popU64()
        operandStack.pushF64(Float64(v))
    }
    func f64PromoteF32() {
        let v = operandStack.popF32()
        operandStack.pushF64(Float64(v))
    }
    func i32ReinterpretF32() {
        
    }
    func i64ReinterpretF64() {
        
    }
    func f32ReinterpretI32() {
        
    }
    func f64ReinterpretI64() {
        
    }
    
    func i32Extend8S() {
        let v = operandStack.popS32()
        let n = Int32(Int8(truncatingIfNeeded: v))
        operandStack.pushS32(n)
    }
    func i32Extend16S() {
        let v = operandStack.popS32()
        let n = Int32(Int16(truncatingIfNeeded: v))
        operandStack.pushS32(n)
    }
    func i64Extend8S() {
        let v = operandStack.popS64()
        let n = Int64(Int8(truncatingIfNeeded: v))
        operandStack.pushS64(n)
    }
    func i64Extend16S() {
        let v = operandStack.popS64()
        let n = Int64(Int16(truncatingIfNeeded: v))
        operandStack.pushS64(n)
    }
    func i64Extend32S() {
        let v = operandStack.popS64()
        let n = Int64(Int32(truncatingIfNeeded: v))
        operandStack.pushS64(n)
    }
    
//    func truncSat(_ arg: Byte) {
//        switch arg {
//        case 0:
//            let v =
//        }
//    }
//
//    func truncSatU(z: Float64, n: Int) -> UInt64 {
//        guard !z.isNaN else { return 0 }
//        guard !z.isInfinite else { return 0 }
//        let max = (1 << n) - 1
//
//    }
}
