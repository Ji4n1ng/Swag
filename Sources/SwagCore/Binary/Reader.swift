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
        let value = bytes.littleEndianValue(UInt32.self)
        return value
    }
    
    mutating func readFloat32() -> Float32 {
        let bytes = self.readBytes(4)
        let value = bytes.littleEndianValue(Float32.self)
        return value
    }
    
    mutating func readFloat64() -> Float64 {
        let bytes = self.readBytes(8)
        let value = bytes.littleEndianValue(Float64.self)
        return value
    }
    
    // MARK: variable length value
    mutating func readVarUInt32() throws -> UInt32 {
        let (n, w) = try decodeVarUInt(data: data, size: 32)
        data = Array(data.suffix(from: w))
        return UInt32(n)
    }
    
    mutating func readVarInt32() throws -> Int32 {
        let (n, w) = try decodeVarInt(data: data, size: 32)
        data = Array(data.suffix(from: w))
        return Int32(n)
    }
    
    mutating func readVarInt64() throws -> Int64 {
        let (n, w) = try decodeVarInt(data: data, size: 64)
        data = Array(data.suffix(from: w))
        return Int64(n)
    }
    
    // MARK: bytes & name
    mutating func readBytes(_ n: Int) -> [Byte] {
        let bytes = Array(data.prefix(n))
        data = Array(data.dropFirst(n))
        return bytes
    }
    
    mutating func readBytes() throws -> [Byte] {
        let len = Int(try readVarUInt32())
        if data.count < len {
            throw ParseError.unexpectedEnd
        }
        let bytes = Array(data.prefix(len))
        data = Array(data.dropFirst(len))
        return bytes
    }
    
    mutating func readName() throws -> String {
        let data = try readBytes()
        if let str = String(bytes: data, encoding: .utf8) {
            return str
        } else {
            throw ParseError.stringEncodeError(data)
        }
    }
    
    // MARK: module
    public mutating func readModule() throws -> Module {
        // Magic
        if remaining() < 4 {
            throw ParseError.invalidModule("unexpected end of magic header")
        }
        let magic = readUInt32()
        guard magic == MAGIC_NUMBER else {
            throw ParseError.invalidModule("magic header not detected")
        }
        // Version
        if remaining() < 4 {
            throw ParseError.invalidModule("unexpected end of binary version")
        }
        let version = readUInt32()
        guard version == VERSION else {
            throw ParseError.invalidModule("unknown binary version: \(version)")
        }
        
        var module = Module(magic: magic, version: version)
        // Read Sections
        var prevSecID: SectionID = .custom
        while remaining() > 0 {
            let id = readByte()
            guard let secID = SectionID(rawValue: id) else {
                throw ParseError.invalidSectionID(id)
            }
            if secID == .custom {
                if module.customSecs != nil {
                    let customSec = try readCustomSec()
                    module.customSecs?.append(customSec)
                } else {
                    var customSecs = [CustomSec]()
                    let customSec = try readCustomSec()
                    customSecs.append(customSec)
                    module.customSecs = customSecs
                }
                continue
            }
            
            if secID.rawValue > SectionID.data.rawValue {
                throw ParseError.invalidModule("malformed section id: \(secID)")
            }
            if secID.rawValue <= prevSecID.rawValue {
                throw ParseError.invalidModule("junk after last section, id: \(secID)")
            }
            prevSecID = secID
            
            let n = try readVarUInt32()
            let remainingBeforeRead = remaining()
            switch secID {
            case .type:
                module.typeSec = try readTypeSec()
            case .import:
                module.importSec = try readImportSec()
            case .func:
                module.funcSec = try readIndices()
            case .table:
                module.tableSec = try readTableSec()
            case .mem:
                module.memSec = try readMemSec()
            case .global:
                module.globalSec = try readGlobalSec()
            case .export:
                module.exportSec = try readExportSec()
            case .start:
                module.startSec = try readStartSec()
            case .elem:
                module.elemSec = try readElemSec()
            case .code:
                module.codeSec = try readCodeSec()
            case .data:
                module.dataSec = try readDataSec()
            default:
                throw ParseError.invalidModule("invalid section id: \(secID)")
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
    
    mutating func readCustomSec() throws -> CustomSec {
        let bytes = try readBytes()
        var secReader = Reader(data: bytes)
        let name = try secReader.readName()
        let data = secReader.data
        return CustomSec(name: name, bytes: data)
    }
    
    // MARK: Type Sec
    mutating func readTypeSec() throws -> [FuncType] {
        let len = try readVarUInt32()
        var fts = [FuncType]()
        for _ in 0..<len {
            fts.append(try readFuncType())
        }
        return fts
    }
    
    // MARK: Import Sec
    mutating func readImportSec() throws -> [Import] {
        let len = try readVarUInt32()
        var imports = [Import]()
        for _ in 0..<len {
            imports.append(try readImport())
        }
        return imports
    }
    
    mutating func readImport() throws -> Import {
        let module = try readName()
        let name = try readName()
        let desc = try readImportDesc()
        return Import(module: module, name: name, desc: desc)
    }
    
    mutating func readImportDesc() throws -> ImportDesc {
        let tag = try ImportTag(readByte())
        var desc = ImportDesc(tag: tag, funcType: nil, table: nil, mem: nil, global: nil)
        switch tag {
        case .func:
            desc.funcType = try readVarUInt32()
        case .table:
            desc.table = try readTableType()
        case .mem:
            desc.mem = try readLimits()
        case .global:
            desc.global = try readGlobalType()
        }
        return desc
    }
    
    // MARK: Table Sec
    mutating func readTableSec() throws -> [TableType] {
        let count = try readVarUInt32()
        var tts = [TableType]()
        for _ in 0..<count {
            tts.append(try readTableType())
        }
        return tts
    }
    
    // MARK: Mem Sec
    mutating func readMemSec() throws -> [MemType] {
        let count = try readVarUInt32()
        var vec = [Limits]()
        for _ in 0..<count {
            vec.append(try readLimits())
        }
        return vec
    }
    
    // MARK: global sec
    mutating func readGlobalSec() throws -> [Global] {
        let count = try readVarUInt32()
        var vec = [Global]()
        for _ in 0..<count {
            vec.append(
                Global(
                    type: try readGlobalType(),
                    init: try readExpr()
                )
            )
        }
        return vec
    }
    
    // MARK: export sec
    mutating func readExportSec() throws -> [Export] {
        let count = try readVarUInt32()
        var exports = [Export]()
        for _ in 0..<count {
            exports.append(try readExport())
        }
        return exports
    }
    
    mutating func readExport() throws -> Export {
        let name = try readName()
        let desc = try readExportDesc()
        return Export(name: name, desc: desc)
    }
    
    mutating func readExportDesc() throws -> ExportDesc {
        let tag = try ExportTag(readByte())
        let desc = ExportDesc(tag: tag, idx: try readVarUInt32())
        return desc
    }
    
    // MARK: start sec
    mutating func readStartSec() throws -> UInt32 {
        // TODO: - &
        return try readVarUInt32()
    }
    
    // MARK: elem sec
    mutating func readElemSec() throws -> [Elem] {
        let count = try readVarUInt32()
        var elems = [Elem]()
        for _ in 0..<count {
            elems.append(try readElem())
        }
        return elems
    }
    
    mutating func readElem() throws -> Elem {
        let table = try readVarUInt32()
        let offset = try readExpr()
        let indices = try readIndices()
        return Elem(table: table, offset: offset, init: indices)
    }
    
    // MARK: code sec
    mutating func readCodeSec() throws -> [Code] {
        let count = try readVarUInt32()
        var vec = [Code]()
        for i in 0..<Int(count) {
            vec.append(try readCode(i))
        }
        return vec
    }
    
    mutating func readCode(_ idx: Int) throws -> Code {
        let n = try readVarUInt32()
        let remainingBeforeRead = remaining()
        let locals = try readLocalsVec()
        let expr = try readExpr()
        let code = Code(locals: locals, expr: expr)
        let remainingAfterRead = remaining()
        if remainingAfterRead + Int(n) != remainingBeforeRead {
            throw ParseError.invalidCode(idx)
        }
        let count = code.getLocalCount()
        if count >= UInt32.max {
            throw ParseError.invalidCodeTooManyLocals(count)
        }
        return code
    }
    
    mutating func readLocalsVec() throws -> [Locals] {
        let count = try readVarUInt32()
        var vec = [Locals]()
        for _ in 0..<count {
            vec.append(try readLocals())
        }
        return vec
    }
    
    mutating func readLocals() throws -> Locals {
        let n = try readVarUInt32()
        let type = try readValType()
        return Locals(n: n, type: type)
    }
    
    // MARK: data sec
    mutating func readDataSec() throws -> [Data] {
        let count = try readVarUInt32()
        var vec = [Data]()
        for _ in 0..<count {
            vec.append(try readData())
        }
        return vec
    }
    
    mutating func readData() throws -> Data {
        let mem = try readVarUInt32()
        let offset = try readExpr()
        let _init = try readBytes()
        return Data(mem: mem, offset: offset, init: _init)
    }
    
    // MARK: value types
    mutating func readValTypes() throws -> [ValType] {
        let len = try readVarUInt32()
        var vts = [ValType]()
        for _ in 0..<len {
            vts.append(try readValType())
        }
        return vts
    }
    
    mutating func readValType() throws -> ValType {
        let byte = readByte()
        guard let vt = ValType(rawValue: byte) else {
            fatalError("malformed value type: \(byte)")
        }
        return vt
    }
    
    // MARK: entity types
    mutating func readBlockType() throws -> BlockType {
        let raw = try readVarInt32()
        if raw < 0 {
            let _ = try BasicBlockType(raw)
        }
        return raw
    }
    
    mutating func readFuncType() throws -> FuncType {
        let tag = readByte()
        if tag != FUNC_TYPE_TAG {
            fatalError("invalid functype tag: \(tag)")
        }
        let p = try readValTypes()
        let r = try readValTypes()
        let ft = FuncType(
            paramTypes: p,
            resultTypes: r
        )
        return ft
    }
    
    mutating func readTableType() throws -> TableType {
        let tt = TableType(
            elemType: readByte(),
            limits: try readLimits()
        )
        if tt.elemType != FUNC_REF {
            fatalError()
        }
        return tt
    }
    
    mutating func readGlobalType() throws -> GlobalType {
        let vt = try readValType()
        guard let mut = MutType(rawValue: readByte()) else {
            fatalError()
        }
        return GlobalType(valType: vt, mut: mut)
    }
    
    mutating func readLimits() throws -> Limits {
        let tag = try LimitsTag(readByte())
        let min = try readVarUInt32()
        var limits = Limits(tag: tag, min: min, max: nil)
        if tag == .minMax {
            limits.max = try readVarUInt32()
        }
        return limits
    }
    
    // MARK: indices
    mutating func readIndices() throws -> [UInt32] {
        let len = try readVarUInt32()
        var vec = [UInt32]()
        for _ in 0..<len {
            vec.append(try readVarUInt32())
        }
        return vec
    }
    
    // MARK: expr & instruction
    mutating func readExpr() throws -> Expr {
        let (instrs, end) = try readInstructions()
        if end != .end {
            throw ParseError.invalidExprEnd(end)
        }
        return instrs
    }
    
    mutating func readInstructions() throws -> ([Instruction], Opcode) {
        var instrs = [Instruction]()
        while true {
            let instr = try readInstruction()
            if instr.opcode == .else || instr.opcode == .end {
                let end = instr.opcode
                return (instrs, end)
            }
            instrs.append(instr)
        }
    }
    
    mutating func readInstruction() throws -> Instruction {
        let opcode = try Opcode(readByte())
        let args = try readArgs(opcode: opcode)
        return Instruction(opcode: opcode, args: args)
    }
    
    mutating func readArgs(opcode: Opcode) throws -> Any? {
        switch opcode {
        case .block, .loop:
            return try readBlockArgs()
        case .if:
            return try readIfArgs()
        case .br, .brIf:
            return try readVarUInt32() // label_idx
        case .brTable:
            return try readBrTableArgs()
        case .call:
            return try readVarUInt32() // func_idx
        case .callIndirect:
            return try readCallIndirectArgs()
        case .localGet, .localSet, .localTee:
            return try readVarUInt32() // local_idx
        case .globalGet, .globalSet:
            return try readVarUInt32() // global_idx
        case .memorySize, .memoryGrow:
            return readZero()
        case .i32Const:
            return try readVarInt32()
        case .i64Const:
            return try readVarInt64()
        case .f32Const:
            return readFloat32()
        case .f64Const:
            return readFloat64()
        case .truncSat:
            return readByte()
        default:
            if Opcode.i32Load.rawValue ... Opcode.i64Store32.rawValue ~= opcode.rawValue {
                return try readMemArg()
            }
            return nil
        }
    }
    
    mutating func readBlockArgs() throws -> BlockArgs {
        let blockType = try readBlockType()
        let (instrs, end) = try readInstructions()
        let blockArgs = BlockArgs(blockType: blockType, instrutions: instrs)
        if end != .end {
            throw ParseError.invalidArgs("invalid block end: \(end)")
        }
        return blockArgs
    }
    
    mutating func readIfArgs() throws -> IfArgs {
        let blockType = try readBlockType()
        let (instrs1, end1) = try readInstructions()
        var ifArgs = IfArgs(blockType: blockType, instrutions1: instrs1, instrutions2: nil)
        if end1 == .else {
            let (instrs2, end2) = try readInstructions()
            ifArgs.instrutions2 = instrs2
            if end2 != .end {
                throw ParseError.invalidArgs("invalid block end: \(end2)")
            }
        }
        return ifArgs
    }
    
    mutating func readBrTableArgs() throws -> BrTableArgs {
        let labels = try readIndices()
        let _default = try readVarUInt32()
        return BrTableArgs(labels: labels, default: _default)
    }
    
    mutating func readCallIndirectArgs() throws -> TypeIdx {
        let typeIdx = try readVarUInt32()
        readZero()
        return typeIdx
    }
    
    mutating func readMemArg() throws -> MemArg {
        let align = try readVarUInt32()
        let offset = try readVarUInt32()
        return MemArg(align: align, offset: offset)
    }
    
    @discardableResult mutating func readZero() -> Byte {
        let b = readByte()
        if b != 0 {
            fatalError("zero flag expected, got \(b)")
        }
        return b
    }
    
    // MARK: Snapshot
    public mutating func readSnapshot() throws -> Snapshot {
        var memory: Memory? = nil
        
        while remaining() > 0 {
            let id = readByte()
            guard let secID = SnapshotSectionID(rawValue: id) else {
                throw ParseError.invalidSnapshotSectionID(id)
            }
            let n = try readVarUInt32()
            let remainingBeforeRead = remaining()
            switch secID {
            case .memory:
                memory = try readSnapshotMemory()
            case .controlStack:
                continue
            case .operandStack:
                continue
            case .globals:
                continue
            }
            let remainingAfterRead = remaining()
            if remainingAfterRead + Int(n) != remainingBeforeRead {
                fatalError()
            }       
        }
        
        if remaining() > 0 {
            print("junk after last section")
        }

        guard memory != nil else { throw ParseError.missingSection("memory") }
        return Snapshot(memory: memory!)
        
    }
    
    mutating func readSnapshotMemory() throws -> Memory {
        let memTypes = try readMemSec()
        let memData = try readBytes()
        var memory = Memory(type: memTypes[0], data: memData)
        return memory
    }
    
}
