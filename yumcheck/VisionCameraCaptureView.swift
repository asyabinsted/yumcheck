//
//  MLKitCameraCaptureView.swift
//  yumcheck
//
//  Created by Assistant on 16/09/2025.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct VisionCameraCaptureView: View {
    @Binding var extractedText: String
    @Binding var isPresented: Bool
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var capturedImage: UIImage?
    @State private var showingTextSelection = false
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
                    
                    Text("Take a photo of the ingredients label for intelligent text recognition")
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
                        InstructionRow(icon: "textformat", text: "ML Kit will highlight text regions for selection")
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
                    
                    // Manual Input Button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Enter Manually Instead")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Scan Ingredients")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            VisionCameraView(
                onImageCaptured: { image in
                    print("📸 VisionCameraCaptureView: Image captured, size: \(image.size)")
                    capturedImage = image
                    showingCamera = false
                    showingTextSelection = true
                    print("📸 VisionCameraCaptureView: showingTextSelection set to true")
                },
                onCancel: {
                    showingCamera = false
                }
            )
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            VisionPhotoLibraryPicker(
                onImageSelected: { image in
                    print("📸 VisionCameraCaptureView: Image selected from library, size: \(image.size)")
                    capturedImage = image
                    showingPhotoLibrary = false
                    showingTextSelection = true
                    print("📸 VisionCameraCaptureView: showingTextSelection set to true")
                },
                onCancel: {
                    showingPhotoLibrary = false
                }
            )
        }
        .sheet(isPresented: $showingTextSelection) {
            if let image = capturedImage {
                TextSelectionView(
                    image: image,
                    onTextExtracted: { text in
                        print("📸 VisionCameraCaptureView: Text extracted: \(text)")
                        extractedText = text
                        showingTextSelection = false
                        isPresented = false
                    },
                    onCancel: {
                        print("📸 VisionCameraCaptureView: TextSelectionView cancelled")
                        showingTextSelection = false
                    }
                )
                .onAppear {
                    print("📸 VisionCameraCaptureView: Presenting TextSelectionView with image size: \(image.size)")
                }
            } else {
                Text("Error: No image captured.")
                    .onAppear {
                        print("❌ VisionCameraCaptureView: No captured image available for TextSelectionView")
                        print("❌ VisionCameraCaptureView: capturedImage is nil")
                        print("❌ VisionCameraCaptureView: showingTextSelection = \(showingTextSelection)")
                    }
            }
        }
        .onChange(of: capturedImage) { newImage in
            print("📸 VisionCameraCaptureView: capturedImage changed to: \(newImage?.size ?? CGSize.zero)")
        }
        .onChange(of: showingTextSelection) { newValue in
            print("📸 VisionCameraCaptureView: showingTextSelection changed to: \(newValue)")
            if newValue {
                print("📸 VisionCameraCaptureView: capturedImage when showingTextSelection becomes true: \(capturedImage?.size ?? CGSize.zero)")
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
            showingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    } else {
                        showPermissionAlert(for: "camera")
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
                showingPhotoLibrary = true
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    DispatchQueue.main.async {
                        if status == .authorized || status == .limited {
                            showingPhotoLibrary = true
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
                showingPhotoLibrary = true
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized || status == .limited {
                            showingPhotoLibrary = true
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
}

// MARK: - Camera View

struct VisionCameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.cameraDevice = .rear
        picker.cameraFlashMode = .auto
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VisionCameraView
        
        init(_ parent: VisionCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.onImageCaptured(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.onImageCaptured(originalImage)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}

// MARK: - Photo Library Picker

struct VisionPhotoLibraryPicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    let onCancel: () -> Void
    
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
        let parent: VisionPhotoLibraryPicker
        
        init(_ parent: VisionPhotoLibraryPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.onCancel()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.parent.onImageSelected(image)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 16)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
