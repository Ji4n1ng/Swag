//
//  Memory.swift
//  wasm.swift
//
//  Created by Jianing Wang on 2021/1/19.
//

import Foundation

public struct Memory {
    var type: MemType
    var data: [Byte?]
    
    init(memoryType: MemType) {
        self.type = memoryType
        self.data = Array<Byte?>.init(repeating: nil, count: Int(memoryType.min) * PAGE_SIZE)
    }
    
    func size() -> UInt32 {
        return UInt32(self.data.count / PAGE_SIZE)
    }
    
    mutating func grow(_ n: UInt32) -> UInt32 {
        let oldSize = size()
        if n == 0 {
            return oldSize
        }
        var maxPageCount = UInt32(MAX_PAGE_COUNT)
        if let max = type.max,
           max > 0 {
            maxPageCount = max
        }
        let newSize = oldSize + n
        if newSize > maxPageCount {
            return 0xFFFFFFFF // -1
        }
        // TODO: copy?
        var newData = Array<Byte?>.init(repeating: nil, count: Int(newSize) * PAGE_SIZE)
        for (offset, element) in data.enumerated() {
            newData[offset] = element
        }
        self.data = newData
        return oldSize
    }
    
    func checkOffset(offset: UInt64, length: Int) {
        if (self.data.count - length) < Int(offset) {
            fatalError("MemoryOutOfBounds")
        }
    }
    
    func read(offset: UInt64, buf: inout [Byte?]) {
        checkOffset(offset: offset, length: buf.count)
        let startIndex = Int(offset)
        let endIndex = startIndex + buf.count
        let dataSlice = data[startIndex..<endIndex]
        buf = Array(dataSlice)
    }
    
    mutating func write(offset: UInt64, data: [Byte]) {
        checkOffset(offset: offset, length: data.count)
        let startIndex = Int(offset)
        let endIndex = startIndex + data.count
        let subrange = startIndex..<endIndex
        self.data.replaceSubrange(subrange, with: data)
    }
    
}
