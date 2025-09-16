//
//  OCRCaptureView.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct OCRCaptureView: View {
    @Binding var extractedText: String
    @Binding var isPresented: Bool
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Scan Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Take a photo of the ingredients label to automatically extract the text")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tips for best results:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        InstructionRow(icon: "camera.fill", text: "Ensure good lighting")
                        InstructionRow(icon: "doc.text.fill", text: "Keep the label flat and straight")
                        InstructionRow(icon: "magnifyingglass", text: "Make sure text is clearly visible")
                        InstructionRow(icon: "hand.raised.fill", text: "Hold the camera steady")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Camera Button
                    Button(action: {
                        checkCameraPermission()
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isProcessing)
                    
                    // Photo Library Button
                    Button(action: {
                        checkPhotoLibraryPermission()
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Choose from Library")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(isProcessing)
                    
                    // Manual Input Button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Enter Manually Instead")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .disabled(isProcessing)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Scan Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Select Image Source"),
                buttons: [
                    .default(Text("Camera")) {
                        checkCameraPermission()
                    },
                    .default(Text("Photo Library")) {
                        checkPhotoLibraryPermission()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            if sourceType == .camera {
                OCRCameraPickerView(selectedImage: $selectedImage, isPresented: $showingImagePicker)
            } else {
                OCRPhotoLibraryPickerView(selectedImage: $selectedImage, isPresented: $showingImagePicker)
            }
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                processImageWithOCR(image)
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Permission Handling
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sourceType = .camera
            showingImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        sourceType = .camera
                        showingImagePicker = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert(for: "camera")
        @unknown default:
            break
        }
    }
    
    private func checkPhotoLibraryPermission() {
        if #available(iOS 14, *) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .authorized, .limited:
                sourceType = .photoLibrary
                showingImagePicker = true
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    DispatchQueue.main.async {
                        if status == .authorized || status == .limited {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        } else {
                            showPermissionAlert(for: "photo library")
                        }
                    }
                }
            case .denied, .restricted:
                showPermissionAlert(for: "photo library")
            @unknown default:
                break
            }
        } else {
            // Fallback for iOS 13 and earlier
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized, .limited:
                sourceType = .photoLibrary
                showingImagePicker = true
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized || status == .limited {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        } else {
                            showPermissionAlert(for: "photo library")
                        }
                    }
                }
            case .denied, .restricted:
                showPermissionAlert(for: "photo library")
            @unknown default:
                break
            }
        }
    }
    
    private func showPermissionAlert(for type: String) {
        errorMessage = "Please enable \(type) access in Settings to scan ingredients."
        showErrorAlert = true
    }
    
    // MARK: - OCR Processing
    
    private func processImageWithOCR(_ image: UIImage) {
        isProcessing = true
        
        OCRService.shared.extractTextFromImage(image) { result in
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success(let text):
                    if text.isEmpty {
                        errorMessage = "No text was found in the image. Please try again with better lighting or a clearer image."
                        showErrorAlert = true
                    } else {
                        extractedText = text
                        isPresented = false
                    }
                case .failure(let error):
                    errorMessage = "Failed to extract text: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Supporting Views
// Note: InstructionRow is now defined in VisionCameraCaptureView.swift

// MARK: - OCR Camera Picker

struct OCRCameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: OCRCameraPickerView
        
        init(_ parent: OCRCameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// MARK: - OCR Photo Library Picker

struct OCRPhotoLibraryPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: OCRPhotoLibraryPickerView
        
        init(_ parent: OCRPhotoLibraryPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.parent.selectedImage = image
                    }
                }
            }
        }
    }
}
