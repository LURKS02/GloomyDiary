//
//  Extension+Bundle.swift
//  GloomyDiary
//
//  Created by 디해 on 5/4/25.
//

import Foundation

extension Bundle {
    var isAppStore: Bool {
        return !isTestFlight && !isSimulator
    }
    
    var isTestFlight: Bool {
        return appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
