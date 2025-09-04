//
//  HistoryView.swift
//  yumcheck
//
//  Created by Asya Binsted on 02/09/2025.
//

import SwiftUI

struct HistoryView: View {
    @State private var historyItems: [HistoryItem] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if historyItems.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("No History Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Your scanned products will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 40)
                } else {
                    // History list
                    List {
                        ForEach(historyItems) { item in
                            HistoryItemRow(item: item)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !historyItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            clearAllHistory()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            loadHistory()
        }
    }
    
    private func loadHistory() {
        historyItems = LocalDatabaseService.shared.getHistory()
    }
    
    private func deleteItems(offsets: IndexSet) {
        historyItems.remove(atOffsets: offsets)
        // Save updated history to local storage
        saveHistory()
    }
    
    private func clearAllHistory() {
        historyItems.removeAll()
        LocalDatabaseService.shared.clearHistory()
    }
    
    private func saveHistory() {
        // Note: LocalDatabaseService manages history internally
        // This is just for UI updates
    }
}

struct HistoryItem: Identifiable {
    let id: UUID
    let barcode: String
    let productName: String?
    let brand: String?
    let scanDate: Date
    let found: Bool
}

struct HistoryItemRow: View {
    let item: HistoryItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(item.found ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: item.found ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(item.found ? .green : .red)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                if let productName = item.productName {
                    Text(productName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                } else {
                    Text("Product Not Found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                if let brand = item.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Barcode: \(item.barcode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(item.scanDate, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HistoryView()
}
