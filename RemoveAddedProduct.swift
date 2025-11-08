import Foundation

// Supabase configuration
let supabaseURL = "https://avvmksvgywfdnmxqlhwb.supabase.co"
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2dm1rc3ZneXdmZG5teHFsaHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTE3OTIsImV4cCI6MjA3MjM4Nzc5Mn0.uu47MLjxgkLYHopS3vnFZ2t9m9WoKMSeFS34rGJ-PlE"

// Product to remove
let productBarcode = "1234567890123"

func removeProduct() async -> Bool {
    print("🗑️ Removing product from Supabase...")
    print("📊 Barcode: \(productBarcode)")
    
    guard let url = URL(string: "\(supabaseURL)/rest/v1/products") else {
        print("❌ Invalid Supabase URL")
        return false
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
    request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("return=representation", forHTTPHeaderField: "Prefer")
    
    // Create the filter for the specific barcode
    let queryItems = [URLQueryItem(name: "barcode", value: "eq.\(productBarcode)")]
    
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    components?.queryItems = queryItems
    
    if let finalURL = components?.url {
        request.url = finalURL
    }
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                print("✅ Product removed successfully!")
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
print("🧹 Removing added product from database...")

Task {
    let success = await removeProduct()
    
    if success {
        print("🎉 Product removed successfully!")
    } else {
        print("⚠️ Failed to remove product. Check the logs above.")
    }
    
    exit(0)
}

// Keep the script running
RunLoop.main.run()



