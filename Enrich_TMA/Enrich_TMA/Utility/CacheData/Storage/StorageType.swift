//
//  StorageType.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/12/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import Foundation
enum StorageType {
    case cache
    case permanent

    var searchPathDirectory: FileManager.SearchPathDirectory {
        switch self {
        case .cache:
            return .cachesDirectory
        case .permanent:
            return .documentDirectory
        }
    }

    func subFolderName(subfolder: String) -> URL {
        let path = NSSearchPathForDirectoriesInDomains(searchPathDirectory, .userDomainMask, true).first ?? ""
        return URL(fileURLWithPath: path).appendingPathComponent(subfolder)
    }

    func clearStorage() {
        let path = NSSearchPathForDirectoriesInDomains(searchPathDirectory, .userDomainMask, true).first ?? ""
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: path).appendingPathComponent("/"))
    }

    func clearStorageForSubfolder(subfolder: String) {
        let path = NSSearchPathForDirectoriesInDomains(searchPathDirectory, .userDomainMask, true).first ?? ""
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: path).appendingPathComponent(subfolder))
    }

}
