//
//  ProductAnalysisService.swift
//  yumcheck
//
//  Created by Assistant on 03/09/2025.
//

import Foundation

// MARK: - Analysis Models

struct ProductAnalysis {
    let safetyScore: Int // 1-5 scale
    let overallVerdict: SafetyVerdict
    let keyBenefits: [String]
    let mainConcerns: [String]
    let ingredientAnalysis: IngredientAnalysis
    let recommendations: [String]
    let skinTypeCompatibility: [SkinType]
    let alternativeSuggestions: [String]
    let usageTips: [String]
}

enum SafetyVerdict: String, CaseIterable {
    case generallySafe = "Generally Safe"
    case useWithCaution = "Use with Caution"
    case notRecommended = "Not Recommended"
    
    var color: String {
        switch self {
        case .generallySafe: return "#34C759" // Green
        case .useWithCaution: return "#FFD60A" // Yellow
        case .notRecommended: return "#FF3B30" // Red
        }
    }
    
    var icon: String {
        switch self {
        case .generallySafe: return "checkmark.circle.fill"
        case .useWithCaution: return "exclamationmark.triangle.fill"
        case .notRecommended: return "xmark.octagon.fill"
        }
    }
}

struct IngredientAnalysis {
    let beneficial: [IngredientInfo]
    let concerning: [IngredientInfo]
    let neutral: [IngredientInfo]
    let naturalVsSynthetic: NaturalSyntheticRatio
}

struct IngredientInfo {
    let name: String
    let category: IngredientCategory
    let description: String
    let safetyLevel: SafetyLevel
    let benefits: [String]
    let concerns: [String]
}

enum IngredientCategory: String, CaseIterable {
    case moisturizer = "Moisturizer"
    case preservative = "Preservative"
    case surfactant = "Surfactant"
    case antioxidant = "Antioxidant"
    case emollient = "Emollient"
    case humectant = "Humectant"
    case fragrance = "Fragrance"
    case colorant = "Colorant"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .moisturizer: return "drop.fill"
        case .preservative: return "shield.fill"
        case .surfactant: return "bubble.left.and.bubble.right.fill"
        case .antioxidant: return "leaf.fill"
        case .emollient: return "heart.fill"
        case .humectant: return "humidity.fill"
        case .fragrance: return "nose.fill"
        case .colorant: return "paintpalette.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

enum SafetyLevel: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case moderate = "Moderate"
    case concerning = "Concerning"
    case harmful = "Harmful"
    
    var color: String {
        switch self {
        case .excellent: return "#34C759" // Green
        case .good: return "#30D158" // Light Green
        case .moderate: return "#FFD60A" // Yellow
        case .concerning: return "#FF9500" // Orange
        case .harmful: return "#FF3B30" // Red
        }
    }
}

struct NaturalSyntheticRatio {
    let naturalPercentage: Double
    let syntheticPercentage: Double
    let naturalIngredients: [String]
    let syntheticIngredients: [String]
}

enum SkinType: String, CaseIterable {
    case sensitive = "Sensitive"
    case dry = "Dry"
    case oily = "Oily"
    case combination = "Combination"
    case normal = "Normal"
    case acneProne = "Acne-Prone"
    case mature = "Mature"
    
    var icon: String {
        switch self {
        case .sensitive: return "exclamationmark.triangle.fill"
        case .dry: return "drop.fill"
        case .oily: return "sun.max.fill"
        case .combination: return "circle.grid.2x2.fill"
        case .normal: return "checkmark.circle.fill"
        case .acneProne: return "circle.dotted"
        case .mature: return "clock.fill"
        }
    }
}

// MARK: - Product Analysis Service

class ProductAnalysisService {
    static let shared = ProductAnalysisService()
    private init() {}
    
    // MARK: - Main Analysis Function
    
