//
//  Reader.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/11/7.
//

import Foundation

public struct Reader {
    public var data: [Byte]
    
    public init(data: [Byte]) {
        self.data = data
    }
}

extension Reader {
    
    func remaining() -> Int {
        return self.data.count
    }
    
    // MARK: fixed length value
    mutating func readByte() -> Byte {
        let byte = data.removeFirst()
        return byte
    }
    
    mutating func readUInt32() -> UInt32 {
        let bytes = self.readBytes(4)
        let littleEndianValue = bytes.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
        }.pointee
        return littleEndianValue
    }
    
    mutating func readFloat32() -> Float32 {
        let bytes = self.readBytes(4)
        let littleEndianValue = bytes.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: Float32.self, capacity: 1) { $0 })
        }.pointee
        return littleEndianValue
    }
    
    mutating func readFloat64() -> Float64 {
        let bytes = self.readBytes(4)
        let littleEndianValue = bytes.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: Float64.self, capacity: 1) { $0 })
        }.pointee
        return littleEndianValue
    }
    
    // MARK: LEB128
    /// https://en.wikipedia.org/wiki/LEB128#Decode_unsigned_integer
    func decodeVarUInt(data: [Byte], size: Int) -> (UInt64, Int) {
        var result = UInt64(0)
        for (i, b) in data.enumerated() {
            if i == size / 7 {
                // 1000 0000
                if b & 0x80 != 0 {
                    fatalError("Int too long")
                }
                if b >> (size - i*7) > 0 {
                    fatalError("Int too large")
                }
            }
            result |= (UInt64(b) & 0x7f) << (i * 7)
            if b & 0x80 == 0 {
                return (result, i + 1)
            }
        }
        fatalError("unexpected end")
    }
    
    /// https://en.wikipedia.org/wiki/LEB128#Decode_signed_integer
    func decodeVarInt(data: [Byte], size: Int) -> (Int64, Int) {
        var result = Int64(0)
        for (i, b) in data.enumerated() {
            if i == size / 7 {
                if b & 0x80 != 0 {
                    fatalError("Int too long")
                }
                if (b & 0x40 == 0) && (b >> (size - i * 7 - 1) != 0) ||
                    (b & 0x40 != 0) && (Int8(b | 0x80) >> (size - i * 7 - 1) != -1) {
                    fatalError("Int too large")
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
        fatalError("unexpected end")
    }
    
    // MARK: variable length value
    mutating func readVarUInt32() -> UInt32 {
        let (n, w) = decodeVarUInt(data: data, size: 32)
        data = Array(data.suffix(from: w))
        return UInt32(n)
    }
    
    mutating func readVarInt32() -> Int32 {
        let (n, w) = decodeVarInt(data: data, size: 32)
        data = Array(data.suffix(from: w))
        return Int32(n)
    }
    
    mutating func readVarInt64() -> Int64 {
        let (n, w) = decodeVarInt(data: data, size: 64)
        data = Array(data.suffix(from: w))
        return Int64(n)
    }
    
    // MARK: bytes & name
    mutating func readBytes(_ n: Int) -> [Byte] {
        let bytes = Array(data.prefix(n))
        data = Array(data.dropFirst(n))
        return bytes
    }
    
    mutating func readBytes() -> [Byte] {
        let len = Int(readVarUInt32())
        if data.count < len {
            fatalError()
        }
        let bytes = Array(data.prefix(len))
        data = Array(data.dropFirst(len))
        return bytes
    }
    
    mutating func readName() -> String {
        let data = readBytes()
        if let str = String(bytes: data, encoding: .utf8) {
            return str
        } else {
            fatalError()
        }
//        return string(data)
    }
    
    // MARK: module
    public mutating func readModule() -> Module {
        // Magic
        if remaining() < 4 {
            fatalError("unexpected end of magic header")
        }
        let magic = readUInt32()
        guard magic == MAGIC_NUMBER else { fatalError("magic header not detected") }
        // Version
        if remaining() < 4 {
            fatalError("unexpected end of binary version")
        }
        let version = readUInt32()
        guard version == VERSION else { fatalError("unknown binary version: \(version)") }
        
        var module = Module(magic: magic, version: version)
        // Read Sections
        var prevSecID: SectionID = .custom
        while remaining() > 0 {
            guard let secID = SectionID(rawValue: readByte()) else {
                fatalError()
            }
            if secID == .custom {
                if module.customSecs != nil {
                    module.customSecs?.append(readCustomSec())
                } else {
                    var customSecs = [CustomSec]()
                    customSecs.append(readCustomSec())
                    module.customSecs = customSecs
                }
                continue
            }
            
            if secID.rawValue > SectionID.data.rawValue {
                fatalError("malformed section id: \(secID)")
            }
            if secID.rawValue <= prevSecID.rawValue {
                fatalError("junk after last section, id: \(secID)")
            }
            prevSecID = secID
            
            let n = readVarUInt32()
            let remainingBeforeRead = remaining()
            switch secID {
            case .type:
                module.typeSec = readTypeSec()
            case .import:
                module.importSec = readImportSec()
            case .func:
                module.funcSec = readIndices()
            case .table:
                module.tableSec = readTableSec()
            case .mem:
                module.memSec = readMemSec()
            case .global:
                module.globalSec = readGlobalSec()
            case .export:
                module.exportSec = readExportSec()
            case .start:
                module.startSec = readStartSec()
            case .elem:
                module.elemSec = readElemSec()
            case .code:
                module.codeSec = readCodeSec()
            case .data:
                module.dataSec = readDataSec()
            default:
                fatalError()
            }
            let remainingAfterRead = remaining()
            if remainingAfterRead + Int(n) != remainingBeforeRead {
                fatalError()
            }
        }
        
        if module.funcSec?.count != module.codeSec?.count {
            fatalError()
        }
        if remaining() > 0 {
            print("junk after last section")
        }
        return module
    }
    
    mutating func readCustomSec() -> CustomSec {
        let bytes = readBytes()
        var secReader = Reader(data: bytes)
        return CustomSec(
            name: secReader.readName(),
            bytes: secReader.data
        )
    }
    
//    func readNonCustomSec(secID: Byte) {
//        switch SecID {
//        case
//        }
//    }
    
    // MARK: Type Sec
    mutating func readTypeSec() -> [FuncType] {
        let len = readVarUInt32()
        var fts = [FuncType]()
        for _ in 0..<len {
            fts.append(readFuncType())
        }
        return fts
    }
    
    // MARK: Import Sec
    mutating func readImportSec() -> [Import] {
        let len = readVarUInt32()
        var imports = [Import]()
        for _ in 0..<len {
            imports.append(readImport())
        }
        return imports
    }
    
    mutating func readImport() -> Import {
        return Import(
            module: readName(),
            name: readName(),
            desc: readImportDesc()
        )
    }
    
    mutating func readImportDesc() -> ImportDesc {
        guard let tag = ImportTag(rawValue: readByte()) else {
            fatalError()
        }
        var desc = ImportDesc(tag: tag, funcType: nil, table: nil, mem: nil, global: nil)
        switch tag {
        case .func:
            desc.funcType = readVarUInt32()
        case .table:
            desc.table = readTableType()
        case .mem:
            desc.mem = readLimits()
        case .global:
            desc.global = readGlobalType()
        }
        return desc
    }
    
    // MARK: Table Sec
    mutating func readTableSec() -> [TableType] {
        let count = readVarUInt32()
        var tts = [TableType]()
        for _ in 0..<count {
            tts.append(readTableType())
        }
        return tts
    }
    
    // MARK: Mem Sec
    mutating func readMemSec() -> [MemType] {
        let count = readVarUInt32()
        var vec = [Limits]()
        for _ in 0..<count {
            vec.append(readLimits())
        }
        return vec
    }
    
    // MARK: global sec
    mutating func readGlobalSec() -> [Global] {
        let count = readVarUInt32()
        var vec = [Global]()
        for _ in 0..<count {
            vec.append(Global(type: readGlobalType(), init: readExpr()))
        }
        return vec
    }
    
    // MARK: export sec
    mutating func readExportSec() -> [Export] {
        let count = readVarUInt32()
        var exports = [Export]()
        for _ in 0..<count {
            exports.append(readExport())
        }
        return exports
    }
    
    mutating func readExport() -> Export {
        return Export(
            name: readName(),
            desc: readExportDesc()
        )
    }
    
    mutating func readExportDesc() -> ExportDesc {
        guard let tag = ExportTag(rawValue: readByte()) else {
            fatalError()
        }
        let desc = ExportDesc(tag: tag, idx: readVarUInt32())
        return desc
    }
    
    // MARK: start sec
    mutating func readStartSec() -> UInt32 {
        // TODO: - &
        return readVarUInt32()
    }
    
    // MARK: elem sec
    mutating func readElemSec() -> [Elem] {
        let count = readVarUInt32()
        var elems = [Elem]()
        for _ in 0..<count {
            elems.append(readElem())
        }
        return elems
    }
    
    mutating func readElem() -> Elem {
        return Elem(table: readVarUInt32(), offset: readExpr(), init: readIndices())
    }
    
    // MARK: code sec
    mutating func readCodeSec() -> [Code] {
        let count = readVarUInt32()
        var vec = [Code]()
        for i in 0..<count {
            vec.append(readCode(Int(i)))
        }
        return vec
    }
    
    mutating func readCode(_ idx: Int) -> Code {
        let n = readVarUInt32()
        let remainingBeforeRead = remaining()
        let locals = readLocalsVec()
        let expr = readExpr()
        let code = Code(locals: locals, expr: expr)
        let remainingAfterRead = remaining()
        if remainingAfterRead + Int(n) != remainingBeforeRead {
            fatalError("invalid code[\(idx)]")
        }
        if code.getLocalCount() >= UInt32.max {
            fatalError("too many locals: \(code.getLocalCount())")
        }
        return code
    }
    
    mutating func readLocalsVec() -> [Locals] {
        let count = readVarUInt32()
        var vec = [Locals]()
        for _ in 0..<count {
            vec.append(readLocals())
        }
        return vec
    }
    
    mutating func readLocals() -> Locals {
        return Locals(n: readVarUInt32(), type: readValType())
    }
    
    // MARK: data sec
    mutating func readDataSec() -> [Data] {
        let count = readVarUInt32()
        var vec = [Data]()
        for _ in 0..<count {
            vec.append(readData())
        }
        return vec
    }
    
    mutating func readData() -> Data {
        return Data(mem: readVarUInt32(), offset: readExpr(), init: readBytes())
    }
    
    // MARK: value types
    mutating func readValTypes() -> [ValType] {
        let len = readVarUInt32()
        var vts = [ValType]()
        for _ in 0..<len {
            vts.append(readValType())
        }
        return vts
    }
    
    mutating func readValType() -> ValType {
        let vt = readByte()
        guard let _ = BaseValType(rawValue: vt) else {
            fatalError("malformed value type: \(vt)")
        }
        return vt
    }
    
    // MARK: entity types
    mutating func readBlockType() -> BlockType {
        let blockType = readVarInt32()
        if blockType < 0 {
//            BlockTypeI32   BlockType = -1  // ()->(i32)
//            BlockTypeI64   BlockType = -2  // ()->(i64)
//            BlockTypeF32   BlockType = -3  // ()->(f32)
//            BlockTypeF64   BlockType = -4  // ()->(f64)
//            BlockTypeEmpty BlockType = -64 // ()->()
            switch blockType {
            case -1, -2, -3, -4, -64:
                break
            default:
                fatalError("malformed block type: \(blockType)")
            }
        }
        return blockType
    }
    
    mutating func readFuncType() -> FuncType {
        let t = readByte()
        let p = readValTypes()
        let r = readValTypes()
        let ft = FuncType(
            tag: t,
            paramTypes: p,
            resultTypes: r
        )
        if ft.tag != FUNC_TYPE_TAG {
            fatalError("invalid functype tag: \(ft.tag)")
        }
        return ft
    }
    
    mutating func readTableType() -> TableType {
        let tt = TableType(
            elemType: readByte(),
            limits: readLimits()
        )
        if tt.elemType != FUNC_REF {
            fatalError()
        }
        return tt
    }
    
    mutating func readGlobalType() -> GlobalType {
        let vt = readValType()
        guard let mut = MutType(rawValue: readByte()) else {
            fatalError()
        }
        return GlobalType(valType: vt, mut: mut)
    }
    
    mutating func readLimits() -> Limits {
        guard let tag = LimitsTag(rawValue: readByte()) else {
            fatalError()
        }
        var limits = Limits(tag: tag, min: readVarUInt32(), max: nil)
        if tag == .minMax {
            limits.max = readVarUInt32()
        }
        return limits
    }
    
    // MARK: indices
    mutating func readIndices() -> [UInt32] {
        let len = readVarUInt32()
        var vec = [UInt32]()
        for _ in 0..<len {
            vec.append(readVarUInt32())
        }
        return vec
    }
    
    // MARK: expr & instruction
    mutating func readExpr() -> Expr {
        let (instrs, end) = readInstructions()
        if end != .end {
            fatalError("invalid expr end: \(end)")
        }
        return instrs
    }
    
    mutating func readInstructions() -> ([Instruction], Opcode) {
        var instrs = [Instruction]()
        while true {
            let instr = readInstruction()
            if instr.opcode == .else || instr.opcode == .end {
                let end = instr.opcode
                return (instrs, end)
            }
            instrs.append(instr)
        }
    }
    
    mutating func readInstruction() -> Instruction {
        guard let opcode = Opcode(rawValue: readByte()) else {
            fatalError()
        }
        let args = readArgs(opcode: opcode)
        return Instruction(opcode: opcode, args: args)
    }
    
    mutating func readArgs(opcode: Opcode) -> Any? {
        switch opcode {
        case .block, .loop:
            return readBlockArgs()
        case .if:
            return readIfArgs()
        case .br, .brIf:
            return readVarUInt32() // label_idx
        case .brTable:
            return readBrTableArgs()
        case .call:
            return readVarUInt32() // func_idx
        case .callIndirect:
            return readCallIndirectArgs()
        case .localGet, .localSet, .localTee:
            return readVarUInt32() // local_idx
        case .globalGet, .globalSet:
            return readVarUInt32() // global_idx
        case .memorySize, .memoryGrow:
            return readZero()
        case .i32Const:
            return readVarInt32()
        case .i64Const:
            return readVarInt64()
        case .f32Const:
            return readFloat32()
        case .f64Const:
            return readFloat64()
        case .truncSat:
            return readByte()
        default:
            if Opcode.i32Load.rawValue ... Opcode.i64Store.rawValue ~= opcode.rawValue {
                return readMemArg()
            }
            return nil
        }
    }
    
    mutating func readBlockArgs() -> BlockArgs {
        let blockType = readBlockType()
        let (instrs, end) = readInstructions()
        let blockArgs = BlockArgs(blockType: blockType, instrutions: instrs)
        if end != .end {
            fatalError("invalid block end: \(end)")
        }
        return blockArgs
    }
    
    mutating func readIfArgs() -> IfArgs {
        let blockType = readBlockType()
        let (instrs1, end1) = readInstructions()
        var ifArgs = IfArgs(blockType: blockType, instrutions1: instrs1, instrutions2: nil)
        if end1 == .else {
            let (instrs2, end2) = readInstructions()
            ifArgs.instrutions2 = instrs2
            if end2 != .end {
                fatalError("invalid block end: \(end2)")
            }
        }
        return ifArgs
    }
    
    mutating func readBrTableArgs() -> BrTableArgs {
        BrTableArgs(labels: readIndices(), default: readVarUInt32())
    }
    
    mutating func readCallIndirectArgs() -> UInt32 {
        let typeIdx = readVarUInt32()
        readZero()
        return typeIdx
    }
    
    mutating func readMemArg() -> MemArg {
        MemArg(align: readVarUInt32(), offset: readVarUInt32())
    }
    
    @discardableResult mutating func readZero() -> Byte {
        let b = readByte()
        if b != 0 {
            fatalError("zero flag expected, got \(b)")
        }
        return b
    }
}
