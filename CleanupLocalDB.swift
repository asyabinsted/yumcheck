import Foundation

// Test barcodes to remove
let testBarcodes = ["8851473004307", "8854927000238", "8859446300395"]

func cleanupLocalDatabase() {
    print("🗑️ Cleaning up local database...")
    
    // Get the Documents directory
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let dbPath = documentsPath.appendingPathComponent("yumcheck.db")
    
    print("📁 Looking for database at: \(dbPath.path)")
    
    if FileManager.default.fileExists(atPath: dbPath.path) {
        do {
            // Read the database to check if it contains our test products
            let dbData = try Data(contentsOf: dbPath)
            let dbString = String(data: dbData, encoding: .utf8) ?? ""
            
            var foundTestProducts = false
            for barcode in testBarcodes {
                if dbString.contains(barcode) {
                    print("🔍 Found test product with barcode: \(barcode)")
                    foundTestProducts = true
                }
            }
            
            if foundTestProducts {
                // Remove the database file
                try FileManager.default.removeItem(at: dbPath)
                print("✅ Local database removed successfully")
            } else {
                print("ℹ️ No test products found in local database")
            }
        } catch {
            print("❌ Error accessing local database: \(error)")
        }
    } else {
        print("ℹ️ Local database not found - may not exist or already cleaned")
    }
}

// Main execution
print("🧹 Starting local database cleanup...")
print("📋 Looking for barcodes: \(testBarcodes.joined(separator: ", "))")

cleanupLocalDatabase()

print("🎉 Local database cleanup completed!")
