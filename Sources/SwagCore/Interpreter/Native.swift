//
//  Native.swift
//  SwagCore
//
//  Created by Jianing Wang on 2021/2/9.
//

import Foundation

// MARK: - Native

enum LogPosition: String {
    case native = "🐦"
    case wasm = "🟪"
}

enum LogType: String {
    case ln = "✏️"
    case right = "✅"
    case wrong = "❌"
    case warning = "❗️"
    case date = "🕒"
    case url = "🌏"
    case json = "💡"
    case fuck = "🖕"
    case happy = "😄"
}

func log<T>(_ message: T,
            _ position: LogPosition = .native,
            _ type: LogType = .ln,
            file: String = #file,
            method: String = #function,
            line: Int    = #line) {
    #if DEBUG
        print("\(position.rawValue) \(type.rawValue) \((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}


func printChar(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let arg = args.first else { fatalError() }
    guard let val = arg.val as? Int32 else { fatalError() }
    guard let unicodeScalar = UnicodeScalar(Int(val)) else { fatalError() }
    let character = Character(unicodeScalar)
    log(character)
    return []
}

func printInt(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let arg = args.first else { fatalError() }
    guard let val = arg.val as? Int32 else { fatalError() }
    log(val)
    return []
}

func assertTrue(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let val = args.first?.val as? Int32 else { fatalError() }
    assertEq(val, 1)
    return []
}

func assertFalse(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let val = args.first?.val as? Int32 else { fatalError() }
    assertEq(val, 0)
    return []
}

func assertEq(_ args: [WasmVal]) throws -> [WasmVal] {
    let arg0 = args[0]
    let arg1 = args[1]
    guard arg0.type == arg1.type else { fatalError() }
    switch arg0.type {
    case .i32:
        guard let val0 = arg0.val as? Int32 else { fatalError() }
        guard let val1 = arg1.val as? Int32 else { fatalError() }
        assertEq(val0, val1)
    case .i64:
        guard let val0 = arg0.val as? Int64 else { fatalError() }
        guard let val1 = arg1.val as? Int64 else { fatalError() }
        assertEq(val0, val1)
    case .f32:
        guard let val0 = arg0.val as? Float32 else { fatalError() }
        guard let val1 = arg1.val as? Float32 else { fatalError() }
        assertEq(val0, val1)
    case .f64:
        guard let val0 = arg0.val as? Float64 else { fatalError() }
        guard let val1 = arg1.val as? Float64 else { fatalError() }
        assertEq(val0, val1)
    }
    return []
}

func assertEqI32(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let val0 = args[0].val as? Int32 else { fatalError() }
    guard let val1 = args[1].val as? Int32 else { fatalError() }
    assertEq(val0, val1)
    return []
}

func assertEqI64(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let val0 = args[0].val as? Int64 else { fatalError() }
    guard let val1 = args[1].val as? Int64 else { fatalError() }
    assertEq(val0, val1)
    return []
}

func assertEqF32(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let val0 = args[0].val as? Float32 else { fatalError() }
    guard let val1 = args[1].val as? Float32 else { fatalError() }
    assertEq(val0, val1)
    return []
}

func assertEqF64(_ args: [WasmVal]) throws -> [WasmVal] {
    guard let val0 = args[0].val as? Float64 else { fatalError() }
    guard let val1 = args[1].val as? Float64 else { fatalError() }
    assertEq(val0, val1)
    return []
}

func assertEq<T: Equatable>(_ a: T, _ b: T) {
    if a == b {
        log("\(a) == \(b)", .native, .right)
    } else {
        log("\(a) != \(b)", .native, .wrong)
    }
}
