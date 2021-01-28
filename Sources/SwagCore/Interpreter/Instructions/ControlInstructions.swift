//
//  ControlInstructions.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/26.
//

import Foundation

extension VM {
    
    // MARK: - Control Instructions
    
    mutating func call(funcIdx: FuncIdx) {
        let importedFuncCount = module.importSec?.count ?? 0
        if funcIdx < importedFuncCount {
            callAssertFunc(funcIdx: funcIdx)
        } else {
            callInternalFunc(funcIdx: UInt32(Int(funcIdx) - importedFuncCount))
        }
    }
    
/*
operand stack:

+~~~~~~~~~~~~~~~+
|               |
+---------------+
|     stack     |
+---------------+
|     locals    |
+---------------+
|     params    |
+---------------+
|  ............ |
*/
    
    mutating func callInternalFunc(funcIdx: FuncIdx) {
        guard let funcTypeIndex = module.funcSec?[Int(funcIdx)] else { fatalError() }
        guard let funcType = module.typeSec?[Int(funcTypeIndex)] else { fatalError() }
        guard let code = module.codeSec?[Int(funcIdx)] else { fatalError() }
        enterBlock(opcode: .call, blockType: funcType, instrs: code.expr)
        
        // alloc locals
        let localCount = Int(code.getLocalCount())
        for _ in 0..<localCount {
            operandStack.pushU64(0)
        }
    }
    
    mutating func callAssertFunc(funcIdx: FuncIdx) {
        guard let importItem = module.importSec?[Int(funcIdx)] else { fatalError() }
        
        switch importItem.name {
        case "assert_true":
            assertEq(operandStack.popBool(), true)
        case "assert_false":
            assertEq(operandStack.popBool(), false)
        case "assert_eq_i32":
            assertEq(operandStack.popU32(), operandStack.popU32())
        case "assert_eq_i64":
            assertEq(operandStack.popU64(), operandStack.popU64())
        case "assert_eq_f32":
            assertEq(operandStack.popF32(), operandStack.popF32())
        case "assert_eq_f64":
            assertEq(operandStack.popF64(), operandStack.popF64())
        default:
            print("TODO: callAssertFunc")
        }
    }
    
    func assertEq<T: Equatable>(_ a: T, _ b: T) {
        if a != b {
            print("Error: \(a) != \(b)")
        } else {
            print("Equal: \(a) == \(b)")
        }
    }
    
    mutating func brIf() {
        if operandStack.popBool() {
            exitBlock()
        }
    }
}
