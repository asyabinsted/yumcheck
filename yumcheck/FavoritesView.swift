//
//  FavoritesView.swift
//  yumcheck
//
//  Created by Asya Binsted on 02/09/2025.
//

import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [ProductInfo] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.pink)
                        .padding(.top, 40)
                    
                    Text("Favorites")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Your favorite beauty products")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Content
                if favorites.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 120)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "heart")
                                        .font(.system(size: 32))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No favorites yet")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Products you favorite will appear here")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            )
                            .padding(.horizontal)
                    }
                } else {
                    // Favorites list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(favorites, id: \.barcode) { product in
                                FavoriteProductRow(product: product)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Feature cards
                VStack(spacing: 12) {
                    FeatureCard(
                        icon: "star.fill",
                        title: "Quick Access",
                        description: "Easily find your most-loved products",
                        color: .yellow
                    )
                    
                    FeatureCard(
                        icon: "bell.fill",
                        title: "Price Alerts",
                        description: "Get notified when prices drop",
                        color: .blue
                    )
                    
                    FeatureCard(
                        icon: "arrow.clockwise",
                        title: "Auto Updates",
                        description: "Keep product info current",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    private func loadFavorites() {
        favorites = LocalDatabaseService.shared.getFavorites()
    }
}

struct FavoriteProductRow: View {
    let product: ProductInfo
    
    var body: some View {
        HStack(spacing: 16) {
            // Product image or placeholder
            if let imageUrl = product.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    )
            }
            
            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.productName ?? "Unknown Product")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let brand = product.brands {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Barcode: \(product.barcode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Remove from favorites button
            Button(action: {
                LocalDatabaseService.shared.removeFromFavorites(barcode: product.barcode)
                // Refresh the list
            }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.pink)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    FavoritesView()
}
