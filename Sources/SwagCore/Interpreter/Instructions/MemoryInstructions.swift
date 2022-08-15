//
//  MemoryInstructions.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/20.
//

import Foundation

extension VM {
    
    // MARK: - Memory Instructions
    
    func memorySize() {
        operandStack.pushU32(memory.size())
    }
    
    func memoryGrow() {
        let oldSize = memory.grow(operandStack.popU32())
        operandStack.pushU32(oldSize)
    }
    
    // MARK: Load
    
    func i32Load(memArg: MemArg) {
        let val = readU32(memArg: memArg)
//        log("val: \(val)")
        operandStack.pushU32(val)
    }
    
    func i64Load(memArg: MemArg) {
        let val = readU64(memArg: memArg)
        
        operandStack.pushU64(val)
    }
    
    func f32Load(memArg: MemArg) {
        let val = readU32(memArg: memArg)
        operandStack.pushU32(val)
    }
    
    func f64Load(memArg: MemArg) {
        let val = readU64(memArg: memArg)
        operandStack.pushU64(val)
    }
    
    func i32Load8S(memArg: MemArg) {
        let val = readU8(memArg: memArg)
        operandStack.pushS32(Int32(Int8(truncatingIfNeeded: val)))
    }
    
    func i32Load8U(memArg: MemArg) {
        let val = readU8(memArg: memArg)
        operandStack.pushU32(UInt32(val))
    }
    
    func i32Load16S(memArg: MemArg) {
        let val = readU16(memArg: memArg)
        operandStack.pushS32(Int32(Int16(truncatingIfNeeded: val)))
    }
    
    func i32Load16U(memArg: MemArg) {
        let val = readU16(memArg: memArg)
        operandStack.pushU32(UInt32(val))
    }
    
    func i64Load8S(memArg: MemArg) {
        let val = readU8(memArg: memArg)
        operandStack.pushS64(Int64(Int8(truncatingIfNeeded: val)))
    }
    
    func i64Load8U(memArg: MemArg) {
        let val = readU8(memArg: memArg)
        operandStack.pushU64(UInt64(val))
    }
    
    func i64Load16S(memArg: MemArg) {
        let val = readU16(memArg: memArg)
        operandStack.pushS64(Int64(Int16(truncatingIfNeeded: val)))
    }
    
    func i64Load16U(memArg: MemArg) {
        let val = readU16(memArg: memArg)
        operandStack.pushU64(UInt64(val))
    }
    
    func i64Load32S(memArg: MemArg) {
        let val = readU32(memArg: memArg)
        operandStack.pushS64(Int64(Int32(truncatingIfNeeded: val)))
    }
    
    func i64Load32U(memArg: MemArg) {
        let val = readU32(memArg: memArg)
        operandStack.pushU64(UInt64(val))
    }
    
    /// d = pop(); addr = arg.offset + d; push(mem[addr:addr+n])
    func getOffset(memArg: MemArg) -> UInt64 {
        let offset = memArg.offset
        let addr = UInt64(offset) + UInt64(operandStack.popU32())
        return addr
    }
    
    func readU8(memArg: MemArg) -> Byte {
        var buf = Array<Byte?>.init(repeating: nil, count: 1)
        let offset = getOffset(memArg: memArg)
        memory.read(offset: offset, buf: &buf)
        let result = buf[0]!
        return result
    }
    
    func readU16(memArg: MemArg) -> UInt16 {
        var buf = Array<Byte?>.init(repeating: nil, count: 2)
        let offset = getOffset(memArg: memArg)
        memory.read(offset: offset, buf: &buf)
        let unwrapBuf = buf.compactMap { $0 }
        guard unwrapBuf.count == buf.count else { fatalError() }
        let result = unwrapBuf.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
        }.pointee
        return result
    }
    
    func readU32(memArg: MemArg) -> UInt32 {
        var buf = Array<Byte?>.init(repeating: nil, count: 4)
        let offset = getOffset(memArg: memArg)
        memory.read(offset: offset, buf: &buf)
        let unwrapBuf = buf.compactMap { $0 }
        guard unwrapBuf.count == buf.count else {
            // `buf` has "nil" elements. Just return 0.
            return 0
        }
        let result = unwrapBuf.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
        }.pointee
        return result
    }
    
    func readU64(memArg: MemArg) -> UInt64 {
        var buf = Array<Byte?>.init(repeating: nil, count: 8)
        let offset = getOffset(memArg: memArg)
        memory.read(offset: offset, buf: &buf)
        let unwrapBuf = buf.compactMap { $0 }
        guard unwrapBuf.count == buf.count else { fatalError() }
        let result = unwrapBuf.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1) { $0 })
        }.pointee
        return result
    }
    
    // MARK: Store
    
    func i32Store(memArg: MemArg) {
        let val = operandStack.popU32()
        writeU32(memArg: memArg, n: val)
    }
    
    func i64Store(memArg: MemArg) {
        let val = operandStack.popU64()
        writeU64(memArg: memArg, n: val)
    }
    
    func f32Store(memArg: MemArg) {
        let val = operandStack.popU32()
        writeU32(memArg: memArg, n: val)
    }
    
    func f64Store(memArg: MemArg) {
        let val = operandStack.popU64()
        writeU64(memArg: memArg, n: val)
    }
    
    func i32Store8(memArg: MemArg) {
        let val = operandStack.popU32()
        writeU8(memArg: memArg, n: Byte(val))
    }
    
    func i32Store16(memArg: MemArg) {
        let val = operandStack.popU32()
        writeU16(memArg: memArg, n: UInt16(val))
    }
    
    func i64Store8(memArg: MemArg) {
        let val = operandStack.popU64()
        writeU8(memArg: memArg, n: Byte(val))
    }
    
    func i64Store16(memArg: MemArg) {
        let val = operandStack.popU64()
        writeU16(memArg: memArg, n: UInt16(val))
    }
    
    func i64Store32(memArg: MemArg) {
        let val = operandStack.popU64()
        writeU32(memArg: memArg, n: UInt32(val))
    }
    
    func writeU8(memArg: MemArg, n: Byte) {
        let buf = [n]
        let offset = getOffset(memArg: memArg)
        memory.write(offset: offset, data: buf)
    }
    
    func writeU16(memArg: MemArg, n: UInt16) {
        let buf = withUnsafeBytes(of: n.littleEndian, Array.init).map { Byte.init($0) }
        let offset = getOffset(memArg: memArg)
        memory.write(offset: offset, data: buf)
    }
    
    func writeU32(memArg: MemArg, n: UInt32) {
        let buf = withUnsafeBytes(of: n.littleEndian, Array.init).map { Byte.init($0) }
        let offset = getOffset(memArg: memArg)
        memory.write(offset: offset, data: buf)
    }
    
    func writeU64(memArg: MemArg, n: UInt64) {
        let buf = withUnsafeBytes(of: n.littleEndian, Array.init).map { Byte.init($0) }
        let offset = getOffset(memArg: memArg)
        memory.write(offset: offset, data: buf)
    }
    
    
}
