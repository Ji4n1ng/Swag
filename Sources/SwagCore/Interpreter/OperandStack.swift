//
//  OperandStack.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/12/25.
//

import Foundation

public struct OperandStack {
    private var slots = [UInt64]()
}

extension OperandStack {
    mutating func pushU64(_ val: UInt64) {
        slots.append(val)
    }
    mutating func popU64() -> UInt64 {
        slots.removeLast()
    }
    
    mutating func pushS64(_ val: Int64) {
        pushU64(UInt64(val))
    }
    mutating func popS64() -> Int64 {
        Int64(popU64())
    }
    
    mutating func pushU32(_ val: UInt32) {
        pushU64(UInt64(val))
    }
    mutating func popU32() -> UInt32 {
        UInt32(popU64())
    }
    
    mutating func pushS32(_ val: Int32) {
        pushU32(UInt32(val))
    }
    mutating func popS32() -> Int32 {
        Int32(popU32())
    }
    
    mutating func pushF32(_ val: Float32) {
        pushU32(val.bitPattern)
    }
    mutating func popF32() -> Float32 {
        Float32(bitPattern: popU32())
    }
    
    mutating func pushF64(_ val: Float64) {
        pushU64(val.bitPattern)
    }
    mutating func popF64() -> Float64 {
        Float64(bitPattern: popU64())
    }
    
    mutating func pushBool(_ val: Bool) {
        pushU64(val ? 1 : 0)
    }
    mutating func popBool() -> Bool {
        popU64() != 0
    }
    
    func size() -> Int {
        return slots.count
    }
    
    func getOperand(at index: UInt32) -> UInt64 {
        return slots[Int(index)]
    }
    
    mutating func setOperand(at index: UInt32, with val: UInt64) {
        slots[Int(index)] = val
    }
    
    mutating func pushU64s(_ vals: [UInt64]) {
        slots.append(contentsOf: vals)
    }
    @discardableResult mutating func popU64s(_ n: Int) -> [UInt64] {
        let vals = Array(slots.suffix(n))
        slots.removeLast(n)
        return vals
    }
}