    func analyzeProduct(_ productInfo: ProductInfo) -> ProductAnalysis {
        print("🔍 ProductAnalysisService: Starting analysis for product: \(productInfo.productName ?? "Unknown")")
        print("🔍 ProductAnalysisService: Barcode: \(productInfo.barcode)")
        print("🔍 ProductAnalysisService: Ingredients text: \(productInfo.ingredientsText ?? "None")")
        print("🔍 ProductAnalysisService: Labels: \(productInfo.labels)")
        
        // Always provide a basic analysis, even if data is minimal
        let ingredients = parseIngredients(productInfo.ingredientsText ?? "")
        let additives = parseAdditives(productInfo.labels)
        
        print("🔍 ProductAnalysisService: Parsed ingredients: \(ingredients)")
        print("🔍 ProductAnalysisService: Parsed additives: \(additives)")
        
        let safetyScore = calculateSafetyScore(ingredients: ingredients, additives: additives, productInfo: productInfo)
        let overallVerdict = determineVerdict(safetyScore: safetyScore)
        let ingredientAnalysis = analyzeIngredients(ingredients: ingredients)
        
        print("🔍 ProductAnalysisService: Safety score: \(safetyScore)")
        print("🔍 ProductAnalysisService: Overall verdict: \(overallVerdict.rawValue)")
        
        let keyBenefits = extractKeyBenefits(ingredientAnalysis: ingredientAnalysis)
        let mainConcerns = extractMainConcerns(ingredientAnalysis: ingredientAnalysis)
        let recommendations = generateRecommendations(analysis: ingredientAnalysis, verdict: overallVerdict)
        let skinTypeCompatibility = determineSkinTypeCompatibility(ingredientAnalysis: ingredientAnalysis)
        let alternativeSuggestions = generateAlternativeSuggestions(concerns: mainConcerns)
        let usageTips = generateUsageTips(ingredientAnalysis: ingredientAnalysis, productInfo: productInfo)
        
        print("🔍 ProductAnalysisService: Analysis completed successfully")
        print("🔍 ProductAnalysisService: Key benefits: \(keyBenefits)")
        print("🔍 ProductAnalysisService: Main concerns: \(mainConcerns)")
        print("🔍 ProductAnalysisService: Recommendations: \(recommendations)")
        
        return ProductAnalysis(
            safetyScore: safetyScore,
            overallVerdict: overallVerdict,
            keyBenefits: keyBenefits,
            mainConcerns: mainConcerns,
            ingredientAnalysis: ingredientAnalysis,
            recommendations: recommendations,
            skinTypeCompatibility: skinTypeCompatibility,
            alternativeSuggestions: alternativeSuggestions,
            usageTips: usageTips
        )
    }
    
    // MARK: - Safety Scoring
    
    private func calculateSafetyScore(ingredients: [String], additives: [String], productInfo: ProductInfo) -> Int {
        var score = 5 // Start with perfect score
        
        // Deduct points for concerning ingredients
        for ingredient in ingredients {
            let ingredientInfo = getIngredientInfo(ingredient)
            switch ingredientInfo.safetyLevel {
            case .excellent: break // No deduction
            case .good: break // No deduction
            case .moderate: score -= 1
            case .concerning: score -= 2
            case .harmful: score -= 3
            }
        }
        
        // Deduct points for harmful additives
        for additive in additives {
            if isHarmfulAdditive(additive) {
                score -= 1
            }
        }
        
        // Bonus points for beneficial ingredients
        let beneficialCount = ingredients.filter { isBeneficialIngredient($0) }.count
        if beneficialCount >= 3 {
            score += 1
        }
        
        // Ensure score stays within 1-5 range
        return max(1, min(5, score))
    }
    
    private func determineVerdict(safetyScore: Int) -> SafetyVerdict {
        switch safetyScore {
        case 4...5: return .generallySafe
        case 2...3: return .useWithCaution
        default: return .notRecommended
        }
    }
    
    // MARK: - Ingredient Analysis
    
