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
    var type: FuncType
    var code: Code?
    var swiftFunc: SwiftFunc?
    
    /// init external func
    init(_ funcType: FuncType, swiftFunc: @escaping SwiftFunc) {
        self.type = funcType
        self.swiftFunc = swiftFunc
    }
    
    /// init internal func
    init(_ funcType: FuncType, code: Code) {
        self.type = funcType
        self.code = code
    }
}
