//
//  Utility.swift
//  FingerPushExample
//
//  Copyright © 2020 kissoft. All rights reserved.
//

import UIKit
import os.log

//MARK: - osLog
func log(_ message: String, function: String = #function, file: String = #file, line: Int = #line, _ type: OSLogType = .default) {
    forBuildStyle(debug: {
        os_log("[%{public}@/function = %{public}@:%{public}@] \nmessage = %{public}@",
               log: OSLog(subsystem: Bundle.main.bundleIdentifier ?? "", category: "kissoft"),
               type: type ,
               (file as NSString).lastPathComponent, function, "[#\(line)]", message)
    }) {
        os_log("[%{public}@/%{public}@:%{public}@] %{public}@", log: .disabled, type: type, (file as NSString).lastPathComponent, function, "[#\(line)]", message)
    }
}

//MARK: - debug check
func forBuildStyle(debug debugCode: () -> Void,
                   release releaseCode: () -> Void) {
    var debugBuild: Bool = false
    assert({ debugBuild = true; return true }())

    if debugBuild {
        debugCode()
    } else {
        releaseCode()
    }
}
