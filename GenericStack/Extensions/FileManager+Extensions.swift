//
//  FileManager+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

protocol FileManagerTemporaryFiles {
    func clearTemporaryDirectory() throws
    @discardableResult func writeToTemporaryDirectory(_ data: Data, fileName: String) throws -> URL
}

extension FileManager: FileManagerTemporaryFiles {
    func clearTemporaryDirectory() throws {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let temporaryDirectoryContents = try contentsOfDirectory(atPath: temporaryDirectoryURL.path)
        try temporaryDirectoryContents.forEach {
            try removeItem(at: temporaryDirectoryURL.appendingPathComponent($0))
        }
    }
    
    @discardableResult func writeToTemporaryDirectory(_ data: Data, fileName: String) throws -> URL {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: temporaryDirectoryURL)
        return temporaryDirectoryURL
    }
    
}
