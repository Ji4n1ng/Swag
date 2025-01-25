//
//  Snapshot.swift
//  SwagCore
//
//  Created by Jianing Wang on 3/16/24.
//

import Foundation

public enum SnapshotSectionID: Byte {
    case memory = 0
    case operandStack
    case controlStack
    case globals
}

public class Snapshot {
    
    public let memory: Memory
    public let operandStack: OperandStack
    public let controlStack: ControlStack
//    let globals: [GlobalVar]
    
    public init(memory: Memory, operandStack: OperandStack, controlStack: ControlStack) {
        self.memory = memory
        self.operandStack = operandStack
        self.controlStack = controlStack
    }
    
    public func export() -> [Byte] {
        let exp = Exporter()
        var data = [Byte]()
        data.append(contentsOf: exp.exportMemory(memory))
        data.append(contentsOf: exp.exportOperandStack(operandStack))
        data.append(contentsOf: exp.exportControlStack(controlStack))
        return data
    }
    
    public func export(_ url: URL) {
        let data = export()
        let d = Foundation.Data(data)
        do {
            try d.write(to: url)
        } catch {
            print("Failed to write data to \(url)")
            print(error)
        }
    }
    
}

