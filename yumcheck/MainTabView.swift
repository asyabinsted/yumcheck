//
//  MainTabView.swift
//  yumcheck
//
//  Created by Asya Binsted on 02/09/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showProductPage = false
    @State private var productPageProduct: ProductInfo?
    @State private var productPageBarcode: String = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Scan Tab
            ContentView(
                onProductFound: { product, barcode in
                    print("🎯 [DEBUG] MainTabView: onProductFound called with product: \(product.productName ?? "Unknown"), barcode: \(barcode)")
                    print("🎯 [DEBUG] MainTabView: Current thread: \(Thread.isMainThread ? "Main" : "Background")")
                    print("🎯 [DEBUG] MainTabView: Timestamp: \(Date())")
                    print("🎯 [DEBUG] MainTabView: Setting productPageProduct = product")
                    productPageProduct = product
                    print("🎯 [DEBUG] MainTabView: Setting productPageBarcode = \(barcode)")
                    productPageBarcode = barcode
                    print("🎯 [DEBUG] MainTabView: Setting showProductPage = true")
                    showProductPage = true
                    print("🎯 [DEBUG] MainTabView: showProductPage set to true successfully")
                },
                onProductNotFound: { barcode in
                    print("🎯 [DEBUG] MainTabView: onProductNotFound called with barcode: \(barcode)")
                    print("🎯 [DEBUG] MainTabView: Current thread: \(Thread.isMainThread ? "Main" : "Background")")
                    print("🎯 [DEBUG] MainTabView: Timestamp: \(Date())")
                    print("🎯 [DEBUG] MainTabView: Setting productPageProduct = nil")
                    productPageProduct = nil
                    print("🎯 [DEBUG] MainTabView: Setting productPageBarcode = \(barcode)")
                    productPageBarcode = barcode
                    print("🎯 [DEBUG] MainTabView: Setting showProductPage = true")
                    showProductPage = true
                    print("🎯 [DEBUG] MainTabView: showProductPage set to true successfully")
                }
            )
            .tabItem {
                Image(systemName: "barcode.viewfinder")
                Text("Scan")
            }
            .tag(0)
            
            // Favorites Tab
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorites")
                }
                .tag(1)
            
            // History Tab
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .sheet(isPresented: $showProductPage) {
            ProductPageView(
                product: productPageProduct,
                barcode: productPageBarcode,
                onProductAdded: { addedProduct in
                    // Update the product page to show the newly added product
                    productPageProduct = addedProduct
                }
            )
        }
        .onChange(of: showProductPage) { isPresented in
            if isPresented {
                print("🎯 MainTabView: Sheet is being presented with product: \(productPageProduct?.productName ?? "nil"), barcode: '\(productPageBarcode)'")
            }
        }
    }
}

#Preview {
    MainTabView()
}
