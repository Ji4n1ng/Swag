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
//    let operandStack: OperandStack
//    let controlStack: ControlStack
//    let globals: [GlobalVar]
    
    public init(memory: Memory) {
        self.memory = memory
    }
    
    public func export() -> [Byte] {
        let exporter = Exporter()
        var data = [Byte]()
        data.append(contentsOf: exporter.exportMemory(memory))
        return data
    }
    
}

