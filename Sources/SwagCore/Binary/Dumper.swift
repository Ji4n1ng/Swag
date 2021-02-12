//
//  Dumper.swift
//  Swag
//
//  Created by Jianing Wang on 2021/1/28.
//

import Foundation

public struct Dumper {
    public var module: Module
    public var importedFuncCount: Int = 0
    public var importedTableCount: Int = 0
    public var importedMemCount: Int = 0
    public var importedGlobalCount: Int = 0
    
    public init(module: Module) {
        self.module = module
    }
}

public extension Dumper {
    
    mutating func dump() {
        print("Version: 0x\(module.version)")
        dumpTypeSec()
        dumpImportSec()
        dumpFuncSec()
        dumpTableSec()
        dumpMemSec()
        dumpGlobalSec()
        dumpExportSec()
        dumpStartSec()
        dumpElemSec()
        dumpCodeSec()
        dumpDataSec()
        dumpCustomSec()
    }
    
    func dumpTypeSec() {
        guard let typeSec = module.typeSec else {
            print("No type sec")
            return
        }
        print("Type[\(typeSec.count)]:")
        for (i, funcType) in typeSec.enumerated() {
            print("  type[\(i)]: \(funcType)")
        }
    }
    
    mutating func dumpImportSec() {
        guard let importSec = module.importSec else {
            print("No import sec")
            return
        }
        print("Import[\(importSec.count)]:")
        for imp in importSec {
            switch imp.desc.tag {
            case .func:
                print("  func[\(importedFuncCount)]: \(imp.module) \(imp.name), \(String(describing: imp.desc.funcType))")
                importedFuncCount += 1
            case .table:
                print("  table[\(importedTableCount)]: \(imp.module) \(imp.name), \(String(describing: imp.desc.table?.limits))")
                importedTableCount += 1
            case .mem:
                print("  mem[\(importedMemCount)]: \(imp.module) \(imp.name), \(String(describing: imp.desc.mem))")
                importedMemCount += 1
            case .global:
                print("  global[\(importedGlobalCount)]: \(imp.module) \(imp.name), \(String(describing: imp.desc.global))")
                importedGlobalCount += 1
            }
        }
    }
    
    func dumpFuncSec() {
        guard let funcSec = module.funcSec else {
            print("No func sec")
            return
        }
        print("Function[\(funcSec.count)]:")
        for (i, sig) in funcSec.enumerated() {
            print("  func[\(importedFuncCount + i)]: sig=\(sig)")
        }
    }
    
    func dumpTableSec() {
        guard let tableSec = module.tableSec else {
            print("No table sec")
            return
        }
        print("Table[\(tableSec.count)]:")
        for (i, t) in tableSec.enumerated() {
            print("  table[\(importedTableCount + i)]: \(t.limits)")
        }
    }
    
    func dumpMemSec() {
        guard let memSec = module.memSec else {
            print("No mem sec")
            return
        }
        print("Memory[\(memSec.count)]:")
        for (i, limits) in memSec.enumerated() {
            print("  memory[\(importedMemCount + i)]: \(limits)")
        }
    }
    
    func dumpGlobalSec() {
        guard let globalSec = module.globalSec else {
            print("No global sec")
            return
        }
        print("Global[\(globalSec.count)]:")
        for (i, g) in globalSec.enumerated() {
            print("  global[\(importedGlobalCount + i)]: \(g.type)")
        }
    }
    
    func dumpExportSec() {
        guard let exportSec = module.exportSec else {
            print("No export sec")
            return
        }
        print("Export[\(exportSec.count)]:")
        for exp in exportSec {
            switch exp.desc.tag {
            case .func:
                print("  func[\(exp.desc.idx)]: \(exp.name)")
            case .table:
                print("  table[\(exp.desc.idx)]: \(exp.name)")
            case .mem:
                print("  memory[\(exp.desc.idx)]: \(exp.name)")
            case .global:
                print("  global[\(exp.desc.idx)]: \(exp.name)")
            }
        }
    }
    
    func dumpStartSec() {
        guard let startSec = module.startSec else {
            print("No start sec")
            return
        }
        print("Start:")
        print("  func=\(startSec)")
    }
    
    func dumpElemSec() {
        guard let elemSec = module.elemSec else {
            print("No element sec")
            return
        }
        print("Element[\(elemSec.count)]:")
        for (i, elem) in elemSec.enumerated() {
            // TODO
            print("  elem[\(importedGlobalCount + i)]: \(elem.table)")
        }
    }
    
    func dumpCodeSec() {
        guard let codeSec = module.codeSec else {
            print("No code sec")
            return
        }
        print("Code[\(codeSec.count)]:")
        for (i, code) in codeSec.enumerated() {
            // TODO
            var localsStr = ""
            for (i, locals) in code.locals.enumerated() {
                if i > 0 {
                    localsStr += ", "
                }
                localsStr += "\(locals.type) x \(locals.n)"
            }
            print("  func[\(importedFuncCount + i)]: locals=[\(localsStr)]")
            dumpExpr(indentation: "    ", expr: code.expr)
        }
    }
    
    func dumpDataSec() {
        guard let dataSec = module.dataSec else {
            print("No data sec")
            return
        }
        print("Data[\(dataSec.count)]:")
        for (i, data) in dataSec.enumerated() {
            // TODO
            print("  data[\(i)]: mem=\(data.mem)")
        }
    }
    
    func dumpCustomSec() {
        guard let customSecs = module.customSecs else {
            print("No custom sec")
            return
        }
        print("Custom[\(customSecs.count)]:")
        for (i, custom) in customSecs.enumerated() {
            // TODO
            print("  custom[\(i)]: name=\(custom.name)")
        }
    }
    
    func dumpExpr(indentation: String, expr: Expr) {
        for (_, instr) in expr.enumerated() {
            switch instr.opcode {
            case .block, .loop:
                guard let args = instr.args as? BlockArgs else {
                    fatalError()
                }
                let bt = module.getFuncType(bt: args.blockType)
                print("\(indentation)\(instr.opcode) \(bt)")
                dumpExpr(indentation: indentation + "  ", expr: args.instrutions)
                print("\(indentation)end")
            case .if:
                guard let args = instr.args as? IfArgs else {
                    fatalError()
                }
                let bt = module.getFuncType(bt: args.blockType)
                print("\(indentation)if \(bt)")
                dumpExpr(indentation: indentation + "  ", expr: args.instrutions1)
                if let instrs2 = args.instrutions2 {
                    print("\(indentation)else")
                    dumpExpr(indentation: indentation + "  ", expr: instrs2)
                }
                print("\(indentation)end")
            default:
                if let args = instr.args {
                    print("\(indentation)\(instr.opcode) \(args)")
                } else {
                    print("\(indentation)\(instr.opcode)")
                }
            }
        }
    }
}
