//
//  ImageUploadService.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import Foundation
import UIKit

class ImageUploadService {
    static let shared = ImageUploadService()
    private init() {}
    
    // Supabase configuration
    private let supabaseURL = "https://avvmksvgywfdnmxqlhwb.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2dm1rc3ZneXdmZG5teHFsaHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTE3OTIsImV4cCI6MjA3MjM4Nzc5Mn0.uu47MLjxgkLYHopS3vnFZ2t9m9WoKMSeFS34rGJ-PlE"
    
    // MARK: - Image Upload Function
    
    func uploadImage(_ image: UIImage, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("📸 ImageUploadService: Starting image upload for file: \(fileName)")
        print("📸 Original image size: \(image.size)")
        print("📸 Original image scale: \(image.scale)")
        
        // Compress image to reduce file size
        guard let imageData = compressImage(image) else {
            print("❌ Failed to compress image")
            completion(.failure(ImageUploadError.compressionFailed))
            return
        }
        
        print("📸 Image compressed to \(imageData.count) bytes")
        print("📸 Image data first 20 bytes: \(imageData.prefix(20).map { String(format: "%02x", $0) }.joined(separator: " "))")
        
        // Create upload URL - try different bucket names
        let bucketNames = ["products", "public", "images"]
        var uploadURL = ""
        var selectedBucket = ""
        
        // For now, we'll try the first bucket and provide a helpful error if it fails
        selectedBucket = bucketNames[0]
        uploadURL = "\(supabaseURL)/storage/v1/object/\(selectedBucket)/\(fileName)"
        
        guard let url = URL(string: uploadURL) else {
            print("❌ Invalid upload URL: \(uploadURL)")
            completion(.failure(ImageUploadError.invalidURL))
            return
        }
        
        print("📤 Using bucket: \(selectedBucket)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("public", forHTTPHeaderField: "x-upsert")
        request.httpBody = imageData
        request.timeoutInterval = 60.0
        
        print("📤 Request headers:")
        print("   Authorization: Bearer \(supabaseKey.prefix(20))...")
        print("   Content-Type: image/jpeg")
        print("   Content-Length: \(imageData.count)")
        print("   x-upsert: public")
        
        print("📤 Uploading to: \(uploadURL)")
        
        // Upload image
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Upload failed with error: \(error.localizedDescription)")
                    completion(.failure(ImageUploadError.uploadFailed(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    completion(.failure(ImageUploadError.invalidResponse))
                    return
                }
                
                print("📤 Upload response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    // Success - return the public URL
                    let publicURL = "\(self.supabaseURL)/storage/v1/object/public/products/\(fileName)"
                    print("✅ Upload successful! Public URL: \(publicURL)")
                    completion(.success(publicURL))
                } else {
                    print("❌ Upload failed with status: \(httpResponse.statusCode)")
                    print("❌ Response headers: \(httpResponse.allHeaderFields)")
                    
                    var errorMessage = "Upload failed with status \(httpResponse.statusCode)"
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("❌ Error response body: \(responseString)")
                        errorMessage += ": \(responseString)"
                    }
                    
                    // Handle specific error cases
                    switch httpResponse.statusCode {
                    case 400:
                        if let data = data, let responseString = String(data: data, encoding: .utf8), responseString.contains("Bucket not found") {
                            // Try to save locally as fallback
                            if let localURL = self.saveImageLocally(image, fileName: fileName) {
                                print("💾 Saved image locally as fallback: \(localURL)")
                                completion(.success(localURL.absoluteString))
                                return
                            } else {
                                errorMessage = "Storage bucket not found and local save failed. Please contact support."
                            }
                        } else {
                            errorMessage = "Bad Request (400): Invalid image data or file format. Please try taking another photo."
                        }
                    case 401:
                        errorMessage = "Unauthorized (401): Invalid API key or authentication failed."
                    case 403:
                        errorMessage = "Forbidden (403): Insufficient permissions to upload to this bucket."
                    case 404:
                        // Try to save locally as fallback
                        if let localURL = self.saveImageLocally(image, fileName: fileName) {
                            print("💾 Saved image locally as fallback: \(localURL)")
                            completion(.success(localURL.absoluteString))
                            return
                        } else {
                            errorMessage = "Storage bucket not found and local save failed. Please contact support."
                        }
                    case 413:
                        errorMessage = "File too large (413): Image is too large. Please try a smaller image."
                    default:
                        break
                    }
                    
                    completion(.failure(ImageUploadError.uploadFailed(NSError(domain: "UploadError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Helper Functions
    
    private func compressImage(_ image: UIImage) -> Data? {
        print("📸 Starting image compression...")
        print("📸 Original image size: \(image.size)")
        print("📸 Original image scale: \(image.scale)")
        
        // Resize image to reasonable dimensions
        let maxDimension: CGFloat = 1024
        let size = image.size
        
        var newSize = size
        if size.width > maxDimension || size.height > maxDimension {
            let ratio = min(maxDimension / size.width, maxDimension / size.height)
            newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            print("📸 Resizing from \(size) to \(newSize)")
        } else {
            print("📸 No resizing needed")
        }
        
        // Use higher quality context for better results
        let scale: CGFloat = 1.0 // Use 1.0 scale for consistent results
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        // Draw image with proper scaling
        image.draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("❌ Failed to create resized image")
            return nil
        }
        
        print("📸 Resized image size: \(resizedImage.size)")
        print("📸 Resized image scale: \(resizedImage.scale)")
        
        // Try different compression qualities
        let compressionQualities: [CGFloat] = [0.8, 0.7, 0.6, 0.5]
        
        for quality in compressionQualities {
            if let imageData = resizedImage.jpegData(compressionQuality: quality) {
                print("📸 Compressed with quality \(quality) to \(imageData.count) bytes")
                
                // Check if data looks like valid JPEG (starts with FF D8)
                if imageData.count >= 2 {
                    let header = imageData.prefix(2)
                    let headerHex = header.map { String(format: "%02x", $0) }.joined(separator: " ")
                    print("📸 Image header: \(headerHex)")
                    
                    if header[0] == 0xFF && header[1] == 0xD8 {
                        print("✅ Valid JPEG header found")
                        return imageData
                    } else {
                        print("⚠️ Invalid JPEG header, trying next quality")
                    }
                }
            }
        }
        
        print("❌ Failed to create valid JPEG data")
        return nil
    }
    
    func generateFileName(for barcode: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(barcode)_\(timestamp).jpg"
    }
    
    // MARK: - Local Storage Fallback
    
    private func saveImageLocally(_ image: UIImage, fileName: String) -> URL? {
        print("💾 Attempting to save image locally as fallback...")
        
        // Get the Documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access Documents directory")
            return nil
        }
        
        // Create a subdirectory for product images
        let imagesDirectory = documentsDirectory.appendingPathComponent("ProductImages")
        
        // Create the directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("❌ Could not create images directory: \(error)")
            return nil
        }
        
        // Create the file URL
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        
        // Compress and save the image
        guard let imageData = compressImage(image) else {
            print("❌ Could not compress image for local storage")
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            print("✅ Image saved locally at: \(fileURL.path)")
            return fileURL
        } catch {
            print("❌ Could not save image locally: \(error)")
            return nil
        }
    }
}

// MARK: - Error Types

enum ImageUploadError: Error, LocalizedError {
    case compressionFailed
    case invalidURL
    case uploadFailed(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .invalidURL:
            return "Invalid upload URL"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
