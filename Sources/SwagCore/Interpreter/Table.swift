//
//  Table.swift
//  SwagCore
//
//  Created by Jianing Wang on 2021/2/12.
//

import Foundation

public struct Table {
    var type: TableType
    var elems: [Function]
}

extension Table {
    func size() -> UInt32 {
        return UInt32(elems.count)
    }
    
    func getElem(_ idx: UInt32) -> Function {
        checkIdx(idx)
        let elem = elems[Int(idx)]
        return elem
    }
    
    mutating func setElem(_ idx: UInt32, elem: Function) {
        checkIdx(idx)
        elems[Int(idx)] = elem
    }
    
    func checkIdx(_ idx: UInt32) {
        if idx >= UInt32(elems.count) {
            fatalError()
        }
    }
}
