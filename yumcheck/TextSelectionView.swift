//
//  TextSelectionView.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import SwiftUI

struct TextSelectionView: View {
    let image: UIImage
    @State private var textElements: [TextElement] = []
    @State private var isLoading = true
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var extractedText = ""
    @State private var showPreview = false
    
    let onTextExtracted: (String) -> Void
    let onCancel: () -> Void
    
    init(image: UIImage, onTextExtracted: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.image = image
        self.onTextExtracted = onTextExtracted
        self.onCancel = onCancel
        print("🔍 TextSelectionView: Initialized with image size: \(image.size)")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    // Loading view
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Analyzing text...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("ML Kit is detecting text regions")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    // Text selection interface
                    VStack(spacing: 0) {
                        // Image with text overlays
                        GeometryReader { geometry in
                            ZStack {
                                // Background image
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                                
                                // Text element overlays
                                ForEach(Array(textElements.enumerated()), id: \.offset) { index, element in
                                    TextElementOverlay(
                                        element: element,
                                        imageSize: image.size,
                                        containerSize: geometry.size,
                                        onTap: {
                                            toggleElementSelection(at: index)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Bottom controls
                        VStack(spacing: 16) {
                            // Selection summary
                            HStack {
                                Text("\(selectedElementsCount) of \(textElements.count) text regions selected")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button("Select All") {
                                    selectAllElements()
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            // Action buttons
                            HStack(spacing: 16) {
                                Button("Retake Photo") {
                                    onCancel()
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(12)
                                
                                Button("Use Selected Text") {
                                    extractSelectedText()
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedElementsCount > 0 ? Color.blue : Color.gray)
                                .cornerRadius(12)
                                .disabled(selectedElementsCount == 0)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                        .background(Color.black.opacity(0.8))
                    }
                }
            }
            .navigationTitle("Select Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            performTextRecognition()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showPreview) {
            TextPreviewView(
                extractedText: extractedText,
                onConfirm: {
                    onTextExtracted(extractedText)
                },
                onCancel: {
                    showPreview = false
                }
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var selectedElementsCount: Int {
        textElements.filter { $0.isSelected }.count
    }
    
    // MARK: - Actions
    
    private func performTextRecognition() {
        print("🔍 TextSelectionView: Starting text recognition...")
        print("🔍 TextSelectionView: Image size: \(image.size)")
        
        VisionTextRecognitionService.shared.recognizeTextInImage(image) { result in
            print("🔍 TextSelectionView: Recognition completed")
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let elements):
                    self.textElements = elements
                    print("✅ TextSelectionView: Found \(elements.count) text elements")
                case .failure(let error):
                    print("❌ TextSelectionView: Recognition failed: \(error.localizedDescription)")
                    self.errorMessage = "Failed to recognize text: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    private func toggleElementSelection(at index: Int) {
        textElements[index].isSelected.toggle()
    }
    
    private func selectAllElements() {
        for index in textElements.indices {
            textElements[index].isSelected = true
        }
    }
    
    private func extractSelectedText() {
        let selectedElements = textElements.filter { $0.isSelected }
        let text = selectedElements.map { $0.text }.joined(separator: " ")
        let cleanedText = cleanAndFormatIngredientsText(text)
        
        extractedText = cleanedText
        showPreview = true
    }
    
    private func cleanAndFormatIngredientsText(_ text: String) -> String {
        var cleanedText = text
        
        // Remove common OCR artifacts
        cleanedText = cleanedText.replacingOccurrences(of: "|", with: "I")
        cleanedText = cleanedText.replacingOccurrences(of: "0", with: "O")
        cleanedText = cleanedText.replacingOccurrences(of: "5", with: "S")
        
        // Remove extra whitespace
        cleanedText = cleanedText.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split by common separators
        let separators = [",", ";", "\n", "•", "·", "▪", "▫"]
        var ingredients: [String] = []
        
        for separator in separators {
            if cleanedText.contains(separator) {
                ingredients = cleanedText.components(separatedBy: separator)
                break
            }
        }
        
        if ingredients.isEmpty {
            ingredients = [cleanedText]
        }
        
        // Clean each ingredient
        let cleanedIngredients = ingredients.compactMap { ingredient -> String? in
            let cleaned = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            
            guard cleaned.count > 2 else { return nil }
            
            return cleaned.prefix(1).uppercased() + cleaned.dropFirst().lowercased()
        }
        
        return cleanedIngredients.joined(separator: ", ")
    }
}

// MARK: - Text Element Overlay

struct TextElementOverlay: View {
    let element: TextElement
    let imageSize: CGSize
    let containerSize: CGSize
    let onTap: () -> Void
    
    var body: some View {
        Rectangle()
            .stroke(element.isSelected ? Color.blue : Color.gray, lineWidth: 2)
            .background(
                Rectangle()
                    .fill(element.isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .frame(
                width: scaledFrame.width,
                height: scaledFrame.height
            )
            .position(
                x: scaledFrame.midX,
                y: scaledFrame.midY
            )
            .onTapGesture {
                onTap()
            }
            .overlay(
                // Confidence indicator
                VStack {
                    HStack {
                        Spacer()
                        Text(String(format: "%.0f%%", element.confidence * 100))
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(2)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                    }
                    Spacer()
                }
                .frame(
                    width: scaledFrame.width,
                    height: scaledFrame.height
                )
                .position(
                    x: scaledFrame.midX,
                    y: scaledFrame.midY
                )
            )
    }
    
    private var scaledFrame: CGRect {
        // Scale the element frame from image coordinates to container coordinates
        let scaleX = containerSize.width / imageSize.width
        let scaleY = containerSize.height / imageSize.height
        
        return CGRect(
            x: element.frame.origin.x * scaleX,
            y: element.frame.origin.y * scaleY,
            width: element.frame.width * scaleX,
            height: element.frame.height * scaleY
        )
    }
}

// MARK: - Text Preview View

struct TextPreviewView: View {
    let extractedText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @State private var editableText: String
    
    init(extractedText: String, onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.extractedText = extractedText
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self._editableText = State(initialValue: extractedText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("Extracted Text")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Review and edit the extracted ingredients text")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Editable text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients:")
                        .font(.headline)
                    
                    TextEditor(text: $editableText)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button("Use This Text") {
                        onConfirm()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Review Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onConfirm()
                    }
                }
            }
        }
    }
}
