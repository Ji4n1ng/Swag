//
//  VM.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2020/12/30.
//

import Foundation

public class VM {
    public var operandStack: OperandStack
    public var controlStack: ControlStack
    public var module: Module
    public var memory: Memory
    public var globals: [GlobalVar]
    public var funcs: [Function]
    public var table: Table?
    
    /// [Optional] This field records the position of the first local
    /// variable of the current function (if there is a parameter, then
    /// this is the first parameter) in the operand stack. It is used to
    /// implement local variable instructions.
    /// This field is not necessary, because its value can be obtained
    /// from the call frame of the current function.
    public var local0Index: UInt32
    
    // MARK: Hook
    /// for hooking
    public var hookDict: [FuncIdx: String]? = nil
    /// to record the size passed to the current `malloc` function
    public var currentMallocedSize: UInt64? = nil
    /// to record the pointer passed to the current `free` function
    public var currentFreedPointer: UInt64? = nil
    
    public init(module: Module) {
        self.module = module
        operandStack = OperandStack()
        // init memory
        if let memSec = module.memSec,
           memSec.count > 0 {
            memory = Memory(memoryType: memSec[0])
        } else {
            // TODO: ???
            let tag: LimitsTag = .minMax
            let type = MemType(tag: tag, min: 1000, max: UInt32(MAX_PAGE_COUNT))
            memory = Memory(memoryType: type)
        }
        funcs = [Function]()
        controlStack = ControlStack(frames: [ControlFrame]())
        globals = [GlobalVar]()
        local0Index = 0
        initMemory()
        initGlobals()
        initFuncs()
        initTable()
        if let startSec = module.startSec {
            call(funcIdx: startSec)
        } else {
            guard let exportSec = module.exportSec else { fatalError() }
            for exp in exportSec {
//                if exp.desc.tag == .func && exp.name == "__wasm_call_ctors" {
//                    call(funcIdx: exp.desc.idx)
//                    break
//                }
                if exp.desc.tag == .func && exp.name == "main" {
                    call(funcIdx: exp.desc.idx)
                    break
                }
            }
        }
    }
    
    func initMemory() {
        if let dataSec = module.dataSec {
            for data in dataSec {
                for instr in data.offset {
                    execInstr(instr)
                }
                memory.write(offset: operandStack.popU64(), data: data.`init`)
            }
        }
    }
    
    func initGlobals() {
        guard let globalSec = module.globalSec else { return }
        for global in globalSec {
            for instr in global.`init` {
                execInstr(instr)
            }
            let globalVal = GlobalVar(type: global.type, val: operandStack.popU64())
            globals.append(globalVal)
        }
    }
    
    func initFuncs() {
        linkNativeFuncs()
        if let funcSec = module.funcSec {
            let existingFuncCount = funcs.count
            for (i, typeIdx) in funcSec.enumerated() {
                guard let funcType = module.typeSec?[Int(typeIdx)] else { continue }
                guard let code = module.codeSec?[i] else { continue }
                let funcIdx = FuncIdx(i + existingFuncCount)
                let function = Function(funcIdx, type: funcType, code: code)
                funcs.append(function)
            }
        }
    }
    
    func linkNativeFuncs() {
        if let importSec = module.importSec {
            for imp in importSec {
                if imp.desc.tag == .func && imp.module == "env" {
                    guard let typeIdx = imp.desc.funcType else { continue }
                    guard let funcType = module.typeSec?[Int(typeIdx)] else { continue }
                    switch imp.name {
                    case "print_char":
                        let function = Function(type: funcType, swiftFunc: printChar)
                        funcs.append(function)
                    case "print_int":
                        let function = Function(type: funcType, swiftFunc: printInt)
                        funcs.append(function)
                    case "assert_true":
                        let function = Function(type: funcType, swiftFunc: assertTrue)
                        funcs.append(function)
                    case "assert_false":
                        let function = Function(type: funcType, swiftFunc: assertFalse)
                        funcs.append(function)
                    case "assert_eq_i32":
                        let function = Function(type: funcType, swiftFunc: assertEqI32)
                        funcs.append(function)
                    case "assert_eq_i64":
                        let function = Function(type: funcType, swiftFunc: assertEqI64)
                        funcs.append(function)
                    case "assert_eq_f32":
                        let function = Function(type: funcType, swiftFunc: assertEqF32)
                        funcs.append(function)
                    case "assert_eq_f64":
                        let function = Function(type: funcType, swiftFunc: assertEqF64)
                        funcs.append(function)
                    default:
                        fatalError("Native funcs no found")
                    }
                }
            }
        }
    }
    
