//
//  TagUtilities.swift
//  Amii
//
//  Created by Amy Collector on 13/06/2020.
//  Copyright © 2020 Amy Collector. All rights reserved.
//

import Foundation

struct TagUtility {
    static let PAGE_SIZE: Int = 4
    static let FULL_DATA_SIZE: Int = 540

    static func splitPages(_ tagData: Data) -> [Data] {
        let pagesCount = tagData.count / TagUtility.PAGE_SIZE

        var pages = Array<Data>()
        
        for i in 0..<pagesCount {
            pages.append(tagData.subdata(in: i..<(i+TagUtility.PAGE_SIZE + 1)))
        }
        
        return pages
    }
    
    static func validateTag(_ tagData: Data) -> Bool {
        
        #if DEBUG && targetEnvironment(simulator)
        return true
        #endif

        // tag start
        if tagData.page(0)[0] != 4 {
            return false
        }
        
        let lock = tagData.page(2)
        // lock signature
        if lock[2] != 0x0F || lock[3] != 0xE0 {
            return false
        }
        
        let cc = tagData.page(3)
        // CC signature
        if cc[0] != 0xF1 || cc[1] != 0x10 || cc[2] != 0xFF || cc[3] != 0xEE {
            return false
        }
        
        let dynamic = tagData.page(0x82)
        // dynamic lock signature
        if dynamic[0] != 0x01 || dynamic[1] != 0x0 || dynamic[2] != 0x0F {
            return false
        }
        
        let cfg0 = tagData.page(0x83)
        // CFG0 signature
        if cfg0[0] != 0x0 || cfg0[1] != 0x0 || cfg0[2] != 0x0 || cfg0[3] != 0x04 {
            return false
        }
        
        let cfg1 = tagData.page(0x84)
        // CFG1 signature
        if cfg1[0] != 0x5F || cfg1[1] != 0x0 || cfg1[2] != 0x0 || cfg1[3] != 0x00 {
            return false
        }
        
        return true
    }

    static func keygen(_ uid: Data) -> Data? {
        if uid.count == 7 {
            var pwd = Data(count: 4)
            
            pwd[0] = uid[1] ^ uid[3] ^ 0xAA
            pwd[1] = uid[2] ^ uid[4] ^ 0x55
            pwd[2] = uid[3] ^ uid[5] ^ 0xAA
            pwd[3] = uid[4] ^ uid[6] ^ 0x55
            
            return pwd
        }
        
        return nil
    }
}

struct MifareCommands {
    static let READ: UInt8 = 0x30
    static let WRITE: UInt8 = 0xA2
    static let PWD_AUTH: UInt8 = 0x1B
}

struct Ntag215Pages {
    static let STATIC_LOCK_BITS: UInt8 = 2
    static let CAPABILITY_CONTAINER: UInt8 = 3
    static let USER_MEMORY_FIRST: UInt8 = 4
    static let MODEL_HEAD: UInt8 = 21
    static let MODEL_TAIL: UInt8 = 22
    static let USER_MEMORY_LAST: UInt8 = 129
    static let DYNAMIC_LOCK_BITS: UInt8 = 130
    static let CONFIG0: UInt8 = 131
    static let CONFIG1: UInt8 = 132
    static let PASSWORD: UInt8 = 133
    static let PACK: UInt8 = 134
    static let TOTAL: UInt8 = 135
}

struct Ntag215Data {
    static let STATIC_LOCK_BITS = Data([0x00, 0x00, 0x0f, 0xe0])
    static let COMPATIBILITY_CONTAINER = Data([0xf1, 0x10, 0xff, 0xee])
    static let DYNAMIC_LOCK_BITS = Data([0x01, 0x00, 0x0f, 0xbd])
    static let CONFIG0 = Data([0x00, 0x00, 0x00, 0x04])
    static let CONFIG1 = Data([0x5f, 0x00, 0x00, 0x00])
    static let PACK = Data([0x80, 0x80, 0x00, 0x00])
}
