//
//  ControlFrame.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/25.
//

import Foundation

public struct ControlFrame {
    var opcode: Opcode
    var blockType: FuncType
    var instrs: [Instruction]
    /// base pointer (operand stack)
    var bp: Int
    /// program counter
    var pc: Int
    /// function
    var function: Function?
}

public struct ControlStack {
    var frames: [ControlFrame]
    
    var topControlFrame: ControlFrame? {
        get {
            return self.frames.last
        }
        set {
            guard let val = newValue else { return }
            frames[frames.count - 1] = val
        }
    }
}

extension ControlStack {
    func controlDepth() -> Int {
        return frames.count
    }
    
    func topCallFrame() -> (ControlFrame?, Int) {
        for (i, frame) in frames.reversed().enumerated() {
            if frame.opcode == .call {
                return (frame, i)
            }
        }
        return (nil, -1)
    }
    
    mutating func pushControlFrame(_ controlFrame: ControlFrame) {
        frames.append(controlFrame)
    }
    @discardableResult mutating func popControlFrame() -> ControlFrame {
        frames.removeLast()
    }
}
