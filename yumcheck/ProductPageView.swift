//
//  ProductPageView.swift
//  yumcheck
//
//  Created by Asya Binsted on 02/09/2025.
//

import SwiftUI

struct ProductPageView: View {
    let product: ProductInfo?
    let barcode: String
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false
    @State private var currentProduct: ProductInfo?
    
    // Callback for when a product is successfully added
    let onProductAdded: ((ProductInfo) -> Void)?
    
    init(product: ProductInfo?, barcode: String, onProductAdded: ((ProductInfo) -> Void)? = nil) {
        print("🎯 [DEBUG] ProductPageView: Initializing...")
        print("🎯 [DEBUG] ProductPageView: Current thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("🎯 [DEBUG] ProductPageView: Timestamp: \(Date())")
        print("🎯 [DEBUG] ProductPageView: Product: \(product?.productName ?? "nil")")
        print("🎯 [DEBUG] ProductPageView: Barcode: \(barcode)")
        print("🎯 [DEBUG] ProductPageView: Product is nil: \(product == nil)")
        
        self.product = product
        self.barcode = barcode
        self.onProductAdded = onProductAdded
        self._currentProduct = State(initialValue: product)
        
        print("🎯 [DEBUG] ProductPageView: Initialized successfully")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let product = currentProduct {
                        // Product found
                        ProductFoundView(product: product, isFavorite: $isFavorite)
                    } else {
                        // Product not found
                        ProductNotFoundView(
                            barcode: barcode,
                            onProductAdded: { addedProduct in
                                currentProduct = addedProduct
                                onProductAdded?(addedProduct)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if currentProduct != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            toggleFavorite()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .pink : .primary)
                        }
                    }
                }
            }
            .onAppear {
                checkFavoriteStatus()
            }
        }
    }
    
    private func checkFavoriteStatus() {
        if let product = currentProduct {
            isFavorite = LocalDatabaseService.shared.isFavorite(barcode: product.barcode)
        }
    }
    
    private func toggleFavorite() {
        guard let product = currentProduct else { return }
        
        if isFavorite {
            LocalDatabaseService.shared.removeFromFavorites(barcode: product.barcode)
        } else {
            LocalDatabaseService.shared.addToFavorites(product)
        }
        
        isFavorite.toggle()
    }
}

struct ProductFoundView: View {
    let product: ProductInfo
    @Binding var isFavorite: Bool
    @State private var analysis: ProductAnalysis?
    @State private var isLoadingAnalysis = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Product image
            if let imageUrl = product.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(height: 200)
                .cornerRadius(16)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                    )
            }
            
            // Product info
            VStack(alignment: .leading, spacing: 16) {
                // Basic info
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.productName ?? "Unknown Product")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let brand = product.brands {
                        Text(brand)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let category = product.category {
                        Text(category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Barcode
                HStack {
                    Text("Barcode:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(product.barcode)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                // Ingredients
                if let ingredients = product.ingredientsText, !ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(ingredients)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                }
                
                // Labels/Claims
                if !product.labels.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Labels & Claims")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100))
                        ], spacing: 8) {
                            ForEach(product.labels, id: \.self) { label in
                                Text(label)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Allergens
                if !product.allergens.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Allergens")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100))
                        ], spacing: 8) {
                            ForEach(product.allergens, id: \.self) { allergen in
                                Text(allergen)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Eco score
                if let ecoScore = product.ecoScore {
                    HStack {
                        Text("Eco Score:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(ecoScore)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            
            // Product Analysis Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Product Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                if isLoadingAnalysis {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Analyzing product...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else if let analysis = analysis {
                    ProductAnalysisView(analysis: analysis)
                } else {
                    Button("Analyze Product") {
                        analyzeProduct()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .onAppear {
            // Auto-analyze when view appears
            analyzeProduct()
        }
    }
    
    private func analyzeProduct() {
        print("🔍 ProductPageView: Starting product analysis")
        isLoadingAnalysis = true
        analysis = nil
        
        // Perform analysis on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            print("🔍 ProductPageView: Running analysis on background queue")
            
            do {
                let productAnalysis = ProductAnalysisService.shared.analyzeProduct(product)
                print("🔍 ProductPageView: Analysis completed successfully, returning to main queue")
                
                DispatchQueue.main.async {
                    print("🔍 ProductPageView: Setting analysis result on main queue")
                    self.analysis = productAnalysis
                    self.isLoadingAnalysis = false
                    print("🔍 ProductPageView: Analysis state updated - isLoading: \(self.isLoadingAnalysis), analysis: \(self.analysis != nil)")
                }
            } catch {
                print("❌ ProductPageView: Analysis failed with error: \(error)")
                DispatchQueue.main.async {
                    self.isLoadingAnalysis = false
                    self.analysis = nil
                    print("❌ ProductPageView: Analysis failed, resetting state")
                }
            }
        }
    }
}

struct ProductNotFoundView: View {
    let barcode: String
    let onProductAdded: (ProductInfo) -> Void
    @State private var showAddProductView = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Not found icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Product Not Found")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("We couldn't find this product in our database or Open Beauty Facts")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Barcode: \(barcode)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    showAddProductView = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Database")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    // TODO: Report issue
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble.fill")
                        Text("Report Issue")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showAddProductView) {
            AddProductView(
                prefilledBarcode: barcode,
                onProductAdded: { product in
                    onProductAdded(product)
                    showAddProductView = false
                }
            )
        }
    }
}

#Preview("Product Found") {
    ProductPageView(
        product: ProductInfo(
            barcode: "4894819894099",
            productName: "Watsons Super Smooth Gum Care Dental Floss Picks",
            brands: "Watsons",
            ingredientsText: "PTFE, Polystyrene",
            imageUrl: nil,
            category: "dental",
            quantity: "50 pieces",
            imageFrontUrl: nil,
            imageIngredientsUrl: nil,
            imagePackagingUrl: nil,
            labels: ["Gentle on gums", "93% supreme glide"],
            ecoScore: "B",
            allergens: ["Latex"]
        ),
        barcode: "4894819894099"
    )
}

#Preview("Product Not Found") {
    ProductPageView(
        product: nil,
        barcode: "1234567890123"
    )
}
