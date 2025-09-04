//
//  AddProductService.swift
//  yumcheck
//
//  Created by Assistant on 03/09/2025.
//

import Foundation

class AddProductService {
    static let shared = AddProductService()
    private init() {}
    
    // Supabase configuration
    private let supabaseURL = "https://avvmksvgywfdnmxqlhwb.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2dm1rc3ZneXdmZG5teHFsaHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTE3OTIsImV4cCI6MjA3MjM4Nzc5Mn0.uu47MLjxgkLYHopS3vnFZ2t9m9WoKMSeFS34rGJ-PlE"
    
    // MARK: - Main Add Product Function
    
    func addProduct(_ product: ProductInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        print("📝 AddProductService: Starting to add product: \(product.productName ?? "Unknown")")
        print("📝 AddProductService: Barcode: \(product.barcode)")
        
        // Step 1: Add to local database first
        print("📱 Step 1: Adding to Local Database...")
        LocalDatabaseService.shared.saveProduct(product)
        print("✅ Product saved to Local Database")
        
        // Step 2: Add to Supabase cloud database
        print("📊 Step 2: Adding to Supabase Cloud Database...")
        addToSupabase(product) { result in
            switch result {
            case .success:
                print("✅ Product successfully added to Supabase")
                completion(.success(()))
            case .failure(let error):
                print("❌ Failed to add to Supabase: \(error.localizedDescription)")
                // Even if Supabase fails, we still have it in local DB
                // We could choose to retry later or just report the error
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Supabase Integration
    
    private func addToSupabase(_ product: ProductInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/products") else {
            completion(.failure(AddProductError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.timeoutInterval = 30.0
        
        // Convert ProductInfo to Supabase format
        let supabaseProduct = convertToSupabaseFormat(product)
        
        do {
            let jsonData = try JSONEncoder().encode(supabaseProduct)
            request.httpBody = jsonData
            
            print("📤 Supabase request body: \(String(data: jsonData, encoding: .utf8) ?? "Unable to convert to string")")
            
        } catch {
            print("❌ Failed to encode product data: \(error.localizedDescription)")
            completion(.failure(AddProductError.encodingError(error)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Supabase network error: \(error.localizedDescription)")
                completion(.failure(AddProductError.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                completion(.failure(AddProductError.invalidResponse))
                return
            }
            
            print("📡 Supabase response status: \(httpResponse.statusCode)")
            
            if let data = data, !data.isEmpty {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to convert to string"
                print("📦 Supabase response: \(responseString)")
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                print("✅ Product successfully added to Supabase")
                completion(.success(()))
            } else {
                print("❌ Supabase error response: \(httpResponse.statusCode)")
                let errorMessage = "Server error: \(httpResponse.statusCode)"
                completion(.failure(AddProductError.serverError(errorMessage)))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Data Conversion
    
    private func convertToSupabaseFormat(_ product: ProductInfo) -> SupabaseProduct {
        // Parse ingredients from text
        let ingredients = product.ingredientsText?.components(separatedBy: CharacterSet(charactersIn: ",;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
        
        // Create attributes structure
        let attributes = SupabaseAttributes(
            ingredients: ingredients.isEmpty ? nil : ingredients,
            claims: product.labels.isEmpty ? nil : product.labels,
            packaging: nil,
            certifications: nil,
            imageUrl: product.imageUrl?.absoluteString,
            nutritionGrade: nil,
            allergens: product.allergens.isEmpty ? nil : product.allergens,
            additives: nil,
            ecoscoreGrade: product.ecoScore
        )
        
        let currentDate = ISO8601DateFormatter().string(from: Date())
        
        return SupabaseProduct(
            barcode: product.barcode,
            name: product.productName ?? "Unknown Product",
            brand: product.brands,
            category: product.category,
            quantity: product.quantity,
            attributes: attributes,
            created_at: currentDate,
            updated_at: currentDate
        )
    }
}

// MARK: - Error Types

enum AddProductError: Error, LocalizedError {
    case invalidURL
    case encodingError(Error)
    case networkError(Error)
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for database connection"
        case .encodingError(let error):
            return "Failed to encode product data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

// MARK: - Supabase Product Model
// Note: SupabaseProduct is already defined in UnifiedProductService.swift
