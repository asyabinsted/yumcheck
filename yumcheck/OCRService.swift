//
//  OCRService.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import Foundation
import Vision
import UIKit

class OCRService {
    static let shared = OCRService()
    private init() {}
    
    // MARK: - OCR Processing
    
    func extractTextFromImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        print("🔍 OCRService: Starting text extraction from image")
        print("🔍 Image size: \(image.size)")
        
        // Process image to enhance text clarity
        guard let processedImage = preprocessImageForOCR(image) else {
            print("❌ Failed to preprocess image for OCR")
            completion(.failure(OCRError.imageProcessingFailed))
            return
        }
        
        // Convert UIImage to CGImage
        guard let cgImage = processedImage.cgImage else {
            print("❌ Failed to convert UIImage to CGImage")
            completion(.failure(OCRError.imageConversionFailed))
            return
        }
        
        // Create text recognition request
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ OCR request failed: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("❌ No text observations found")
                    completion(.failure(OCRError.noTextFound))
                    return
                }
                
                let extractedText = self.processTextObservations(observations)
                print("✅ OCR completed. Extracted text length: \(extractedText.count)")
                completion(.success(extractedText))
            }
        }
        
        // Configure request for better accuracy
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en", "es", "fr", "de", "it", "pt"] // Support multiple languages
        request.usesLanguageCorrection = true
        request.automaticallyDetectsLanguage = true
        
        // Perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    print("❌ Failed to perform OCR request: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Image Preprocessing
    
    private func preprocessImageForOCR(_ image: UIImage) -> UIImage? {
        print("🖼️ Preprocessing image for OCR...")
        
        // Resize image to optimal size for OCR (not too large, not too small)
        let targetSize = calculateOptimalSize(for: image.size)
        let resizedImage = resizeImage(image, to: targetSize)
        
        // Enhance contrast and brightness for better text recognition
        let enhancedImage = enhanceImageForTextRecognition(resizedImage)
        
        return enhancedImage
    }
    
    private func calculateOptimalSize(for size: CGSize) -> CGSize {
        let maxDimension: CGFloat = 1024
        let minDimension: CGFloat = 512
        
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        
        if size.width > size.height {
            // Landscape
            newSize = CGSize(width: min(maxDimension, max(minDimension, size.width)), 
                           height: min(maxDimension, max(minDimension, size.width)) / aspectRatio)
        } else {
            // Portrait
            newSize = CGSize(width: min(maxDimension, max(minDimension, size.height)) * aspectRatio,
                           height: min(maxDimension, max(minDimension, size.height)))
        }
        
        print("🖼️ Resizing from \(size) to \(newSize)")
        return newSize
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func enhanceImageForTextRecognition(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        
        // Create filters for enhancement
        let contrastFilter = CIFilter(name: "CIColorControls")!
        contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(1.2, forKey: kCIInputContrastKey) // Increase contrast
        contrastFilter.setValue(0.1, forKey: kCIInputBrightnessKey) // Slight brightness increase
        contrastFilter.setValue(1.0, forKey: kCIInputSaturationKey)
        
        guard let enhancedCIImage = contrastFilter.outputImage else { return image }
        
        // Convert back to UIImage
        guard let enhancedCGImage = context.createCGImage(enhancedCIImage, from: enhancedCIImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: enhancedCGImage)
    }
    
    // MARK: - Text Processing
    
    private func processTextObservations(_ observations: [VNRecognizedTextObservation]) -> String {
        var allText: [String] = []
        
        // Sort observations by position (top to bottom, left to right)
        let sortedObservations = observations.sorted { obs1, obs2 in
            let y1 = obs1.boundingBox.origin.y
            let y2 = obs2.boundingBox.origin.y
            
            // If Y coordinates are significantly different, sort by Y
            if abs(y1 - y2) > 0.1 {
                return y1 > y2 // Higher Y first (top to bottom)
            }
            
            // If Y coordinates are similar, sort by X (left to right)
            return obs1.boundingBox.origin.x < obs2.boundingBox.origin.x
        }
        
        for observation in sortedObservations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            let text = topCandidate.string
            let confidence = topCandidate.confidence
            
            // Only include text with reasonable confidence
            if confidence > 0.5 {
                allText.append(text)
            }
        }
        
        let rawText = allText.joined(separator: " ")
        return cleanAndFormatIngredientsText(rawText)
    }
    
    private func cleanAndFormatIngredientsText(_ text: String) -> String {
        print("🧹 Cleaning and formatting ingredients text...")
        
        var cleanedText = text
        
        // Remove common OCR artifacts
        cleanedText = cleanedText.replacingOccurrences(of: "|", with: "I") // Common OCR mistake
        cleanedText = cleanedText.replacingOccurrences(of: "0", with: "O") // In ingredient names
        cleanedText = cleanedText.replacingOccurrences(of: "5", with: "S") // In ingredient names
        
        // Remove extra whitespace and normalize
        cleanedText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split by common separators and clean each ingredient
        let separators = [",", ";", "\n", "•", "·", "▪", "▫"]
        var ingredients: [String] = []
        
        for separator in separators {
            if cleanedText.contains(separator) {
                ingredients = cleanedText.components(separatedBy: separator)
                break
            }
        }
        
        // If no separators found, try to split by common patterns
        if ingredients.isEmpty {
            // Look for patterns like "INGREDIENTS:" or "Contains:"
            let patterns = [
                "INGREDIENTS?:\\s*",
                "CONTAINS?:\\s*",
                "INGREDIENTES?:\\s*",
                "INGRÉDIENTS?:\\s*"
            ]
            
            for pattern in patterns {
                if let range = cleanedText.range(of: pattern, options: .regularExpression) {
                    let afterKeyword = String(cleanedText[range.upperBound...])
                    ingredients = afterKeyword.components(separatedBy: CharacterSet(charactersIn: ",;•·▪▫"))
                    break
                }
            }
        }
        
        // If still no ingredients found, treat the whole text as one ingredient
        if ingredients.isEmpty {
            ingredients = [cleanedText]
        }
        
        // Clean each ingredient
        let cleanedIngredients = ingredients.compactMap { ingredient -> String? in
            let cleaned = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            
            // Skip empty ingredients and very short ones (likely OCR artifacts)
            guard cleaned.count > 2 else { return nil }
            
            // Capitalize first letter of each ingredient
            return cleaned.prefix(1).uppercased() + cleaned.dropFirst().lowercased()
        }
        
        // Join with commas and proper spacing
        let result = cleanedIngredients.joined(separator: ", ")
        print("🧹 Cleaned text: \(result)")
        
        return result
    }
}

// MARK: - Error Types

enum OCRError: Error, LocalizedError {
    case imageProcessingFailed
    case imageConversionFailed
    case noTextFound
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image for text recognition"
        case .imageConversionFailed:
            return "Failed to convert image for processing"
        case .noTextFound:
            return "No text found in the image"
        case .processingFailed:
            return "Text recognition processing failed"
        }
    }
}
