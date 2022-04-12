//
//  Function.swift
//  SwagCore
//
//  Created by Jianing Wang on 2021/2/9.
//

import Foundation

public struct WasmVal {
    var type: ValType
    var val: Any
}
public typealias SwiftFunc = ([WasmVal]) throws -> [WasmVal]

public struct Function {
    var index: FuncIdx
    var type: FuncType
    var code: Code?
    var swiftFunc: SwiftFunc?
    
    /// init external func
    init(type: FuncType, swiftFunc: @escaping SwiftFunc) {
        self.index = 0 // ?
        self.type = type
        self.swiftFunc = swiftFunc
    }
    
    /// init internal func
    init(_ index: FuncIdx, type: FuncType, code: Code) {
        self.index = index
        self.type = type
        self.code = code
    }
}
