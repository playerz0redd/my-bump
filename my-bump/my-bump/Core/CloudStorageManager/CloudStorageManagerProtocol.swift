//
//  CloudStorageManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 20.05.26.
//

import Foundation
import Cloudinary

protocol CloudStorageManagerProtocol {
    func uploadImage(image: Data) async throws -> String
    func getUrl(id: String, width: Int, height: Int) -> URL?
}

final class CloudinaryManager: CloudStorageManagerProtocol {
    
    private let manager: CLDCloudinary
    private let uploadPreset: String = "my-bump"
    private let cloudName: String = "dg7no5imh"
    
    init() {
        let config = CLDConfiguration(cloudName: cloudName, secure: true)
        self.manager = CLDCloudinary(configuration: config)
    }
    
    func uploadImage(image: Data) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            manager.createUploader().upload(data: image, uploadPreset: uploadPreset)
                .response { result, error in
                    if let error = error {
                        continuation.resume(throwing: error )
                    }
                    else if let result = result, let url = result.publicId {
                        continuation.resume(returning: url)
                    }
                }
        }
    }
    
    func getUrl(id: String, width: Int, height: Int) -> URL? {
        let transformation = CLDTransformation()
            .setWidth(width)
            .setHeight(height)
            .setCrop(.fill)
            .setFetchFormat("auto")
            .setQuality("auto")
        
        guard let url = manager.createUrl().setTransformation(transformation).generate(id) else { return nil }
        
        return URL(string: url)
    }
}
