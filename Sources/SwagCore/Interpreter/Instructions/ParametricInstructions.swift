//
//  ParametricInstructions.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/20.
//

import Foundation

extension VM {
    
    // MARK: - Parametric Instructions
    
    func drop() {
        _ = operandStack.popU64()
    }
    
    func select() {
        let v3 = operandStack.popBool()
        let v2 = operandStack.popU64()
        let v1 = operandStack.popU64()
        if v3 {
            operandStack.pushU64(v1)
        } else {
            operandStack.pushU64(v2)
        }
    }
    
}
