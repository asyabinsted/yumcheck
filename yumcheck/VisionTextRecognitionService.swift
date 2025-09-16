//
//  VisionTextRecognitionService.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import Foundation
import UIKit
import Vision

class VisionTextRecognitionService {
    static let shared = VisionTextRecognitionService()
    private init() {}
    
    // MARK: - Text Recognition
    
    func recognizeTextInImage(_ image: UIImage, completion: @escaping (Result<[TextElement], Error>) -> Void) {
        print("🔍 Vision: Starting text recognition...")
        print("🔍 Image size: \(image.size)")
        
        // Preprocess image for better recognition
        guard let processedImage = preprocessImageForVision(image) else {
            print("❌ Failed to preprocess image for Vision")
            completion(.failure(VisionError.imageProcessingFailed))
            return
        }
        
        // Convert UIImage to CGImage
        guard let cgImage = processedImage.cgImage else {
            print("❌ Failed to convert UIImage to CGImage")
            completion(.failure(VisionError.imageProcessingFailed))
            return
        }
        
        // Create text recognition request
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Vision text recognition failed: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("❌ No text recognition results")
                    completion(.failure(VisionError.noTextFound))
                    return
                }
                
                let textElements = self.extractTextElements(from: observations, imageSize: processedImage.size)
                print("✅ Vision recognition completed. Found \(textElements.count) text elements")
                completion(.success(textElements))
            }
        }
        
        // Configure request for better accuracy
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en", "es", "fr", "de", "it", "pt"]
        request.usesLanguageCorrection = true
        request.automaticallyDetectsLanguage = true
        
        // Perform text recognition
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    print("❌ Vision request failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Image Preprocessing
    
    private func preprocessImageForVision(_ image: UIImage) -> UIImage? {
        print("🖼️ Preprocessing image for Vision...")
        
        // Vision works best with images that have good contrast and appropriate size
        // Resize image to optimal size for text recognition
        let targetSize = calculateOptimalSizeForVision(for: image.size)
        let resizedImage = resizeImage(image, to: targetSize)
        
        // Enhance contrast and brightness for better text recognition
        let enhancedImage = enhanceImageForTextRecognition(resizedImage)
        
        return enhancedImage
    }
    
    private func calculateOptimalSizeForVision(for size: CGSize) -> CGSize {
        // Vision works well with images between 1024-2048 pixels
        // For ingredients text, we want to ensure good readability
        let minDimension: CGFloat = 1024
        let maxDimension: CGFloat = 2048
        
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        
        if size.width > size.height {
            // Landscape
            newSize = CGSize(
                width: min(maxDimension, max(minDimension, size.width)),
                height: min(maxDimension, max(minDimension, size.width)) / aspectRatio
            )
        } else {
            // Portrait
            newSize = CGSize(
                width: min(maxDimension, max(minDimension, size.height)) * aspectRatio,
                height: min(maxDimension, max(minDimension, size.height))
            )
        }
        
        print("🖼️ Resizing from \(size) to \(newSize) for Vision")
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
        contrastFilter.setValue(1.3, forKey: kCIInputContrastKey) // Increase contrast for ML Kit
        contrastFilter.setValue(0.1, forKey: kCIInputBrightnessKey) // Slight brightness increase
        contrastFilter.setValue(1.0, forKey: kCIInputSaturationKey)
        
        guard let enhancedCIImage = contrastFilter.outputImage else { return image }
        
        // Convert back to UIImage
        guard let enhancedCGImage = context.createCGImage(enhancedCIImage, from: enhancedCIImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: enhancedCGImage)
    }
    
    // MARK: - Text Element Extraction
    
    private func extractTextElements(from observations: [VNRecognizedTextObservation], imageSize: CGSize) -> [TextElement] {
        var textElements: [TextElement] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            // Convert Vision coordinates to UIKit coordinates
            let boundingBox = observation.boundingBox
            let frame = VNImageRectForNormalizedRect(boundingBox, Int(imageSize.width), Int(imageSize.height))
            
            let textElement = TextElement(
                text: topCandidate.string,
                frame: frame,
                confidence: topCandidate.confidence
            )
            textElements.append(textElement)
        }
        
        // Sort elements by position (top to bottom, left to right)
        textElements.sort { element1, element2 in
            let y1 = element1.frame.origin.y
            let y2 = element2.frame.origin.y
            
            // If Y coordinates are significantly different, sort by Y
            if abs(y1 - y2) > 20 {
                return y1 < y2 // Lower Y first (top to bottom)
            }
            
            // If Y coordinates are similar, sort by X (left to right)
            return element1.frame.origin.x < element2.frame.origin.x
        }
        
        return textElements
    }
}

// MARK: - Data Models

struct TextElement: Identifiable {
    let id = UUID()
    let text: String
    let frame: CGRect
    let confidence: Float
    var isSelected: Bool = true // Default to selected
    
    var isHighConfidence: Bool {
        return confidence > 0.7
    }
}

// MARK: - Error Types

enum VisionError: Error, LocalizedError {
    case imageProcessingFailed
    case noTextFound
    case recognitionFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image for text recognition"
        case .noTextFound:
            return "No text found in the image"
        case .recognitionFailed:
            return "Text recognition processing failed"
        }
    }
}
