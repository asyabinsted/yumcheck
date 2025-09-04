//
//  ProfileView.swift
//  yumcheck
//
//  Created by Asya Binsted on 02/09/2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var showAddProduct = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 4) {
                            Text("YumCheck User")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Beauty Product Scanner")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Stats cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Scanned",
                            value: "24",
                            icon: "barcode.viewfinder",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Favorites",
                            value: "8",
                            icon: "heart.fill",
                            color: .pink
                        )
                        
                        StatCard(
                            title: "Found",
                            value: "18",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Menu sections
                    VStack(spacing: 16) {
                        MenuSection(title: "Account") {
                            MenuRow(
                                icon: "person.circle",
                                title: "Personal Information",
                                color: .blue
                            )
                            
                            MenuRow(
                                icon: "bell",
                                title: "Notifications",
                                color: .orange
                            )
                            
                            MenuRow(
                                icon: "lock",
                                title: "Privacy & Security",
                                color: .purple
                            )
                        }
                        
                        MenuSection(title: "App") {
                            Button(action: {
                                showAddProduct = true
                            }) {
                                MenuRow(
                                    icon: "plus.circle",
                                    title: "Add Product",
                                    color: .blue
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            MenuRow(
                                icon: "gear",
                                title: "Settings",
                                color: .gray
                            )
                            
                            MenuRow(
                                icon: "questionmark.circle",
                                title: "Help & Support",
                                color: .blue
                            )
                            
                            MenuRow(
                                icon: "info.circle",
                                title: "About",
                                color: .green
                            )
                        }
                        
                        MenuSection(title: "Data") {
                            MenuRow(
                                icon: "square.and.arrow.up",
                                title: "Export Data",
                                color: .blue
                            )
                            
                            MenuRow(
                                icon: "trash",
                                title: "Clear All Data",
                                color: .red
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddProduct) {
                AddProductView()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                content
            }
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    ProfileView()
}