    private func analyzeIngredients(ingredients: [String]) -> IngredientAnalysis {
        let beneficial = ingredients.compactMap { ingredient -> IngredientInfo? in
            let info = getIngredientInfo(ingredient)
            return info.safetyLevel == .excellent || info.safetyLevel == .good ? info : nil
        }
        
        let concerning = ingredients.compactMap { ingredient -> IngredientInfo? in
            let info = getIngredientInfo(ingredient)
            return info.safetyLevel == .concerning || info.safetyLevel == .harmful ? info : nil
        }
        
        let neutral = ingredients.compactMap { ingredient -> IngredientInfo? in
            let info = getIngredientInfo(ingredient)
            return info.safetyLevel == .moderate ? info : nil
        }
        
        let naturalSynthetic = calculateNaturalSyntheticRatio(ingredients: ingredients)
        
        return IngredientAnalysis(
            beneficial: beneficial,
            concerning: concerning,
            neutral: neutral,
            naturalVsSynthetic: naturalSynthetic
        )
    }
    
    // MARK: - Ingredient Database
    
    private func getIngredientInfo(_ ingredient: String) -> IngredientInfo {
        let lowercased = ingredient.lowercased()
        
        // Beneficial ingredients
        if lowercased.contains("ceramide") {
            return IngredientInfo(
                name: ingredient,
                category: .moisturizer,
                description: "Skin-repairing lipid that strengthens the skin barrier",
                safetyLevel: .excellent,
                benefits: ["Strengthens skin barrier", "Reduces moisture loss", "Anti-aging properties"],
                concerns: []
            )
        }
        
        if lowercased.contains("niacinamide") {
            return IngredientInfo(
                name: ingredient,
                category: .antioxidant,
                description: "Vitamin B3 derivative with multiple skin benefits",
                safetyLevel: .excellent,
                benefits: ["Reduces inflammation", "Minimizes pores", "Improves skin texture"],
                concerns: []
            )
        }
        
        if lowercased.contains("glycerin") || lowercased.contains("glycerol") {
            return IngredientInfo(
                name: ingredient,
                category: .humectant,
                description: "Natural humectant that draws moisture to the skin",
                safetyLevel: .excellent,
                benefits: ["Deep hydration", "Non-irritating", "Suitable for all skin types"],
                concerns: []
            )
        }
        
        if lowercased.contains("hyaluronic acid") {
            return IngredientInfo(
                name: ingredient,
                category: .humectant,
                description: "Powerful hydrating ingredient that holds 1000x its weight in water",
                safetyLevel: .excellent,
                benefits: ["Intense hydration", "Plumps skin", "Reduces fine lines"],
                concerns: []
            )
        }
        
        if lowercased.contains("vitamin c") || lowercased.contains("ascorbic acid") {
            return IngredientInfo(
                name: ingredient,
                category: .antioxidant,
                description: "Powerful antioxidant that brightens and protects skin",
                safetyLevel: .good,
                benefits: ["Brightens skin", "Fights free radicals", "Stimulates collagen"],
                concerns: ["May cause irritation in sensitive skin"]
            )
        }
        
        // Concerning ingredients
        if lowercased.contains("sodium lauryl sulfate") || lowercased.contains("sls") {
            return IngredientInfo(
                name: ingredient,
                category: .surfactant,
                description: "Harsh cleansing agent that can strip natural oils",
                safetyLevel: .concerning,
                benefits: ["Effective cleansing"],
                concerns: ["Can cause dryness", "May irritate sensitive skin", "Strips natural oils"]
            )
        }
        
        if lowercased.contains("paraben") {
            return IngredientInfo(
                name: ingredient,
                category: .preservative,
                description: "Synthetic preservative with potential health concerns",
                safetyLevel: .concerning,
                benefits: ["Prevents bacterial growth"],
                concerns: ["Potential hormone disruption", "May cause allergic reactions"]
            )
        }
        
        if lowercased.contains("sodium benzoate") {
            return IngredientInfo(
                name: ingredient,
                category: .preservative,
                description: "Preservative that may form benzene when combined with vitamin C",
                safetyLevel: .concerning,
                benefits: ["Prevents bacterial growth"],
                concerns: ["May form carcinogenic benzene", "Can cause skin irritation"]
            )
        }
        
        if lowercased.contains("peg") {
            return IngredientInfo(
                name: ingredient,
                category: .surfactant,
                description: "Polyethylene glycol compound that may contain impurities",
                safetyLevel: .moderate,
                benefits: ["Helps ingredients penetrate skin"],
                concerns: ["May contain harmful impurities", "Can cause skin irritation"]
            )
        }
        
        if lowercased.contains("fragrance") || lowercased.contains("parfum") {
            return IngredientInfo(
                name: ingredient,
                category: .fragrance,
                description: "Synthetic fragrance that may cause allergic reactions",
                safetyLevel: .moderate,
                benefits: ["Pleasant scent"],
                concerns: ["May cause allergic reactions", "Can irritate sensitive skin"]
            )
        }
        
        // Default for unknown ingredients
        return IngredientInfo(
            name: ingredient,
            category: .other,
            description: "Ingredient with limited safety data",
            safetyLevel: .moderate,
            benefits: [],
            concerns: ["Limited safety information available"]
        )
    }
    
