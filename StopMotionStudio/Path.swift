//
//  Path.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/13/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

class Path: NSObject {
    
    var fileName: String?
    var stringPath: String?
    var nsString: NSString?
    var url: URL?
    var data: Data?
    
    init(string: String) {
        self.stringPath = string
        let nsString = NSString(string: string)
        self.fileName = nsString.lastPathComponent
        self.nsString = nsString
        do {
            self.data = try Data(contentsOf: URL(fileURLWithPath: string))
        } catch {
            self.data = nil
        }
    }
    
    init(fileURLWithPath fileURL: URL) {
        self.url = fileURL
        self.fileName = NSString(string: fileURL.absoluteString).lastPathComponent
        self.stringPath = fileURL.absoluteString
        self.nsString = NSString(string: fileURL.absoluteString)
        do {
            self.data = try Data(contentsOf: fileURL)
        } catch {
            self.data = nil
        }
    }
    
    init(nsString: NSString) {
        self.url = URL(fileURLWithPath: nsString.abbreviatingWithTildeInPath)
        self.nsString = nsString
        self.stringPath = nsString.abbreviatingWithTildeInPath
        self.fileName = nsString.lastPathComponent
        do {
            self.data = try Data(contentsOf: URL(fileURLWithPath: stringPath ?? ""))
        } catch {
            self.data = nil
        }
    }
    
    init(data: Data?, fileURL: URL) {
        self.data = data
        self.fileName = NSString(string: fileURL.absoluteString).lastPathComponent
        self.nsString = NSString(string: fileURL.absoluteString)
        self.stringPath = fileURL.absoluteString
        self.url = fileURL
    }
    
}
