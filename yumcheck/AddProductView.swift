//
//  AddProductView.swift
//  yumcheck
//
//  Created by Assistant on 03/09/2025.
//

import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var productName = ""
    @State private var brand = ""
    @State private var barcode = ""
    @State private var category = ""
    @State private var ingredients = ""
    @State private var labels: [String] = []
    @State private var allergens: [String] = []
    @State private var ecoScore = ""
    @State private var selectedImage: UIImage?
    @State private var uploadedImageUrl: String?
    @State private var isUploadingImage = false
    @State private var showOCRCapture = false
    @State private var quantity = ""
    
    @State private var newLabel = ""
    @State private var newAllergen = ""
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // Navigation callback for successful save
    let onProductAdded: ((ProductInfo) -> Void)?
    
    // Initializer with optional barcode pre-fill and callback
    init(prefilledBarcode: String? = nil, onProductAdded: ((ProductInfo) -> Void)? = nil) {
        self.onProductAdded = onProductAdded
        self._barcode = State(initialValue: prefilledBarcode ?? "")
    }
    
    private let categories = [
        "Skincare", "Haircare", "Makeup", "Fragrance", "Body Care", 
        "Oral Care", "Baby Care", "Men's Care", "Sun Care", "Other"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Add New Product")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Help expand our database by adding product information")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Basic Information Section
                        FormSection(title: "Basic Information", icon: "info.circle.fill") {
                            VStack(spacing: 16) {
                                FormField(
                                    title: "Product Name *",
                                    text: $productName,
                                    placeholder: "Enter product name"
                                )
                                
                                FormField(
                                    title: "Brand *",
                                    text: $brand,
                                    placeholder: "Enter brand name"
                                )
                                
                                FormField(
                                    title: "Barcode *",
                                    text: $barcode,
                                    placeholder: "Enter 13-digit barcode",
                                    keyboardType: .numberPad
                                )
                                
                                FormField(
                                    title: "Category",
                                    text: $category,
                                    placeholder: "Select category"
                                )
                                
                                FormField(
                                    title: "Quantity",
                                    text: $quantity,
                                    placeholder: "e.g., 100ml, 50g"
                                )
                            }
                        }
                        
                        // Ingredients Section
                        FormSection(title: "Ingredients", icon: "leaf.fill") {
                            VStack(spacing: 16) {
                                // OCR Scan Button
                                Button(action: {
                                    showOCRCapture = true
                                }) {
                                    HStack {
                                        Image(systemName: "text.viewfinder")
                                            .foregroundColor(.blue)
                                        Text("Scan Ingredients Label")
                                            .foregroundColor(.blue)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                FormField(
                                    title: "Ingredients List",
                                    text: $ingredients,
                                    placeholder: "Enter ingredients separated by commas, or scan from label",
                                    isMultiline: true
                                )
                            }
                        }
                        
                        // Image Section
                        FormSection(title: "Product Image", icon: "camera.fill") {
                            VStack(spacing: 16) {
                                ImagePickerView(selectedImage: $selectedImage, isPresented: .constant(false))
                                
                                if isUploadingImage {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Uploading image...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if uploadedImageUrl != nil {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Image uploaded successfully")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                            }
                        }
                        
                        // Labels Section
                        FormSection(title: "Labels & Claims", icon: "tag.fill") {
                            VStack(spacing: 16) {
                                HStack {
                                    TextField("Add label (e.g., Vegan, Cruelty-Free)", text: $newLabel)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button("Add") {
                                        addLabel()
                                    }
                                    .disabled(newLabel.isEmpty)
                                }
                                
                                if !labels.isEmpty {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        ForEach(labels, id: \.self) { label in
                                            LabelChip(label: label) {
                                                removeLabel(label)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Allergens Section
                        FormSection(title: "Allergens", icon: "exclamationmark.triangle.fill") {
                            VStack(spacing: 16) {
                                HStack {
                                    TextField("Add allergen", text: $newAllergen)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button("Add") {
                                        addAllergen()
                                    }
                                    .disabled(newAllergen.isEmpty)
                                }
                                
                                if !allergens.isEmpty {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        ForEach(allergens, id: \.self) { allergen in
                                            AllergenChip(allergen: allergen) {
                                                removeAllergen(allergen)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Eco Score Section
                        FormSection(title: "Environmental Info", icon: "leaf.arrow.circlepath") {
                            VStack(spacing: 16) {
                                FormField(
                                    title: "Eco Score",
                                    text: $ecoScore,
                                    placeholder: "e.g., A, B, C, D, E"
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Submit Button
                    VStack(spacing: 16) {
                        Button(action: submitProduct) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "cloud.upload.fill")
                                }
                                
                                Text(isLoading ? "Adding Product..." : "Add to Database")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || isLoading)
                        
                        Text("* Required fields")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    // Call the navigation callback if provided
                    if let callback = onProductAdded {
                        let newProduct = ProductInfo(
                            barcode: barcode,
                            productName: productName,
                            brands: brand,
                            ingredientsText: ingredients.isEmpty ? nil : ingredients,
                            imageUrl: uploadedImageUrl != nil ? URL(string: uploadedImageUrl!) : nil,
                            category: category.isEmpty ? nil : category,
                            quantity: quantity.isEmpty ? nil : quantity,
                            imageFrontUrl: nil,
                            imageIngredientsUrl: nil,
                            imagePackagingUrl: nil,
                            labels: labels,
                            ecoScore: ecoScore.isEmpty ? nil : ecoScore,
                            allergens: allergens
                        )
                        callback(newProduct)
                    }
                    dismiss()
                }
            } message: {
                Text("Product has been successfully added to the database!")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showOCRCapture) {
            VisionCameraCaptureView(
                extractedText: $ingredients,
                isPresented: $showOCRCapture
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !productName.isEmpty && !brand.isEmpty && !barcode.isEmpty
    }
    
    // MARK: - Actions
    
    private func addLabel() {
        let trimmedLabel = newLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedLabel.isEmpty && !labels.contains(trimmedLabel) {
            labels.append(trimmedLabel)
            newLabel = ""
        }
    }
    
    private func removeLabel(_ label: String) {
        labels.removeAll { $0 == label }
    }
    
    private func addAllergen() {
        let trimmedAllergen = newAllergen.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedAllergen.isEmpty && !allergens.contains(trimmedAllergen) {
            allergens.append(trimmedAllergen)
            newAllergen = ""
        }
    }
    
    private func removeAllergen(_ allergen: String) {
        allergens.removeAll { $0 == allergen }
    }
    
    private func submitProduct() {
        guard isFormValid else { return }
        
        isLoading = true
        
        // If there's a selected image but no uploaded URL, upload the image first
        if let image = selectedImage, uploadedImageUrl == nil {
            uploadImageAndSubmit(image)
        } else {
            // No image or already uploaded, proceed with product submission
            submitProductWithImage()
        }
    }
    
    private func uploadImageAndSubmit(_ image: UIImage) {
        isUploadingImage = true
        let fileName = ImageUploadService.shared.generateFileName(for: barcode)
        
        ImageUploadService.shared.uploadImage(image, fileName: fileName) { result in
            DispatchQueue.main.async {
                isUploadingImage = false
                
                switch result {
                case .success(let imageUrl):
                    uploadedImageUrl = imageUrl
                    submitProductWithImage()
                case .failure(let error):
                    isLoading = false
                    errorMessage = "Failed to upload image: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func submitProductWithImage() {
        // Create ProductInfo object
        let newProduct = ProductInfo(
            barcode: barcode,
            productName: productName,
            brands: brand,
            ingredientsText: ingredients.isEmpty ? nil : ingredients,
            imageUrl: uploadedImageUrl != nil ? URL(string: uploadedImageUrl!) : nil,
            category: category.isEmpty ? nil : category,
            quantity: quantity.isEmpty ? nil : quantity,
            imageFrontUrl: nil,
            imageIngredientsUrl: nil,
            imagePackagingUrl: nil,
            labels: labels,
            ecoScore: ecoScore.isEmpty ? nil : ecoScore,
            allergens: allergens
        )
        
        // Add to database
        AddProductService.shared.addProduct(newProduct) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    showSuccessAlert = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
}

// MARK: - Supporting Views

struct FormSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            if isMultiline {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                        .focused($isFocused)
                    
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
                .onTapGesture {
                    isFocused = true
                }
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
                    .focused($isFocused)
            }
        }
    }
}

struct LabelChip: View {
    let label: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.blue)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AllergenChip: View {
    let allergen: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(allergen)
                .font(.caption)
                .foregroundColor(.red)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    AddProductView()
}