    // MARK: - Helper Functions
    
    private func parseIngredients(_ ingredientsText: String) -> [String] {
        return ingredientsText
            .components(separatedBy: CharacterSet(charactersIn: ",;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private func parseAdditives(_ labels: [String]) -> [String] {
        return labels.filter { $0.lowercased().contains("additive") }
    }
    
    private func isBeneficialIngredient(_ ingredient: String) -> Bool {
        let beneficialKeywords = ["ceramide", "niacinamide", "glycerin", "hyaluronic", "vitamin c", "retinol", "peptide"]
        let lowercased = ingredient.lowercased()
        return beneficialKeywords.contains { lowercased.contains($0) }
    }
    
    private func isHarmfulAdditive(_ additive: String) -> Bool {
        let harmfulKeywords = ["sodium benzoate", "paraben", "formaldehyde", "triclosan"]
        let lowercased = additive.lowercased()
        return harmfulKeywords.contains { lowercased.contains($0) }
    }
    
    private func calculateNaturalSyntheticRatio(ingredients: [String]) -> NaturalSyntheticRatio {
        let naturalKeywords = ["extract", "oil", "butter", "wax", "glycerin", "vitamin", "mineral"]
        let syntheticKeywords = ["sulfate", "paraben", "peg", "silicone", "synthetic"]
        
        var naturalIngredients: [String] = []
        var syntheticIngredients: [String] = []
        
        for ingredient in ingredients {
            let lowercased = ingredient.lowercased()
            if naturalKeywords.contains(where: { lowercased.contains($0) }) {
                naturalIngredients.append(ingredient)
            } else if syntheticKeywords.contains(where: { lowercased.contains($0) }) {
                syntheticIngredients.append(ingredient)
            }
        }
        
        let total = ingredients.count
        let naturalPercentage = total > 0 ? Double(naturalIngredients.count) / Double(total) * 100 : 0
        let syntheticPercentage = total > 0 ? Double(syntheticIngredients.count) / Double(total) * 100 : 0
        
        return NaturalSyntheticRatio(
            naturalPercentage: naturalPercentage,
            syntheticPercentage: syntheticPercentage,
            naturalIngredients: naturalIngredients,
            syntheticIngredients: syntheticIngredients
        )
    }
    
    // MARK: - Analysis Results
    
    private func extractKeyBenefits(ingredientAnalysis: IngredientAnalysis) -> [String] {
        return ingredientAnalysis.beneficial.prefix(3).map { ingredient in
            ingredient.benefits.first ?? "Contains beneficial \(ingredient.name)"
        }
    }
    
    private func extractMainConcerns(ingredientAnalysis: IngredientAnalysis) -> [String] {
        return ingredientAnalysis.concerning.prefix(3).map { ingredient in
            ingredient.concerns.first ?? "Contains concerning \(ingredient.name)"
        }
    }
    
    private func generateRecommendations(analysis: IngredientAnalysis, verdict: SafetyVerdict) -> [String] {
        var recommendations: [String] = []
        
        switch verdict {
        case .generallySafe:
            recommendations.append("This product appears safe for most skin types")
            if analysis.beneficial.count > 0 {
                recommendations.append("Contains beneficial ingredients for skin health")
            }
        case .useWithCaution:
            recommendations.append("Consider patch testing before full use")
            recommendations.append("Monitor for any skin reactions")
        case .notRecommended:
            recommendations.append("Consider alternative products with safer ingredients")
            recommendations.append("Consult a dermatologist if you have sensitive skin")
        }
        
        if analysis.concerning.contains(where: { $0.category == .fragrance }) {
            recommendations.append("Avoid if you have fragrance sensitivities")
        }
        
        return recommendations
    }
    
    private func determineSkinTypeCompatibility(ingredientAnalysis: IngredientAnalysis) -> [SkinType] {
        var compatible: [SkinType] = [.normal]
        
        // Check for ingredients that benefit specific skin types
        let beneficialIngredients = ingredientAnalysis.beneficial.map { $0.name.lowercased() }
        
        if beneficialIngredients.contains(where: { $0.contains("ceramide") || $0.contains("glycerin") }) {
            compatible.append(.dry)
        }
        
        if beneficialIngredients.contains(where: { $0.contains("niacinamide") }) {
            compatible.append(.oily)
            compatible.append(.acneProne)
        }
        
        if beneficialIngredients.contains(where: { $0.contains("hyaluronic") }) {
            compatible.append(.mature)
        }
        
        // Check for concerning ingredients that affect sensitive skin
        let concerningIngredients = ingredientAnalysis.concerning.map { $0.name.lowercased() }
        if !concerningIngredients.contains(where: { $0.contains("fragrance") || $0.contains("sulfate") }) {
            compatible.append(.sensitive)
        }
        
        return Array(Set(compatible)) // Remove duplicates
    }
    
    private func generateAlternativeSuggestions(concerns: [String]) -> [String] {
        var suggestions: [String] = []
        
        if concerns.contains(where: { $0.lowercased().contains("sulfate") }) {
            suggestions.append("Look for sulfate-free cleansers")
        }
        
        if concerns.contains(where: { $0.lowercased().contains("paraben") }) {
            suggestions.append("Choose paraben-free alternatives")
        }
        
        if concerns.contains(where: { $0.lowercased().contains("fragrance") }) {
            suggestions.append("Opt for fragrance-free products")
        }
        
        if suggestions.isEmpty {
            suggestions.append("Look for products with ceramides and hyaluronic acid")
        }
        
        return suggestions
    }
    
    private func generateUsageTips(ingredientAnalysis: IngredientAnalysis, productInfo: ProductInfo) -> [String] {
        var tips: [String] = []
        
        if ingredientAnalysis.beneficial.contains(where: { $0.name.lowercased().contains("vitamin c") }) {
            tips.append("Use in the morning for antioxidant protection")
        }
        
        if ingredientAnalysis.beneficial.contains(where: { $0.name.lowercased().contains("retinol") }) {
            tips.append("Start with 2-3 times per week and use at night")
        }
        
        if ingredientAnalysis.concerning.contains(where: { $0.name.lowercased().contains("sulfate") }) {
            tips.append("Follow with a gentle, hydrating moisturizer")
        }
        
        if tips.isEmpty {
            tips.append("Always patch test new products")
            tips.append("Use as directed on the packaging")
        }
        
        return tips
    }
}
