//
//  DriveItem.swift
//  
//
//  Created by Butanediol on 9/12/2023.
//

import Vapor

struct DriveItem: Content, Identifiable {
    let createdDateTime: Date
    let eTag: String
    let id: String
    let lastModifiedDateTime: Date
    let name: String
    let webUrl: String
    let cTag: String
    let size: Int
    let folder: Folder?
    let file: File?
    let microsoftGraphDownloadUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case createdDateTime, eTag, id, lastModifiedDateTime
        case name, webUrl, cTag, size, folder, file
        case microsoftGraphDownloadUrl = "@microsoft.graph.downloadUrl"
    }
    
    struct Folder: Codable {
        let childCount: Int
    }
    
    struct File: Codable {
        let mimeType: String
        let hashes: Hashes
        
        struct Hashes: Codable {
            let quickXorHash: String
        }
    }
}
