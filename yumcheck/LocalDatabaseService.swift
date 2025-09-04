//
//  LocalDatabaseService.swift
//  yumcheck
//
//  Created by Asya Binsted on 02/09/2025.
//

import Foundation

struct LocalDatabaseService {
    static let shared = LocalDatabaseService()
    
    private let userDefaults = UserDefaults.standard
    private let productsKey = "local_products"
    private let historyKey = "scan_history"
    
    private init() {}
    
    // MARK: - Product Storage
    
    func saveProduct(_ product: ProductInfo) {
        var products = getLocalProducts()
        
        // Check if product already exists
        if let existingIndex = products.firstIndex(where: { $0.barcode == product.barcode }) {
            products[existingIndex] = product
        } else {
            products.append(product)
        }
        
        saveProducts(products)
    }
    
    func getProduct(barcode: String) -> ProductInfo? {
        let products = getLocalProducts()
        return products.first { $0.barcode == barcode }
    }
    
    private func getLocalProducts() -> [ProductInfo] {
        guard let data = userDefaults.data(forKey: productsKey),
              let products = try? JSONDecoder().decode([ProductInfo].self, from: data) else {
            return []
        }
        return products
    }
    
    private func saveProducts(_ products: [ProductInfo]) {
        if let data = try? JSONEncoder().encode(products) {
            userDefaults.set(data, forKey: productsKey)
        }
    }
    
    // MARK: - History Storage
    
    func addToHistory(barcode: String, product: ProductInfo?, scanDate: Date = Date()) {
        var history = getHistory()
        
        let historyItem = HistoryItem(
            id: UUID(),
            barcode: barcode,
            productName: product?.productName,
            brand: product?.brands,
            scanDate: scanDate,
            found: product != nil
        )
        
        // Add to beginning of array (most recent first)
        history.insert(historyItem, at: 0)
        
        // Keep only last 100 items
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        
        saveHistory(history)
    }
    
    func getHistory() -> [HistoryItem] {
        guard let data = userDefaults.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return history
    }
    
    func clearHistory() {
        userDefaults.removeObject(forKey: historyKey)
    }
    
    private func saveHistory(_ history: [HistoryItem]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
    
    // MARK: - Favorites Storage
    
    func addToFavorites(_ product: ProductInfo) {
        var favorites = getFavorites()
        
        if !favorites.contains(where: { $0.barcode == product.barcode }) {
            favorites.append(product)
            saveFavorites(favorites)
        }
    }
    
    func removeFromFavorites(barcode: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.barcode == barcode }
        saveFavorites(favorites)
    }
    
    func getFavorites() -> [ProductInfo] {
        guard let data = userDefaults.data(forKey: "favorites"),
              let favorites = try? JSONDecoder().decode([ProductInfo].self, from: data) else {
            return []
        }
        return favorites
    }
    
    func isFavorite(barcode: String) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.barcode == barcode }
    }
    
    private func saveFavorites(_ favorites: [ProductInfo]) {
        if let data = try? JSONEncoder().encode(favorites) {
            userDefaults.set(data, forKey: "favorites")
        }
    }
}

// MARK: - Codable Extensions

extension ProductInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case barcode, productName, brands, ingredientsText, imageUrl, category, quantity
        case imageFrontUrl, imageIngredientsUrl, imagePackagingUrl, labels, ecoScore, allergens
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        barcode = try container.decode(String.self, forKey: .barcode)
        productName = try container.decodeIfPresent(String.self, forKey: .productName)
        brands = try container.decodeIfPresent(String.self, forKey: .brands)
        ingredientsText = try container.decodeIfPresent(String.self, forKey: .ingredientsText)
        imageUrl = try container.decodeIfPresent(URL.self, forKey: .imageUrl)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        quantity = try container.decodeIfPresent(String.self, forKey: .quantity)
        imageFrontUrl = try container.decodeIfPresent(URL.self, forKey: .imageFrontUrl)
        imageIngredientsUrl = try container.decodeIfPresent(URL.self, forKey: .imageIngredientsUrl)
        imagePackagingUrl = try container.decodeIfPresent(URL.self, forKey: .imagePackagingUrl)
        labels = try container.decode([String].self, forKey: .labels)
        ecoScore = try container.decodeIfPresent(String.self, forKey: .ecoScore)
        allergens = try container.decode([String].self, forKey: .allergens)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(barcode, forKey: .barcode)
        try container.encodeIfPresent(productName, forKey: .productName)
        try container.encodeIfPresent(brands, forKey: .brands)
        try container.encodeIfPresent(ingredientsText, forKey: .ingredientsText)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(quantity, forKey: .quantity)
        try container.encodeIfPresent(imageFrontUrl, forKey: .imageFrontUrl)
        try container.encodeIfPresent(imageIngredientsUrl, forKey: .imageIngredientsUrl)
        try container.encodeIfPresent(imagePackagingUrl, forKey: .imagePackagingUrl)
        try container.encode(labels, forKey: .labels)
        try container.encodeIfPresent(ecoScore, forKey: .ecoScore)
        try container.encode(allergens, forKey: .allergens)
    }
}

extension HistoryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, barcode, productName, brand, scanDate, found
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        barcode = try container.decode(String.self, forKey: .barcode)
        productName = try container.decodeIfPresent(String.self, forKey: .productName)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        scanDate = try container.decode(Date.self, forKey: .scanDate)
        found = try container.decode(Bool.self, forKey: .found)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(barcode, forKey: .barcode)
        try container.encodeIfPresent(productName, forKey: .productName)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encode(scanDate, forKey: .scanDate)
        try container.encode(found, forKey: .found)
    }
}
