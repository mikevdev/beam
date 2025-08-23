//
//  Constant.swift
//  Beam
//
//  Created by Ravichandrane Rajendran on 04/12/2020.
//

import Foundation

enum Constants {
    static let version = ProcessInfo.processInfo.operatingSystemVersion
    static var runningOnBigSur: Bool = {
        return version.majorVersion >= 11 || (version.majorVersion == 10 && version.minorVersion >= 16)
    }()

    static let SafariUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/618.3.11.7.7 (KHTML, like Gecko) Version/18.0 Safari/618.3.11.7.7"
}
