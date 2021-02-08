//
//  ControlInstructions.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/26.
//

import Foundation

extension VM {
    
    // MARK: - Control Instructions
    
    func unreachable() {
        fatalError("unreachable")
    }
    
    func nop() {
        // do nothing
    }
    
    mutating func block(_ args: BlockArgs) {
        let bt = module.getBlockType(bt: args.blockType)
        enterBlock(opcode: .block, blockType: bt, instrs: args.instrutions)
    }
    
    mutating func loop(_ args: BlockArgs) {
        let bt = module.getBlockType(bt: args.blockType)
        enterBlock(opcode: .loop, blockType: bt, instrs: args.instrutions)
    }
    
    mutating func `if`(_ args: IfArgs) {
        let bt = module.getBlockType(bt: args.blockType)
        let bool = operandStack.popBool()
        if bool {
            enterBlock(opcode: .if, blockType: bt, instrs: args.instrutions1)
        } else {
            let instrs = args.instrutions2 ?? [Instruction]()
            enterBlock(opcode: .if, blockType: bt, instrs: instrs)
        }
    }
    
    mutating func br(_ arg: LabelIdx) {
        let labelIdx = Int(arg)
        for _ in 0..<labelIdx {
            controlStack.popControlFrame()
        }
        if var cf = controlStack.topControlFrame,
           cf.opcode == .loop {
            resetBlock(cf)
            cf.pc = 0
            controlStack.topControlFrame = cf
        } else {
            exitBlock()
        }
    }
    
    mutating func brIf(_ arg: LabelIdx) {
        if operandStack.popBool() {
            br(arg)
        }
    }
    
    mutating func brTable(_ arg: BrTableArgs) {
        let n = Int(operandStack.popU32())
        if n < arg.labels.count {
            br(arg.labels[n])
        } else {
            br(arg.default)
        }
    }
    
    mutating func `return`() {
        let (_, labelIdx) = controlStack.topCallFrame()
        br(LabelIdx(labelIdx))
    }
    
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
    
}