    func initTable() {
        if let tableSec = module.tableSec,
           tableSec.count > 0 {
            table = Table(type: tableSec[0], elems: [])
        }
        if let elemSec = module.elemSec {
            for elem in elemSec {
                let tableType = TableType(limits: Limits(tag: .min, min: 0))
                table = Table(type: tableType, elems: [])
                for instr in elem.offset {
                    execInstr(instr)
                }
                // TODO:
//                let offset = operandStack.popU32()
                for (_, funcIdx) in elem.`init`.enumerated() {
                    let function = funcs[Int(funcIdx)]
                    table?.elems.append(function)
                }
            }
        }
    }
}

extension VM {
    
    // MARK: - block stack
    func enterBlock(opcode: Opcode, funcType: FuncType, instrs: [Instruction], function: Function? = nil) {
        var basePointer = operandStack.size() - funcType.paramTypes.count
        if basePointer < 0 {
            basePointer = 0
        }
        let controlFrame = ControlFrame(opcode: opcode, blockType: funcType, instrs: instrs, bp: basePointer, pc: 0, function: function)
        controlStack.pushControlFrame(controlFrame)
        if opcode == .call {
            local0Index = UInt32(basePointer)
        }
    }
    
    func exitBlock() {
        let controlFrame = controlStack.popControlFrame()
        clearBlock(controlFrame)
    }
    
    func clearBlock(_ controlFrame: ControlFrame) {
        let results = operandStack.popU64s(controlFrame.blockType.resultTypes.count)
        operandStack.popU64s(operandStack.size() - controlFrame.bp)
        operandStack.pushU64s(results)
        if controlFrame.opcode == .call && controlStack.controlDepth() > 0 {
            let (lastCallFrame, _) = controlStack.topCallFrame()
            if let lastCallFrame = lastCallFrame {
                local0Index = UInt32(lastCallFrame.bp)
            }
        }
        // MARK: Hook
        // get the return results of the hooked function
        if let hookDict = hookDict,
           let function = controlFrame.function {
            // vm is exiting function
            for (funcIndex, funcName) in hookDict {
                if funcIndex == function.index {
                    // hook function
                    let resultCount = function.type.resultTypes.count
                    let results = operandStack.getTopOperands(resultCount)
                    log("🪝 The result of the hooked \(funcName) is \(results)", .native, .ins)
                    // hardcode
                    if funcName == "malloc" {
                        guard let size = currentMallocedSize else {
                            fatalError("cannot get malloc size")
                        }
                        guard let pointer = results.first else {
                            fatalError("cannot get freed pointer")
                        }
                        let mallocRange = (Int(pointer), Int(pointer + size))
                        log("🪝 the malloced range is \(mallocRange)", .native, .ins)
                        memory.mallocDict.append(mallocRange)
                        currentMallocedSize = nil
                        memory.isStopCheckingMemory = false
                    } else if funcName == "free" {
                        guard let pointer = currentFreedPointer else {
                            fatalError("cannot get freed pointer")
                        }
                        var mallocIndex: Int? = nil
                        for (i, mallocRange) in memory.mallocDict.enumerated() {
                            if mallocRange.0 == pointer {
                                mallocIndex = i
                            }
                        }
                        if let index = mallocIndex {
                            let mallocRange = memory.mallocDict[index]
                            log("🪝 the freed range is \(mallocRange)", .native, .ins)
                            memory.mallocDict.remove(at: index)
                        } else {
                            log("🪝 cannot find malloced range started at \(pointer)", .native, .warning)
                        }
                        currentFreedPointer = nil
                        memory.isStopCheckingMemory = false
                    }
                }
            }
        }
    }
    
