//
//  Instruction.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/11/26.
//

import Foundation

public struct Instruction {
    public var opcode: Opcode
    public var args: Any?
}

public typealias Expr = [Instruction]

extension Instruction: CustomStringConvertible {
    public var description: String {
        return self.opcode.description
    }
}

public struct MemArg {
    public var align: UInt32
    public var offset: UInt32
}

public typealias BlockType = Int32
public enum BasicBlockType: BlockType {
    /// ()->(i32)
    case i32 = -1
    /// ()->(i64)
    case i64 = -2
    /// ()->(f32)
    case f32 = -3
    /// ()->(f64)
    case f64 = -4
    /// ()->()
    case empty = -64
    
    init(_ raw: BlockType) throws {
        if let bbt = BasicBlockType(rawValue: raw) {
            self = bbt
        } else {
            throw ParseError.invalidBasicBlockType(raw)
        }
    }
}

// block & loop
public struct BlockArgs {
    public var blockType: BlockType
    public var instrutions: [Instruction]
}

public struct IfArgs {
    public var blockType: BlockType
    public var instrutions1: [Instruction]
    public var instrutions2: [Instruction]?
}

// br: br, br_if, br_table, return
public struct BrTableArgs {
    public var labels: [LabelIdx]
    public var `default`: LabelIdx
}
