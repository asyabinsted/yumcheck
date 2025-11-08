//
//  GoogleReverseImageSearchService.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import Foundation
import UIKit

class GoogleReverseImageSearchService {
    static let shared = GoogleReverseImageSearchService()
    private init() {}
    
    // MARK: - Rate Limiting
    private var lastSearchTime: Date?
    private let minimumSearchInterval: TimeInterval = 2.0 // 2 seconds between searches
    private var searchCount = 0
    private let maxSearchesPerHour = 50
    
    // MARK: - Data Models
    
    struct ProductSuggestion {
        let name: String
        let brand: String?
        let category: String?
        let description: String?
        let price: String?
        let confidence: Float
        let source: String
    }
    
    struct SearchResult {
        let suggestions: [ProductSuggestion]
        let totalResults: Int
        let searchTime: Date
    }
    
    enum SearchError: Error, LocalizedError {
        case rateLimited
        case noResults
        case networkError(String)
        case parsingError
        case imageProcessingError
        
        var errorDescription: String? {
            switch self {
            case .rateLimited:
                return "Too many searches. Please wait before trying again."
            case .noResults:
                return "No product information found for this image."
            case .networkError(let message):
                return "Network error: \(message)"
            case .parsingError:
                return "Failed to parse search results."
            case .imageProcessingError:
                return "Failed to process image for search."
            }
        }
    }
    
    // MARK: - Main Search Function
    
    func searchProductFromImage(_ image: UIImage, completion: @escaping (Result<SearchResult, Error>) -> Void) {
        print("🔍 GoogleReverseImageSearch: Starting search...")
        
        // Check rate limiting
        guard checkRateLimit() else {
            completion(.failure(SearchError.rateLimited))
            return
        }
        
        // Process image for search
        guard let imageData = processImageForSearch(image) else {
            completion(.failure(SearchError.imageProcessingError))
            return
        }
        
        // Perform the search
        performReverseImageSearch(imageData: imageData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let searchResult):
                    self.updateSearchStats()
                    completion(.success(searchResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Rate Limiting
    
    private func checkRateLimit() -> Bool {
        let now = Date()
        
        // Check hourly limit
        if searchCount >= maxSearchesPerHour {
            print("⚠️ GoogleReverseImageSearch: Hourly search limit reached")
            return false
        }
        
        // Check minimum interval
        if let lastSearch = lastSearchTime {
            let timeSinceLastSearch = now.timeIntervalSince(lastSearch)
            if timeSinceLastSearch < minimumSearchInterval {
                print("⚠️ GoogleReverseImageSearch: Rate limited - too soon since last search")
                return false
            }
        }
        
        return true
    }
    
    private func updateSearchStats() {
        lastSearchTime = Date()
        searchCount += 1
        
        // Reset hourly counter (simplified - in production, use proper hourly tracking)
        if searchCount > maxSearchesPerHour {
            searchCount = 0
        }
    }
    
    // MARK: - Image Processing
    
    private func processImageForSearch(_ image: UIImage) -> Data? {
        print("🖼️ GoogleReverseImageSearch: Processing image for search...")
        
        // Resize image to reasonable size for search
        let maxSize: CGFloat = 800
        let resizedImage = resizeImage(image, toMaxSize: maxSize)
        
        // Convert to JPEG with good quality
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            print("❌ GoogleReverseImageSearch: Failed to convert image to JPEG")
            return nil
        }
        
        print("✅ GoogleReverseImageSearch: Image processed - size: \(imageData.count) bytes")
        return imageData
    }
    
    private func resizeImage(_ image: UIImage, toMaxSize maxSize: CGFloat) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    // MARK: - Search Implementation
    
    private func performReverseImageSearch(imageData: Data, completion: @escaping (Result<SearchResult, Error>) -> Void) {
        print("🌐 GoogleReverseImageSearch: Performing reverse image search...")
        
        // For this implementation, we'll simulate the search process
        // In a real implementation, you would:
        // 1. Upload image to Google Images search
        // 2. Parse the search results
        // 3. Extract product information
        
        // Simulate network delay
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2.0) {
            // Simulate search results based on image analysis
            let suggestions = self.generateMockSuggestions()
            let searchResult = SearchResult(
                suggestions: suggestions,
                totalResults: suggestions.count,
                searchTime: Date()
            )
            
            print("✅ GoogleReverseImageSearch: Found \(suggestions.count) suggestions")
            completion(.success(searchResult))
        }
    }
    
    // MARK: - Mock Data Generation (Replace with real implementation)
    
    private func generateMockSuggestions() -> [ProductSuggestion] {
        // This is mock data - replace with actual Google Images API integration
        return [
            ProductSuggestion(
                name: "Moisturizing Face Cream",
                brand: "Beauty Brand",
                category: "Skincare",
                description: "Hydrating face cream with natural ingredients for all skin types",
                price: "$24.99",
                confidence: 0.85,
                source: "Amazon"
            ),
            ProductSuggestion(
                name: "Anti-Aging Night Cream",
                brand: "Premium Skincare",
                category: "Skincare",
                description: "Rich night cream with retinol and hyaluronic acid",
                price: "$45.00",
                confidence: 0.72,
                source: "Sephora"
            ),
            ProductSuggestion(
                name: "Daily Moisturizer",
                brand: "Natural Beauty",
                category: "Skincare",
                description: "Lightweight daily moisturizer with SPF protection",
                price: "$18.50",
                confidence: 0.68,
                source: "Ulta"
            )
        ]
    }
    
    // MARK: - Real Implementation Placeholder
    
    /*
     // TODO: Implement actual Google Images API integration
     private func performRealGoogleSearch(imageData: Data, completion: @escaping (Result<SearchResult, Error>) -> Void) {
         // 1. Upload image to Google Images
         // 2. Parse search results HTML/JSON
         // 3. Extract product information from shopping results
         // 4. Return structured data
         
         // Example implementation would involve:
         // - HTTP request to Google Images search
         // - HTML parsing of results
         // - Pattern matching for product data
         // - Confidence scoring based on result quality
     }
     */
}

// MARK: - Extensions for Data Processing

extension GoogleReverseImageSearchService {
    
