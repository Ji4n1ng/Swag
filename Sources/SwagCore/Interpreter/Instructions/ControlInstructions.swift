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
        let ft = module.getFuncType(bt: args.blockType)
        enterBlock(opcode: .block, funcType: ft, instrs: args.instrutions)
    }
    
    mutating func loop(_ args: BlockArgs) {
        let ft = module.getFuncType(bt: args.blockType)
        enterBlock(opcode: .loop, funcType: ft, instrs: args.instrutions)
    }
    
    mutating func `if`(_ args: IfArgs) {
        let ft = module.getFuncType(bt: args.blockType)
        let bool = operandStack.popBool()
        if bool {
            enterBlock(opcode: .if, funcType: ft, instrs: args.instrutions1)
        } else {
            let instrs = args.instrutions2 ?? [Instruction]()
            enterBlock(opcode: .if, funcType: ft, instrs: instrs)
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
        let function = funcs[Int(funcIdx)]
        // MARK: Hook
        // get the parameters of the hooked function
        if let hookDict = hookDict {
            for (hookFuncIdx, hookFuncName) in hookDict {
                if funcIdx == hookFuncIdx {
                    log("🪝 hook: \(hookFuncName) \(function.type.signature())", .native, .ins)
                    let paramCount = function.type.paramTypes.count
                    let params = operandStack.getTopOperands(paramCount)
                    log("🪝 \(hookFuncName)'s parameter is \(params)", .native, .ins)
                    // hardcode
                    if hookFuncName == "malloc" {
                        memory.isStopCheckingMemory = true
                        guard let size = params.first else {
                            fatalError("cannot get malloc size")
                        }
                        currentMallocedSize = size
                    } else if hookFuncName == "free" {
                        memory.isStopCheckingMemory = true
                        guard let pointer = params.first else {
                            fatalError("cannot get freed pointer")
                        }
                        currentFreedPointer = pointer
                    }
                }
            }
        }
        // call
        callFunc(function)
    }
    
    mutating func callFunc(_ f: Function) {
        if f.code != nil {
            callInternalFunc(f)
        } else {
            callExternalFunc(f)
        }
    }
    
    mutating func callExternalFunc(_ f: Function) {
        let args = popArgs(f.type)
        guard let nativeFunc = f.swiftFunc else { fatalError() }
        do {
            let results = try nativeFunc(args)
            pushResults(f.type, results: results)
        } catch {
            fatalError()
        }
    }
    
    mutating func popArgs(_ ft: FuncType) -> [WasmVal] {
        var args = [WasmVal]()
        for paramType in ft.paramTypes {
            var val: Any
            switch paramType {
            case .i32:
                val = operandStack.popS32()
            case .i64:
                val = operandStack.popS64()
            case .f32:
                val = operandStack.popF32()
            case .f64:
                val = operandStack.popF64()
            }
            let arg = WasmVal(type: paramType, val: val)
            args.append(arg)
        }
        return args
    }
    
    mutating func pushResults(_ ft: FuncType, results: [WasmVal]) {
        if ft.resultTypes.count != results.count {
            fatalError()
        }
        for result in results {
            switch result.type {
            case .i32:
                guard let val = result.val as? Int32 else { fatalError() }
                operandStack.pushS32(val)
            case .i64:
                guard let val = result.val as? Int64 else { fatalError() }
                operandStack.pushS64(val)
            case .f32:
                guard let val = result.val as? Float32 else { fatalError() }
                operandStack.pushF32(val)
            case .f64:
                guard let val = result.val as? Float64 else { fatalError() }
                operandStack.pushF64(val)
            }
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
    
    mutating func callInternalFunc(_ f: Function) {
        guard let code = f.code else { fatalError() }
        enterBlock(opcode: .call, funcType: f.type, instrs: code.expr, function: f)
        
        // alloc locals
        let localCount = Int(code.getLocalCount())
        for _ in 0..<localCount {
            operandStack.pushU64(0)
        }
    }
    
    mutating func callIndirect(_ typeIdx: TypeIdx) {
        guard let table = self.table else { fatalError() }
        let ft = module.typeSec![Int(typeIdx)]
        
        let i = operandStack.popU32()
        if i >= table.size() {
            fatalError("undefined element")
        }
        let function = table.getElem(UInt32(i))
        if function.type.signature() != ft.signature() {
            fatalError("Type mismatch")
        }
        
        callFunc(function)
    }
    
}
