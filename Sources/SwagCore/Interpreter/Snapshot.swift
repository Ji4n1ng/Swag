//
//  Snapshot.swift
//  SwagCore
//
//  Created by Jianing Wang on 3/16/24.
//

import Foundation

public enum SnapshotSectionID: Byte {
    case memory = 0
    case controlStack
    case operandStack
    case globals
}

public class Snapshot {
    
    public let memory: Memory
    public let operandStack: OperandStack
//    let controlStack: ControlStack
//    let globals: [GlobalVar]
    
    public init(memory: Memory, operandStack: OperandStack) {
        self.memory = memory
        self.operandStack = operandStack
    }
    
    public func export() -> [Byte] {
        let exp = Exporter()
        var data = [Byte]()
        data.append(contentsOf: exp.exportMemory(memory))
        data.append(contentsOf: exp.exportOperandStack(operandStack))
        return data
    }
    
}

