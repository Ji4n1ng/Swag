//
//  VariableInstructions.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/26.
//

import Foundation

extension VM {
    
    // MARK: - Variable Instructions
    
    func localGet(index: LocalIdx) {
        let idx = index + local0Index
        let value = operandStack.getOperand(at: idx)
        operandStack.pushU64(value)
    }
    
    func localSet(index: LocalIdx) {
        let idx = index + local0Index
        let value = operandStack.popU64()
        operandStack.setOperand(at: idx, with: value)
    }
    
    func localTee(index: LocalIdx) {
        let idx = index + local0Index
        let value = operandStack.popU64()
        operandStack.pushU64(value)
        operandStack.setOperand(at: idx, with: value)
    }
    
    func globalGet(index: LocalIdx) {
        let idx = Int(index)
        let value = globals[idx].val
        operandStack.pushU64(value)
    }
    
    func globalSet(index: LocalIdx) {
        let idx = Int(index)
        let value = operandStack.popU64()
        globals[idx].val = value
    }
    
}
