// Unified Product Service for iOS YumCheck
// This service combines Supabase and Open Beauty Facts lookups

import Foundation

class UnifiedProductService {
    static let shared = UnifiedProductService()
    
    private init() {}
    
    // Supabase configuration
    private let supabaseURL = "https://avvmksvgywfdnmxqlhwb.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2dm1rc3ZneXdmZG5teHFsaHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTE3OTIsImV4cCI6MjA3MjM4Nzc5Mn0.uu47MLjxgkLYHopS3vnFZ2t9m9WoKMSeFS34rGJ-PlE"
    
    // MARK: - Main Product Lookup Function
    
    func getProduct(barcode: String, completion: @escaping (Result<ProductInfo, ProductLookupError>) -> Void) -> URLSessionDataTask? {
        print("🚀 [DEBUG] Starting product lookup for barcode: \(barcode)")
        print("🚀 [DEBUG] Current thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("🚀 [DEBUG] Timestamp: \(Date())")
        
        // Step 1: Check Local DB first
        print("📱 [DEBUG] Step 1: Checking Local Database...")
        let localStartTime = Date()
        
        if let localProduct = LocalDatabaseService.shared.getProduct(barcode: barcode) {
            let localEndTime = Date()
            let localDuration = localEndTime.timeIntervalSince(localStartTime)
            print("✅ [DEBUG] Product found in Local Database: \(localProduct.productName ?? "Unknown")")
            print("✅ [DEBUG] Local DB lookup took: \(localDuration * 1000)ms")
            print("📱 [DEBUG] Source: Local Database")
            print("✅ [DEBUG] Calling completion with success on thread: \(Thread.isMainThread ? "Main" : "Background")")
            completion(.success(localProduct))
            print("✅ [DEBUG] Local DB completion called successfully")
            return nil
        }
        
        let localEndTime = Date()
        let localDuration = localEndTime.timeIntervalSince(localStartTime)
        print("⚠️ [DEBUG] Product not found in Local Database")
        print("⚠️ [DEBUG] Local DB lookup took: \(localDuration * 1000)ms")
        
        // Step 2: Try Supabase Cloud DB
        print("📊 [DEBUG] Step 2: Starting Supabase Cloud Database lookup...")
        let supabaseStartTime = Date()
        
        let supabaseTask = getProductFromSupabase(barcode: barcode) { [weak self] result in
            let supabaseEndTime = Date()
            let supabaseDuration = supabaseEndTime.timeIntervalSince(supabaseStartTime)
            print("📊 [DEBUG] Supabase lookup completed in: \(supabaseDuration * 1000)ms")
            print("📊 [DEBUG] Supabase result thread: \(Thread.isMainThread ? "Main" : "Background")")
            
            switch result {
            case .success(let product):
                print("✅ [DEBUG] Product found in Supabase: \(product.productName ?? "Unknown")")
                print("📱 [DEBUG] Source: Supabase Cloud Database")
                
                // Save to Local DB for faster lookup next time
                print("💾 [DEBUG] Saving product to Local Database...")
                LocalDatabaseService.shared.saveProduct(product)
                print("💾 [DEBUG] Product saved to Local Database for future lookups")
                
                print("✅ [DEBUG] Calling completion with Supabase success on thread: \(Thread.isMainThread ? "Main" : "Background")")
                completion(.success(product))
                print("✅ [DEBUG] Supabase completion called successfully")
                return
            case .failure(let error):
                print("⚠️ [DEBUG] Supabase lookup failed: \(error.localizedDescription)")
                print("⚠️ [DEBUG] Supabase error type: \(type(of: error))")
                // Continue to Open Beauty Facts
            }
            
            // Step 3: If not found in Supabase, check Open Beauty Facts
            print("🌐 [DEBUG] Step 3: Starting Open Beauty Facts API lookup...")
            let obfStartTime = Date()
            
            OpenBeautyFactsService.shared.fetchProduct(barcode: barcode) { result in
                let obfEndTime = Date()
                let obfDuration = obfEndTime.timeIntervalSince(obfStartTime)
                print("🌐 [DEBUG] Open Beauty Facts lookup completed in: \(obfDuration * 1000)ms")
                print("🌐 [DEBUG] OBF result thread: \(Thread.isMainThread ? "Main" : "Background")")
                
                switch result {
                case .success(let product):
                    print("✅ [DEBUG] Product found in Open Beauty Facts: \(product.productName ?? "Unknown")")
                    print("📱 [DEBUG] Source: Open Beauty Facts API")
                    
                    // Save to Local DB for faster lookup next time
                    print("💾 [DEBUG] Saving product to Local Database...")
                    LocalDatabaseService.shared.saveProduct(product)
                    print("💾 [DEBUG] Product saved to Local Database for future lookups")
                    
                    print("✅ [DEBUG] Calling completion with OBF success on thread: \(Thread.isMainThread ? "Main" : "Background")")
                    completion(.success(product))
                    print("✅ [DEBUG] OBF completion called successfully")
                case .failure(let error):
                    print("⚠️ [DEBUG] Open Beauty Facts lookup failed: \(error.localizedDescription)")
                    print("⚠️ [DEBUG] OBF error type: \(type(of: error))")
                    print("❌ [DEBUG] Product not found in any source: \(barcode)")
                    print("❌ [DEBUG] Calling completion with not found on thread: \(Thread.isMainThread ? "Main" : "Background")")
                    completion(.failure(.notFound))
                    print("❌ [DEBUG] Not found completion called successfully")
                }
            }
        }
        
        print("📊 [DEBUG] Supabase task created and started")
        return supabaseTask
    }
    
    // MARK: - Supabase Integration
    
    private func getProductFromSupabase(barcode: String, completion: @escaping (Result<ProductInfo, ProductLookupError>) -> Void) -> URLSessionDataTask {
        let urlString = "\(supabaseURL)/rest/v1/products?barcode=eq.\(barcode)&select=*"
        print("🌐 [DEBUG] Making request to: \(urlString)")
        print("🌐 [DEBUG] Supabase request thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("🌐 [DEBUG] Supabase request timestamp: \(Date())")
        
        guard let url = URL(string: urlString) else {
            print("❌ [DEBUG] Invalid URL: \(urlString)")
            print("❌ [DEBUG] Calling completion with invalid URL error on thread: \(Thread.isMainThread ? "Main" : "Background")")
            completion(.failure(.network(NSError(domain: "Invalid URL", code: -1))))
            return URLSession.shared.dataTask(with: URLRequest(url: URL(string: "about:blank")!))
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("\(supabaseKey)", forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 5.0 // Simple 5 second timeout
        
        print("🌐 [DEBUG] URLRequest created with timeout: \(request.timeoutInterval)s")
        print("🌐 [DEBUG] Starting URLSession data task...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("🔍 [DEBUG] Supabase request completed - checking response...")
            print("🔍 [DEBUG] Completion thread: \(Thread.isMainThread ? "Main" : "Background")")
            print("🔍 [DEBUG] Completion timestamp: \(Date())")
            
            if let error = error {
                print("❌ [DEBUG] Supabase network error: \(error.localizedDescription)")
                print("❌ [DEBUG] Error domain: \((error as NSError).domain)")
                print("❌ [DEBUG] Error code: \((error as NSError).code)")
                print("❌ [DEBUG] Error userInfo: \((error as NSError).userInfo)")
                
                // Check if it's a timeout or cancellation
                if (error as NSError).code == NSURLErrorTimedOut {
                    print("⏰ [DEBUG] Request timed out after 5 seconds")
                    print("⏰ [DEBUG] Calling completion with timeout error on thread: \(Thread.isMainThread ? "Main" : "Background")")
                    completion(.failure(.network(NSError(domain: "Timeout", code: NSURLErrorTimedOut, userInfo: [NSLocalizedDescriptionKey: "Request timed out. Please check your internet connection and try again."]))))
                } else if (error as NSError).code == NSURLErrorCancelled {
                    print("🛑 [DEBUG] Request was cancelled")
                    print("🛑 [DEBUG] Calling completion with cancelled error on thread: \(Thread.isMainThread ? "Main" : "Background")")
                    completion(.failure(.network(NSError(domain: "Cancelled", code: NSURLErrorCancelled, userInfo: [NSLocalizedDescriptionKey: "Request was cancelled."]))))
                } else {
                    print("❌ [DEBUG] Calling completion with network error on thread: \(Thread.isMainThread ? "Main" : "Background")")
                    completion(.failure(.network(error)))
                }
                print("❌ [DEBUG] Supabase error completion called successfully")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Supabase response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❌ Supabase HTTP error: \(httpResponse.statusCode)")
                    completion(.failure(.network(NSError(domain: "HTTP Error", code: httpResponse.statusCode))))
                    return
                }
            }
            
            guard let data = data else {
                print("❌ Supabase: No data received")
                completion(.failure(.network(NSError(domain: "No data", code: -1))))
                return
            }
            
            // Debug: Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Supabase raw response: \(responseString)")
            } else {
                print("❌ Could not convert response data to string")
            }
            
            do {
                // First try to decode as array of SupabaseProduct
                let supabaseProducts = try JSONDecoder().decode([SupabaseProduct].self, from: data)
                print("📊 Supabase decoded \(supabaseProducts.count) products")
                
                if let supabaseProduct = supabaseProducts.first {
                    print("✅ Found product in Supabase: \(supabaseProduct.name)")
                    print("📦 Raw Supabase product: \(supabaseProduct)")
                    let productInfo = self.convertSupabaseToProductInfo(supabaseProduct)
                    print("🔄 Converted to ProductInfo: \(productInfo)")
                    completion(.success(productInfo))
                } else {
                    print("❌ No products found in Supabase response")
                    completion(.failure(.notFound))
                }
            } catch {
                print("❌ Supabase decoding error: \(error.localizedDescription)")
                print("❌ Raw data that failed to decode: \(String(data: data, encoding: .utf8) ?? "Could not convert to string")")
                
                // Try manual JSON parsing as fallback
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       let firstProduct = json.first {
                        print("🔄 Trying manual JSON parsing...")
                        let productInfo = self.convertManualJSONToProductInfo(firstProduct)
                        print("✅ Manual conversion successful: \(productInfo.productName ?? "Unknown")")
                        completion(.success(productInfo))
                    } else {
                        print("❌ Manual JSON parsing also failed")
                        completion(.failure(.decoding(error)))
                    }
                } catch {
                    print("❌ Manual JSON parsing error: \(error.localizedDescription)")
                    completion(.failure(.decoding(error)))
                }
            }
        }
        
        print("🌐 [DEBUG] URLSession data task created, calling resume()...")
        task.resume()
        print("🌐 [DEBUG] URLSession data task resumed successfully")
        return task
    }
    
    // MARK: - Data Conversion
    
    private func convertSupabaseToProductInfo(_ supabaseProduct: SupabaseProduct) -> ProductInfo {
        print("🔄 Converting Supabase product to ProductInfo...")
        let attributes = supabaseProduct.attributes
        
        print("📦 Supabase product details:")
        print("   Barcode: \(supabaseProduct.barcode)")
        print("   Name: \(supabaseProduct.name)")
        print("   Brand: \(supabaseProduct.brand ?? "nil")")
        print("   Category: \(supabaseProduct.category ?? "nil")")
        print("   Quantity: \(supabaseProduct.quantity ?? "nil")")
        print("   Attributes: \(attributes)")
        
        let productInfo = ProductInfo(
            barcode: supabaseProduct.barcode,
            productName: supabaseProduct.name,
            brands: supabaseProduct.brand,
            ingredientsText: attributes.ingredients?.joined(separator: ", "),
            imageUrl: URL(string: attributes.imageUrl ?? ""),
            category: supabaseProduct.category,
            quantity: supabaseProduct.quantity,
            imageFrontUrl: nil,
            imageIngredientsUrl: nil,
            imagePackagingUrl: nil,
            labels: attributes.claims ?? [],
            ecoScore: attributes.ecoscoreGrade,
            allergens: attributes.allergens ?? []
        )
        
        print("✅ Converted ProductInfo:")
        print("   Barcode: \(productInfo.barcode)")
        print("   Product Name: \(productInfo.productName ?? "nil")")
        print("   Brands: \(productInfo.brands ?? "nil")")
        print("   Category: \(productInfo.category ?? "nil")")
        print("   Labels count: \(productInfo.labels.count)")
        
        return productInfo
    }
    
    private func convertManualJSONToProductInfo(_ json: [String: Any]) -> ProductInfo {
        print("🔄 Converting manual JSON to ProductInfo...")
        
        let barcode = json["barcode"] as? String ?? ""
        let name = json["name"] as? String ?? ""
        let brand = json["brand"] as? String
        let category = json["category"] as? String
        let quantity = json["quantity"] as? String
        
        // Parse attributes
        var ingredients: [String] = []
        var claims: [String] = []
        var imageUrl: String? = nil
        var ecoscoreGrade: String? = nil
        var allergens: [String] = []
        
        if let attributes = json["attributes"] as? [String: Any] {
            if let ingredientsArray = attributes["ingredients"] as? [String] {
                ingredients = ingredientsArray
            }
            if let claimsArray = attributes["claims"] as? [String] {
                claims = claimsArray
            }
            if let imageUrlString = attributes["imageUrl"] as? String {
                imageUrl = imageUrlString
            }
            if let ecoscoreGradeString = attributes["ecoscoreGrade"] as? String {
                ecoscoreGrade = ecoscoreGradeString
            }
            if let allergensArray = attributes["allergens"] as? [String] {
                allergens = allergensArray
            }
        }
        
        let productInfo = ProductInfo(
            barcode: barcode,
            productName: name,
            brands: brand,
            ingredientsText: ingredients.isEmpty ? nil : ingredients.joined(separator: ", "),
            imageUrl: imageUrl != nil ? URL(string: imageUrl!) : nil,
            category: category,
            quantity: quantity,
            imageFrontUrl: nil,
            imageIngredientsUrl: nil,
            imagePackagingUrl: nil,
            labels: claims,
            ecoScore: ecoscoreGrade,
            allergens: allergens
        )
        
        print("✅ Manual conversion result:")
        print("   Barcode: \(productInfo.barcode)")
        print("   Product Name: \(productInfo.productName ?? "nil")")
        print("   Brands: \(productInfo.brands ?? "nil")")
        print("   Category: \(productInfo.category ?? "nil")")
        print("   Labels count: \(productInfo.labels.count)")
        
        return productInfo
    }
}

// MARK: - Supporting Types

struct SupabaseProduct: Codable {
    let barcode: String
    let name: String
    let brand: String?
    let category: String?
    let quantity: String?
    let attributes: SupabaseAttributes
    let created_at: String
    let updated_at: String
}

struct SupabaseAttributes: Codable {
    let ingredients: [String]?
    let claims: [String]?
    let packaging: String?
    let certifications: [String]?
    let imageUrl: String?
    let nutritionGrade: String?
    let allergens: [String]?
    let additives: [String]?
    let ecoscoreGrade: String?
    
    enum CodingKeys: String, CodingKey {
        case ingredients, claims, packaging, certifications
        case imageUrl = "image_url"
        case nutritionGrade = "nutrition_grade"
        case allergens, additives
        case ecoscoreGrade = "ecoscore_grade"
    }
}

enum ProductLookupError: Error, LocalizedError {
    case notFound
    case network(Error)
    case decoding(Error)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Product not found in our database or Open Beauty Facts."
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .decoding(let error):
            return "Failed to decode product data: \(error.localizedDescription)"
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }
}
