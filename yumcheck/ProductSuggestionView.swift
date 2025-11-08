//
//  ProductSuggestionView.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import SwiftUI

struct ProductSuggestionView: View {
    let suggestion: GoogleReverseImageSearchService.ProductSuggestion
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let brand = suggestion.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let category = suggestion.category {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let price = suggestion.price {
                        Text(price)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Text("\(Int(suggestion.confidence * 100))% match")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let description = suggestion.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text("Source: \(suggestion.source)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Reject") {
                        onReject()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    
                    Button("Accept") {
                        onAccept()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

struct AutoFillSuggestionsView: View {
    let suggestions: [GoogleReverseImageSearchService.ProductSuggestion]
    let onAcceptAll: () -> Void
    let onClearAll: () -> Void
    let onAcceptSuggestion: (GoogleReverseImageSearchService.ProductSuggestion) -> Void
    let onRejectSuggestion: (GoogleReverseImageSearchService.ProductSuggestion) -> Void
    
    @State private var acceptedSuggestions: Set<UUID> = []
    @State private var rejectedSuggestions: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Auto-Fill Suggestions")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(suggestions.count) suggestions found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Clear All") {
                        onClearAll()
                        acceptedSuggestions.removeAll()
                        rejectedSuggestions.removeAll()
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                    
                    Button("Accept All") {
                        onAcceptAll()
                        // Mark all as accepted
                        acceptedSuggestions = Set(suggestions.indices.map { _ in UUID() })
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            
            // Suggestions List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                        let suggestionId = UUID() // In real implementation, use suggestion.id
                        
                        ProductSuggestionView(
                            suggestion: suggestion,
                            onAccept: {
                                onAcceptSuggestion(suggestion)
                                acceptedSuggestions.insert(suggestionId)
                            },
                            onReject: {
                                onRejectSuggestion(suggestion)
                                rejectedSuggestions.insert(suggestionId)
                            }
                        )
                        .opacity(rejectedSuggestions.contains(suggestionId) ? 0.5 : 1.0)
                        .overlay(
                            // Show checkmark for accepted suggestions
                            Group {
                                if acceptedSuggestions.contains(suggestionId) {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        Spacer()
                                    }
                                    .padding(8)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct AutoFillLoadingView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            VStack(spacing: 8) {
                Text("Analyzing Product Image...")
                    .font(.headline)
                
                Text("Searching for product information")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(progress > Double(index) / 3.0 ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 0.6).repeatForever(), value: progress)
                }
            }
        }
        .padding(24)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

struct AutoFillErrorView: View {
    let error: Error
    let onRetry: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Auto-Fill Failed")
                    .font(.headline)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 12) {
                Button("Dismiss") {
                    onDismiss()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Button("Try Again") {
                    onRetry()
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding(24)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        // Loading View
        AutoFillLoadingView(progress: 0.6)
        
        Spacer()
        
        // Error View
        AutoFillErrorView(
            error: GoogleReverseImageSearchService.SearchError.noResults,
            onRetry: {},
            onDismiss: {}
        )
        
        Spacer()
        
        // Suggestions View
        AutoFillSuggestionsView(
            suggestions: [
                GoogleReverseImageSearchService.ProductSuggestion(
                    name: "Moisturizing Face Cream",
                    brand: "Beauty Brand",
                    category: "Skincare",
                    description: "Hydrating face cream with natural ingredients",
                    price: "$24.99",
                    confidence: 0.85,
                    source: "Amazon"
                )
            ],
            onAcceptAll: {},
            onClearAll: {},
            onAcceptSuggestion: { _ in },
            onRejectSuggestion: { _ in }
        )
    }
    .padding()
}
