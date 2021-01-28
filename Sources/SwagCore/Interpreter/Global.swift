//
//  Global.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/25.
//

import Foundation

public struct GlobalVar {
    var type: GlobalType
    var val: UInt64 {
        willSet {
            if self.type.mut == .const {
                fatalError("Immutable Global")
            }
        }
    }
}
