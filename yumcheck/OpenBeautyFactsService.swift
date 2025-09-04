//
//  OpenBeautyFactsService.swift
//  yumcheck
//
//  Created by Assistant on 28/08/2025.
//

import Foundation

struct ProductInfo: Equatable {
    let barcode: String
    let productName: String?
    let brands: String?
    let ingredientsText: String?
    let imageUrl: URL?
    let category: String?
    let quantity: String?
    let imageFrontUrl: URL?
    let imageIngredientsUrl: URL?
    let imagePackagingUrl: URL?
    let labels: [String]
    let ecoScore: String?
    let allergens: [String]
    
    init(barcode: String, productName: String?, brands: String?, ingredientsText: String?, imageUrl: URL?, category: String?, quantity: String?, imageFrontUrl: URL?, imageIngredientsUrl: URL?, imagePackagingUrl: URL?, labels: [String], ecoScore: String?, allergens: [String]) {
        self.barcode = barcode
        self.productName = productName
        self.brands = brands
        self.ingredientsText = ingredientsText
        self.imageUrl = imageUrl
        self.category = category
        self.quantity = quantity
        self.imageFrontUrl = imageFrontUrl
        self.imageIngredientsUrl = imageIngredientsUrl
        self.imagePackagingUrl = imagePackagingUrl
        self.labels = labels
        self.ecoScore = ecoScore
        self.allergens = allergens
    }
}

private struct APIProduct: Decodable {
    let product_name: String?
    let brands: String?
    let ingredients_text: String?
    let image_url: String?
    let categories: String?
    let quantity: String?
    let image_front_url: String?
    let image_ingredients_url: String?
    let image_packaging_url: String?
    let labels_tags: [String]? // e.g., ["en:vegan", "en:palm-oil-free"]
    let ecoscore_grade: String?
    let allergens_hierarchy: [String]? // e.g., ["en:milk"]
}

private struct OpenBeautyFactsResponse: Decodable {
    let status: Int
    let status_verbose: String?
    let code: String?
    let product: APIProduct?
}

// Using ProductLookupError from UnifiedProductService instead of separate enum

final class OpenBeautyFactsService {
    static let shared = OpenBeautyFactsService()
    private init() {}

    private let baseURL = URL(string: "https://world.openbeautyfacts.org/api/v0")!

    func fetchProduct(barcode: String, completion: @escaping (Result<ProductInfo, ProductLookupError>) -> Void) {
        print("🌐 [DEBUG] OpenBeautyFactsService: Starting fetchProduct for barcode: \(barcode)")
        print("🌐 [DEBUG] OpenBeautyFactsService: Current thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("🌐 [DEBUG] OpenBeautyFactsService: Timestamp: \(Date())")
        
        let url = baseURL.appendingPathComponent("product/").appendingPathComponent("\(barcode).json")
        print("🌐 [DEBUG] OpenBeautyFactsService: URL: \(url)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("🌐 [DEBUG] OpenBeautyFactsService: Request completed")
            print("🌐 [DEBUG] OpenBeautyFactsService: Completion thread: \(Thread.isMainThread ? "Main" : "Background")")
            print("🌐 [DEBUG] OpenBeautyFactsService: Completion timestamp: \(Date())")
            
            if let error = error {
                print("❌ [DEBUG] OpenBeautyFactsService: Network error: \(error.localizedDescription)")
                print("❌ [DEBUG] OpenBeautyFactsService: Error type: \(type(of: error))")
                DispatchQueue.main.async { 
                    print("❌ [DEBUG] OpenBeautyFactsService: Calling completion with network error on main thread")
                    completion(.failure(.network(error))) 
                }
                return
            }

            guard
                let http = response as? HTTPURLResponse,
                (200..<300).contains(http.statusCode),
                let data = data
            else {
                DispatchQueue.main.async { completion(.failure(.unknown("Unexpected server response"))) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(OpenBeautyFactsResponse.self, from: data)
                guard decoded.status == 1, let product = decoded.product else {
                    DispatchQueue.main.async { completion(.failure(.notFound)) }
                    return
                }

                let info = ProductInfo(
                    barcode: barcode,
                    productName: product.product_name,
                    brands: product.brands,
                    ingredientsText: product.ingredients_text,
                    imageUrl: URL(string: product.image_url ?? ""),
                    category: product.categories,
                    quantity: product.quantity,
                    imageFrontUrl: URL(string: product.image_front_url ?? ""),
                    imageIngredientsUrl: URL(string: product.image_ingredients_url ?? ""),
                    imagePackagingUrl: URL(string: product.image_packaging_url ?? ""),
                    labels: product.labels_tags ?? [],
                    ecoScore: product.ecoscore_grade,
                    allergens: product.allergens_hierarchy?.map { $0.replacingOccurrences(of: "en:", with: "") } ?? []
                )

                DispatchQueue.main.async { completion(.success(info)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decoding(error))) }
            }
        }
        task.resume()
    }
}


