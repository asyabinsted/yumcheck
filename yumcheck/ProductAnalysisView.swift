//
//  ProductAnalysisView.swift
//  yumcheck
//
//  Created by Assistant on 03/09/2025.
//

import SwiftUI

struct ProductAnalysisView: View {
    let analysis: ProductAnalysis
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Safety Score Card
                SafetyScoreCard(analysis: analysis)
                
                // Key Benefits and Concerns
                BenefitsConcernsCard(analysis: analysis)
                
                // Ingredient Analysis
                IngredientAnalysisCard(analysis: analysis.ingredientAnalysis)
                
                // Natural vs Synthetic Ratio
                NaturalSyntheticCard(ratio: analysis.ingredientAnalysis.naturalVsSynthetic)
                
                // Skin Type Compatibility
                SkinTypeCompatibilityCard(compatibleTypes: analysis.skinTypeCompatibility)
                
                // Recommendations
                RecommendationsCard(recommendations: analysis.recommendations)
                
                // Alternative Suggestions
                AlternativeSuggestionsCard(suggestions: analysis.alternativeSuggestions)
                
                // Usage Tips
                UsageTipsCard(tips: analysis.usageTips)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Safety Score Card

struct SafetyScoreCard: View {
    let analysis: ProductAnalysis
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: analysis.overallVerdict.icon)
                    .font(.title)
                    .foregroundColor(Color(hex: analysis.overallVerdict.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safety Score")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(analysis.overallVerdict.rawValue)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: analysis.overallVerdict.color))
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Safety Score Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(analysis.safetyScore) / 5.0)
                        .stroke(
                            Color(hex: analysis.overallVerdict.color),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(analysis.safetyScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            // Progress Bar
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Rectangle()
                        .fill(index <= analysis.safetyScore ? 
                              Color(hex: analysis.overallVerdict.color) : 
                              Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Benefits and Concerns Card

struct BenefitsConcernsCard: View {
    let analysis: ProductAnalysis
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Key Benefits")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if analysis.keyBenefits.isEmpty {
                Text("No significant benefits identified")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(analysis.keyBenefits, id: \.self) { benefit in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.top, 2)
                            
                            Text(benefit)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            Divider()
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Main Concerns")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if analysis.mainConcerns.isEmpty {
                Text("No significant concerns identified")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(analysis.mainConcerns, id: \.self) { concern in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                            
                            Text(concern)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Ingredient Analysis Card

struct IngredientAnalysisCard: View {
    let analysis: IngredientAnalysis
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Ingredient Analysis")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Beneficial Ingredients
            if !analysis.beneficial.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Beneficial (\(analysis.beneficial.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    
                    ForEach(analysis.beneficial.prefix(3), id: \.name) { ingredient in
                        IngredientRow(ingredient: ingredient)
                    }
                }
            }
            
            // Concerning Ingredients
            if !analysis.concerning.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Concerning (\(analysis.concerning.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        Spacer()
                    }
                    
                    ForEach(analysis.concerning.prefix(3), id: \.name) { ingredient in
                        IngredientRow(ingredient: ingredient)
                    }
                }
            }
            
            // Neutral Ingredients
            if !analysis.neutral.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Neutral (\(analysis.neutral.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    
                    ForEach(analysis.neutral.prefix(2), id: \.name) { ingredient in
                        IngredientRow(ingredient: ingredient)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct IngredientRow: View {
    let ingredient: IngredientInfo
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Category Icon
            Image(systemName: ingredient.category.icon)
                .font(.caption)
                .foregroundColor(Color(hex: ingredient.safetyLevel.color))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(ingredient.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Safety Level Badge
            Text(ingredient.safetyLevel.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: ingredient.safetyLevel.color))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Natural vs Synthetic Card

struct NaturalSyntheticCard: View {
    let ratio: NaturalSyntheticRatio
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Natural vs Synthetic")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Progress Bars
            VStack(spacing: 12) {
                HStack {
                    Text("Natural")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .frame(width: 60, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * CGFloat(ratio.naturalPercentage / 100), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(ratio.naturalPercentage))%")
                        .font(.caption)
                        .foregroundColor(.green)
                        .frame(width: 40, alignment: .trailing)
                }
                
                HStack {
                    Text("Synthetic")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .frame(width: 60, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * CGFloat(ratio.syntheticPercentage / 100), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(ratio.syntheticPercentage))%")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Skin Type Compatibility Card

struct SkinTypeCompatibilityCard: View {
    let compatibleTypes: [SkinType]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Skin Type Compatibility")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(compatibleTypes, id: \.self) { skinType in
                    HStack(spacing: 8) {
                        Image(systemName: skinType.icon)
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text(skinType.rawValue)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Recommendations Card

struct RecommendationsCard: View {
    let recommendations: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Recommendations")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .padding(.top, 2)
                        
                        Text(recommendation)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Alternative Suggestions Card

struct AlternativeSuggestionsCard: View {
    let suggestions: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Alternative Suggestions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .padding(.top, 2)
                        
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Usage Tips Card

struct UsageTipsCard: View {
    let tips: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.cyan)
                
                Text("Usage Tips")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundColor(.cyan)
                            .padding(.top, 2)
                        
                        Text(tip)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    let sampleAnalysis = ProductAnalysis(
        safetyScore: 4,
        overallVerdict: .generallySafe,
        keyBenefits: ["Contains skin-repairing ceramides", "Hydrating glycerin for moisture", "Antioxidant protection"],
        mainConcerns: ["Contains synthetic fragrance"],
        ingredientAnalysis: IngredientAnalysis(
            beneficial: [],
            concerning: [],
            neutral: [],
            naturalVsSynthetic: NaturalSyntheticRatio(
                naturalPercentage: 70,
                syntheticPercentage: 30,
                naturalIngredients: [],
                syntheticIngredients: []
            )
        ),
        recommendations: ["This product appears safe for most skin types"],
        skinTypeCompatibility: [.normal, .dry, .sensitive],
        alternativeSuggestions: ["Look for fragrance-free alternatives"],
        usageTips: ["Always patch test new products"]
    )
    
    return ProductAnalysisView(analysis: sampleAnalysis)
}
