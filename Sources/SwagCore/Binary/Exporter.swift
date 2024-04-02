//
//  Exporter.swift
//  SwagCore
//
//  Created by Jianing Wang on 4/1/24.
//

import Foundation

public struct Exporter {
    
    public init() {}
    
}

extension Exporter {
    
    func exportMemory(_ memory: Memory) -> [Byte] {
        var data = [Byte]()
        
        // memory type
        let memTypeCount = encodeVarUInt(UInt32(1))
        let memTypeBytes = exportMemType(memory.type)
        
        // memory data
        // TODO: Optimize the compression of memory data
        // 1. remove the nil in the tail
        // 2. replace the nil in the middle with 0
        var memData = [Byte]()
        var i = 0
        for byte in memory.data.reversed() {
            if byte == nil {
                i += 1
            } else {
                break
            }
        }
        memData.append(contentsOf: memory.data[0..<(memory.data.count - i)].map { $0 ?? 0 })
        let dataLength = encodeVarUInt(UInt64(memData.count))
        
        let memLength = encodeVarUInt(UInt64(memTypeCount.count + memTypeBytes.count + dataLength.count + memData.count))
        
        data.append(SnapshotSectionID.memory.rawValue)
        data.append(contentsOf: memLength)
        data.append(contentsOf: memTypeCount)
        data.append(contentsOf: memTypeBytes)
        data.append(contentsOf: dataLength)
        data.append(contentsOf: memData)
        
        return data
    }
    
    func exportMemType(_ memType: MemType) -> [Byte] {
        return exportLimits(memType)
    }
    
    func exportLimits(_ limits: Limits) -> [Byte] {
        var data = [Byte]()
        data.append(limits.tag.rawValue)
        data.append(contentsOf: encodeVarUInt(limits.min))
        if let max = limits.max {
            data.append(contentsOf: encodeVarUInt(max))
        }
        return data
    }
}