    // MARK: - Text Processing Utilities
    
    func extractBrandFromText(_ text: String) -> String? {
        // Common beauty brand patterns
        let brandPatterns = [
            "L'Oreal", "Maybelline", "Revlon", "CoverGirl", "MAC", "Urban Decay",
            "Too Faced", "Fenty Beauty", "Glossier", "The Ordinary", "CeraVe",
            "Neutrogena", "Olay", "Olay", "Nivea", "Vaseline", "Aveeno"
        ]
        
        for brand in brandPatterns {
            if text.lowercased().contains(brand.lowercased()) {
                return brand
            }
        }
        
        return nil
    }
    
    func extractCategoryFromText(_ text: String) -> String? {
        let categories = [
            "Skincare", "Makeup", "Hair Care", "Body Care", "Fragrance",
            "Face Cream", "Moisturizer", "Serum", "Cleanser", "Toner",
            "Foundation", "Lipstick", "Mascara", "Eyeshadow", "Blush"
        ]
        
        for category in categories {
            if text.lowercased().contains(category.lowercased()) {
                return category
            }
        }
        
        return nil
    }
    
    func extractPriceFromText(_ text: String) -> String? {
        // Price patterns: $XX.XX, €XX.XX, £XX.XX, etc.
        let pricePattern = #"\$[\d,]+\.?\d*|\€[\d,]+\.?\d*|\£[\d,]+\.?\d*"#
        
        if let regex = try? NSRegularExpression(pattern: pricePattern) {
            let range = NSRange(location: 0, length: text.utf16.count)
            if let match = regex.firstMatch(in: text, options: [], range: range) {
                return String(text[Range(match.range, in: text)!])
            }
        }
        
        return nil
    }
    
    func calculateConfidence(for suggestion: ProductSuggestion) -> Float {
        var confidence: Float = 0.5 // Base confidence
        
        // Increase confidence based on available data
        if !suggestion.name.isEmpty { confidence += 0.2 }
        if suggestion.brand != nil { confidence += 0.1 }
        if suggestion.category != nil { confidence += 0.1 }
        if suggestion.price != nil { confidence += 0.1 }
        
        // Decrease confidence for very long names (might be noisy)
        if suggestion.name.count > 100 { confidence -= 0.1 }
        
        return min(confidence, 1.0)
    }
}
