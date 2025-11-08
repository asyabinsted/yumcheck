import Foundation

// Supabase configuration
let supabaseURL = "https://avvmksvgywfdnmxqlhwb.supabase.co"
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2dm1rc3ZneXdmZG5teHFsaHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTE3OTIsImV4cCI6MjA3MjM4Nzc5Mn0.uu47MLjxgkLYHopS3vnFZ2t9m9WoKMSeFS34rGJ-PlE"

// Random product data (matching the actual schema)
let randomProduct = [
    "barcode": "1234567890123",
    "name": "Hydrating Face Serum",
    "brand": "Glow Beauty",
    "category": "Skincare",
    "quantity": "30ml",
    "attributes": [
        "ingredients": ["Hyaluronic Acid", "Vitamin C", "Niacinamide", "Aloe Vera", "Green Tea Extract"],
        "claims": ["Vegan", "Cruelty-Free", "Paraben-Free"],
        "packaging": "Glass bottle with dropper",
        "certifications": ["Leaping Bunny", "Vegan Society"],
        "imageUrl": "https://example.com/serum.jpg",
        "nutritionGrade": "A",
        "allergens": [],
        "additives": [],
        "ecoscoreGrade": "A"
    ],
    "created_at": "2025-09-16T14:30:00Z",
    "updated_at": "2025-09-16T14:30:00Z"
] as [String: Any]

func addRandomProduct() async -> Bool {
    print("➕ Adding random product to Supabase...")
    print("📦 Product: \(randomProduct["name"] ?? "Unknown")")
    print("🏷️ Brand: \(randomProduct["brand"] ?? "Unknown")")
    print("📊 Barcode: \(randomProduct["barcode"] ?? "Unknown")")
    
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
        let jsonData = try JSONSerialization.data(withJSONObject: randomProduct)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 201 {
                print("✅ Product added successfully!")
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
print("🎲 Adding random product to database...")

Task {
    let success = await addRandomProduct()
    
    if success {
        print("🎉 Random product added successfully!")
    } else {
        print("⚠️ Failed to add product. Check the logs above.")
    }
    
    exit(0)
}

// Keep the script running
RunLoop.main.run()
