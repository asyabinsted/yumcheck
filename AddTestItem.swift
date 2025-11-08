import Foundation

// Supabase configuration
let supabaseURL = "https://avvmksvgywfdnmxqlhwb.supabase.co"
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2dm1rc3ZneXdmZG5teHFsaHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTE3OTIsImV4cCI6MjA3MjM4Nzc5Mn0.uu47MLjxgkLYHopS3vnFZ2t9m9WoKMSeFS34rGJ-PlE"

// Test product data (matching the actual schema)
let testProduct = [
    "barcode": "9999999999999",
    "name": "Test Product - Facial Cleanser",
    "brand": "Test Beauty Co",
    "category": "Skincare",
    "quantity": "150ml",
    "attributes": [
        "ingredients": ["Water", "Glycerin", "Sodium Laureth Sulfate", "Cocamidopropyl Betaine", "Aloe Vera"],
        "claims": ["Test Product", "Hypoallergenic", "Dermatologist Tested"],
        "packaging": "Plastic bottle with pump dispenser",
        "certifications": ["Test Certification"],
        "imageUrl": "https://example.com/test-product.jpg",
        "nutritionGrade": "B",
        "allergens": ["Fragrance"],
        "additives": ["Preservatives"],
        "ecoscoreGrade": "B"
    ],
    "created_at": "2025-09-16T14:45:00Z",
    "updated_at": "2025-09-16T14:45:00Z"
] as [String: Any]

func addTestProduct() async -> Bool {
    print("➕ Adding test product to Supabase...")
    print("📦 Product: \(testProduct["name"] ?? "Unknown")")
    print("🏷️ Brand: \(testProduct["brand"] ?? "Unknown")")
    print("📊 Barcode: \(testProduct["barcode"] ?? "Unknown")")
    
    guard let url = URL(string: "\(supabaseURL)/rest/v1/products") else {
        print("❌ Invalid Supabase URL")
        return false
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
    request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("return=representation", forHTTPHeaderField: "Prefer")
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: testProduct)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 201 {
                print("✅ Test product added successfully!")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response: \(responseString)")
                }
                return true
            } else {
                print("❌ Supabase error: HTTP \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                return false
            }
        }
    } catch {
        print("❌ Network error: \(error)")
        return false
    }
    
    return false
}

// Main execution
print("🧪 Adding test item to database...")

Task {
    let success = await addTestProduct()
    
    if success {
        print("🎉 Test item added successfully!")
        print("📋 You can search for this product using barcode: 9999999999999")
    } else {
        print("⚠️ Failed to add test item. Check the logs above.")
    }
    
    exit(0)
}

// Keep the script running
RunLoop.main.run()