    func resetBlock(_ controlFrame: ControlFrame) {
        let results = operandStack.popU64s(controlFrame.blockType.paramTypes.count)
        operandStack.popU64s(operandStack.size() - controlFrame.bp)
        operandStack.pushU64s(results)
    }
    
    // MARK: - loop
    
    public func loop() {
        // MARK: Hook
        if hookDict == nil {
            // don't need to hook
            // no need to check memory
            memory.isStopCheckingMemory = true
        }
        
        let depth = controlStack.controlDepth()
        while controlStack.controlDepth() >= depth {
            guard var controlFrame = controlStack.topControlFrame else {
                fatalError()
            }
            if controlFrame.pc == controlFrame.instrs.count {
                exitBlock()
            } else {
                let instr = controlFrame.instrs[controlFrame.pc]
                controlFrame.pc += 1
                controlStack.topControlFrame = controlFrame
                execInstr(instr)
            }
        }
    }
    
    func execInstr(_ instr: Instruction) {
        // print
        if let args = instr.args {
            print("\(instr.opcode) \(args)")
        } else {
            print("\(instr.opcode)")
        }
        
        switch instr.opcode {
        // MARK: Control Instructions
        case .unreachable:
            unreachable()
        case .nop:
            nop()
        case .block:
            let blockArgs = instr.args as! BlockArgs
            block(blockArgs)
        case .loop:
            let blockArgs = instr.args as! BlockArgs
            loop(blockArgs)
        case .if:
            let ifArgs = instr.args as! IfArgs
            self.if(ifArgs)
        case .else:
            break
        case .end:
            break
        case .br:
            let labelIdx = instr.args as! LabelIdx
            br(labelIdx)
        case .brIf:
            let labelIdx = instr.args as! LabelIdx
            brIf(labelIdx)
        case .brTable:
            let brTableArgs = instr.args as! BrTableArgs
            brTable(brTableArgs)
        case .return:
            self.return()
        case .call:
            let funcIndex = instr.args as! FuncIdx
            call(funcIdx: funcIndex)
        case .callIndirect:
            let typeIdx = instr.args as! TypeIdx
            callIndirect(typeIdx)
        
        // MARK: Parametric Instructions
        case .drop:
            drop()
        case .select:
            select()
            
        // MARK: Variable Instructions
        case .localGet:
            let localIndex = instr.args as! LocalIdx
            localGet(index: localIndex)
        case .localSet:
            let localIndex = instr.args as! LocalIdx
            localSet(index: localIndex)
        case .localTee:
            let localIndex = instr.args as! LocalIdx
            localTee(index: localIndex)
        case .globalGet:
            let globalIndex = instr.args as! GlobalIdx
            globalGet(index: globalIndex)
        case .globalSet:
            let globalIndex = instr.args as! GlobalIdx
            globalSet(index: globalIndex)
            
        // MARK: Memory Instructions
        case .i32Load:
            let memArg = instr.args as! MemArg
            i32Load(memArg: memArg)
        case .i64Load:
            let memArg = instr.args as! MemArg
            i64Load(memArg: memArg)
        case .f32Load:
            let memArg = instr.args as! MemArg
            f32Load(memArg: memArg)
        case .f64Load:
            let memArg = instr.args as! MemArg
            f64Load(memArg: memArg)
        case .i32Load8S:
            let memArg = instr.args as! MemArg
            i32Load8S(memArg: memArg)
        case .i32Load8U:
            let memArg = instr.args as! MemArg
            i32Load8U(memArg: memArg)
        case .i32Load16S:
            let memArg = instr.args as! MemArg
            i32Load16S(memArg: memArg)
        case .i32Load16U:
            let memArg = instr.args as! MemArg
            i32Load16U(memArg: memArg)
        case .i64Load8S:
            let memArg = instr.args as! MemArg
            i64Load8S(memArg: memArg)
        case .i64Load8U:
            let memArg = instr.args as! MemArg
            i64Load8U(memArg: memArg)
        case .i64Load16S:
            let memArg = instr.args as! MemArg
            i64Load16S(memArg: memArg)
        case .i64Load16U:
            let memArg = instr.args as! MemArg
            i64Load16U(memArg: memArg)
        case .i64Load32S:
            let memArg = instr.args as! MemArg
            i64Load32S(memArg: memArg)
        case .i64Load32U:
            let memArg = instr.args as! MemArg
            i64Load32U(memArg: memArg)
        case .i32Store:
            let memArg = instr.args as! MemArg
            i32Store(memArg: memArg)
        case .i64Store:
            let memArg = instr.args as! MemArg
            i64Store(memArg: memArg)
        case .f32Store:
            let memArg = instr.args as! MemArg
            f32Store(memArg: memArg)
        case .f64Store:
            let memArg = instr.args as! MemArg
            f64Store(memArg: memArg)
        case .i32Store8:
            let memArg = instr.args as! MemArg
            i32Store8(memArg: memArg)
        case .i32Store16:
            let memArg = instr.args as! MemArg
            i32Store16(memArg: memArg)
        case .i64Store8:
            let memArg = instr.args as! MemArg
            i64Store8(memArg: memArg)
        case .i64Store16:
            let memArg = instr.args as! MemArg
            i64Store16(memArg: memArg)
        case .i64Store32:
            let memArg = instr.args as! MemArg
            i64Store32(memArg: memArg)
        case .memorySize:
            memorySize()
        case .memoryGrow:
            memoryGrow()

        // MARK: Numeric Instructions
        case .i32Const:
            let arg = instr.args as! Int32
            i32Const(arg)
        case .i64Const:
            let arg = instr.args as! Int64
            i64Const(arg)
        case .f32Const:
            let arg = instr.args as! Float32
            f32Const(arg)
        case .f64Const:
            let arg = instr.args as! Float64
            f64Const(arg)
        case .i32Eqz:
            i32Eqz()
        case .i32Eq:
            i32Eq()
        case .i32Ne:
            i32Ne()
        case .i32LtS:
            i32LtS()
        case .i32LtU:
            i32LtU()
        case .i32GtS:
            i32GtS()
        case .i32GtU:
            i32GtU()
        case .i32LeS:
            i32LeS()
        case .i32LeU:
            i32LeU()
        case .i32GeS:
            i32GeS()
        case .i32GeU:
            i32GeU()
        case .i64Eqz:
            i64Eqz()
        case .i64Eq:
            i64Eq()
        case .i64Ne:
            i64Ne()
        case .i64LtS:
            i64LtS()
        case .i64LtU:
            i64LtU()
        case .i64GtS:
            i64GtS()
        case .i64GtU:
            i64GtU()
        case .i64LeS:
            i64LeS()
        case .i64LeU:
            i64LeU()
        case .i64GeS:
            i64GeS()
        case .i64GeU:
            i64GeU()
        case .f32Eq:
            f32Eq()
        case .f32Ne:
            f32Ne()
        case .f32Lt:
            f32Lt()
        case .f32Gt:
            f32Gt()
        case .f32Le:
            f32Le()
        case .f32Ge:
            f32Ge()
        case .f64Eq:
            f64Eq()
        case .f64Ne:
            f64Ne()
        case .f64Lt:
            f64Lt()
        case .f64Gt:
            f64Gt()
        case .f64Le:
            f64Le()
        case .f64Ge:
            f64Ge()
        case .i32Clz:
            i32Clz()
        case .i32Ctz:
            i32Ctz()
        case .i32PopCnt:
            i32PopCnt()
        case .i32Add:
            i32Add()
        case .i32Sub:
            i32Sub()
        case .i32Mul:
            i32Mul()
        case .i32DivS:
            i32DivS()
        case .i32DivU:
            i32DivU()
        case .i32RemS:
            i32RemS()
        case .i32RemU:
            i32RemU()
        case .i32And:
            i32And()
        case .i32Or:
            i32Or()
        case .i32Xor:
            i32Xor()
        case .i32Shl:
            i32Shl()
        case .i32ShrS:
            i32ShrS()
        case .i32ShrU:
            i32ShrU()
        case .i32Rotl:
            i32Rotl()
        case .i32Rotr:
            i32Rotr()
        case .i64Clz:
            i64Clz()
        case .i64Ctz:
            i64Ctz()
        case .i64PopCnt:
            i64PopCnt()
        case .i64Add:
            i64Add()
        case .i64Sub:
            i64Sub()
        case .i64Mul:
            i64Mul()
        case .i64DivS:
            i64DivS()
        case .i64DivU:
            i64DivU()
        case .i64RemS:
            i64RemS()
        case .i64RemU:
            i64RemU()
        case .i64And:
            i64And()
        case .i64Or:
            i64Or()
        case .i64Xor:
            i64Xor()
        case .i64Shl:
            i64Shl()
        case .i64ShrS:
            i64ShrS()
        case .i64ShrU:
            i64ShrU()
        case .i64Rotl:
            i64Rotl()
        case .i64Rotr:
            i64Rotr()
        case .f32Abs:
            f32Abs()
        case .f32Neg:
            f32Neg()
        case .f32Ceil:
            f32Ceil()
        case .f32Floor:
            f32Floor()
        case .f32Trunc:
            f32Trunc()
        case .f32Nearest:
            f32Nearest()
        case .f32Sqrt:
            f32Sqrt()
        case .f32Add:
            f32Add()
        case .f32Sub:
            f32Sub()
        case .f32Mul:
            f32Mul()
        case .f32Div:
            f32Div()
        case .f32Min:
            f32Min()
        case .f32Max:
            f32Max()
        case .f32CopySign:
            f32CopySign()
        case .f64Abs:
            f64Abs()
        case .f64Neg:
            f64Neg()
        case .f64Ceil:
            f64Ceil()
        case .f64Floor:
            f64Floor()
        case .f64Trunc:
            f64Trunc()
        case .f64Nearest:
            f64Nearest()
        case .f64Sqrt:
            f64Sqrt()
        case .f64Add:
            f64Add()
        case .f64Sub:
            f64Sub()
        case .f64Mul:
            f64Mul()
        case .f64Div:
            f64Div()
        case .f64Min:
            f64Min()
        case .f64Max:
            f64Max()
        case .f64CopySign:
            f64CopySign()
        case .i32WrapI64:
            i32WrapI64()
        case .i32TruncF32S:
            i32TruncF32S()
        case .i32TruncF32U:
            i32TruncF32U()
        case .i32TruncF64S:
            i32TruncF64S()
        case .i32TruncF64U:
            i32TruncF64U()
        case .i64ExtendI32S:
            i64ExtendI32S()
        case .i64ExtendI32U:
            i64ExtendI32U()
        case .i64TruncF32S:
            i64TruncF32S()
        case .i64TruncF32U:
            i64TruncF32U()
        case .i64TruncF64S:
            i64TruncF64S()
        case .i64TruncF64U:
            i64TruncF64U()
        case .f32ConvertI32S:
            f32ConvertI32S()
        case .f32ConvertI32U:
            f32ConvertI32U()
        case .f32ConvertI64S:
            f32ConvertI64S()
        case .f32ConvertI64U:
            f32ConvertI64U()
        case .f32DemoteF64:
            f32DemoteF64()
        case .f64ConvertI32S:
            f64ConvertI32S()
        case .f64ConvertI32U:
            f64ConvertI32U()
        case .f64ConvertI64S:
            f64ConvertI64S()
        case .f64ConvertI64U:
            f64ConvertI64U()
        case .f64PromoteF32:
            f64PromoteF32()
        case .i32ReinterpretF32:
            i32ReinterpretF32()
        case .i64ReinterpretF64:
            i64ReinterpretF64()
        case .f32ReinterpretI32:
            f32ReinterpretI32()
        case .f64ReinterpretI64:
            f64ReinterpretI64()
        case .i32Extend8S:
            i32Extend8S()
        case .i32Extend16S:
            i32Extend16S()
        case .i64Extend8S:
            i64Extend8S()
        case .i64Extend16S:
            i64Extend16S()
        case .i64Extend32S:
            i64Extend32S()
        case .truncSat:
            break
        }
    }
}
