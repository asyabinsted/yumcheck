//
//  ContentView.swift
//  yumcheck
//
//  Created by Asya Binsted on 28/08/2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    let onProductFound: (ProductInfo, String) -> Void
    let onProductNotFound: (String) -> Void
    
    @State private var isPresentingScanner = false
    @State private var lastScannedCode: String? = nil
    @State private var cameraAccessDenied = false
    @State private var showPermissionAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var currentLookupTask: URLSessionDataTask? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Yumcheck")
                        .font(.largeTitle).bold()
                        .foregroundColor(Color(.label))
                    Text("Scan beauty product barcodes to get details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 160)
                    VStack(spacing: 8) {
                        Text("Last scanned barcode")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text(lastScannedCode ?? "—")
                            .font(.title3).bold()
                            .foregroundColor(Color(.label))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal)
                        if isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Looking up product...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Cancel") {
                                    cancelLookup()
                                }
                                .font(.caption)
                                .foregroundColor(Color(red: 255/255, green: 59/255, blue: 48/255)) // #FF3B30
                                .padding(.top, 4)
                            }
                            .padding(.top, 6)
                        }
                    }
                }

                Button(action: requestAndPresentScanner) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scan Barcode")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0/255, green: 122/255, blue: 255/255)) // #007AFF
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                if cameraAccessDenied {
                    Text("Camera access is required to scan barcodes. Enable it in Settings.")
                        .font(.footnote)
                        .foregroundColor(Color(red: 255/255, green: 59/255, blue: 48/255)) // #FF3B30
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Product info is now displayed on the dedicated ProductPageView
                // No need to show it here on the scan page

                if let msg = errorMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(Color(red: 255/255, green: 59/255, blue: 48/255)) // #FF3B30
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Home")
        }
        .sheet(isPresented: $isPresentingScanner) {
            ScannerView { code in
                lastScannedCode = code
                isPresentingScanner = false
                fetchProduct(for: code)
            } onCancel: {
                isPresentingScanner = false
            }
            .ignoresSafeArea()
        }
        .alert("Camera Access Needed", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to scan barcodes.")
        }
    }

    private func fetchProduct(for code: String) {
        print("🔄 [DEBUG] ContentView: Starting fetchProduct for barcode: \(code)")
        print("🔄 [DEBUG] ContentView: Current thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("🔄 [DEBUG] ContentView: Timestamp: \(Date())")
        print("🔄 [DEBUG] ContentView: Setting isLoading = true")
        
        isLoading = true
        errorMessage = nil

        print("🔄 [DEBUG] ContentView: Calling UnifiedProductService.getProduct...")
        let startTime = Date()
        
        currentLookupTask = UnifiedProductService.shared.getProduct(barcode: code) { result in
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            print("🔄 [DEBUG] ContentView: Received result for barcode: \(code)")
            print("🔄 [DEBUG] ContentView: Result received in: \(duration * 1000)ms")
            print("🔄 [DEBUG] ContentView: Result thread: \(Thread.isMainThread ? "Main" : "Background")")
            print("🔄 [DEBUG] ContentView: Result timestamp: \(Date())")
            
            DispatchQueue.main.async {
                print("🔄 [DEBUG] ContentView: Inside DispatchQueue.main.async")
                print("🔄 [DEBUG] ContentView: Main thread: \(Thread.isMainThread ? "Main" : "Background")")
                print("🔄 [DEBUG] ContentView: Setting isLoading = false")
                
                self.isLoading = false
                self.currentLookupTask = nil
                
                switch result {
                case .success(let info):
                    print("✅ [DEBUG] ContentView: Success - Product: \(info.productName ?? "Unknown")")
                    
                    // Log to history
                    print("📝 [DEBUG] ContentView: Adding to history...")
                    LocalDatabaseService.shared.addToHistory(barcode: code, product: info)
                    print("📝 [DEBUG] ContentView: Added to history: \(info.productName ?? "Unknown")")
                    
                    // Navigate to product page immediately
                    print("✅ [DEBUG] ContentView: Calling onProductFound on thread: \(Thread.isMainThread ? "Main" : "Background")")
                    self.onProductFound(info, code)
                    print("✅ [DEBUG] ContentView: onProductFound called successfully")
                case .failure(let err):
                    print("❌ [DEBUG] ContentView: Failure - Error: \(err.localizedDescription)")
                    print("❌ [DEBUG] ContentView: Error type: \(type(of: err))")
                    
                    // Check if it's a cancellation - don't navigate if cancelled
                    if (err as NSError).code == NSURLErrorCancelled {
                        print("🛑 [DEBUG] Lookup was cancelled by user")
                        return
                    }
                    
                    // Log to history (product not found)
                    print("📝 [DEBUG] ContentView: Adding to history (product not found)...")
                    LocalDatabaseService.shared.addToHistory(barcode: code, product: nil)
                    print("📝 [DEBUG] ContentView: Added to history: Product not found")
                    
                    // Navigate to product not found page
                    print("❌ [DEBUG] ContentView: Calling onProductNotFound on thread: \(Thread.isMainThread ? "Main" : "Background")")
                    self.onProductNotFound(code)
                    print("❌ [DEBUG] ContentView: onProductNotFound called successfully")
                }
            }
        }
        
        print("🔄 [DEBUG] ContentView: UnifiedProductService.getProduct called, task assigned")
    }
    
    private func cancelLookup() {
        print("🛑 ContentView: Cancelling product lookup")
        currentLookupTask?.cancel()
        currentLookupTask = nil
        isLoading = false
        errorMessage = nil
    }

    private func requestAndPresentScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAccessDenied = false
            isPresentingScanner = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraAccessDenied = !granted
                    self.isPresentingScanner = granted
                }
            }
        case .denied, .restricted:
            cameraAccessDenied = true
            showPermissionAlert = true
        @unknown default:
            cameraAccessDenied = true
        }
    }
}

// MARK: - Product Summary Card (high-level overview)
struct ProductSummaryCard: View {
    let product: ProductInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: product.imageFrontUrl ?? product.imageUrl) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    ZStack { Color(.secondarySystemBackground); Image(systemName: "photo").foregroundColor(.secondary) }
                }
                .frame(width: 90, height: 90)
                .clipped()
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 6) {
                    Text(product.productName ?? "Unknown Product")
                        .font(.headline)
                        .lineLimit(2)
                    if let brand = product.brands, !brand.isEmpty {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 8) {
                        if let cat = product.category, !cat.isEmpty {
                            TagView(text: cat)
                        }
                        if let qty = product.quantity, !qty.isEmpty {
                            TagView(text: qty)
                        }
                    }
                }
                Spacer()
            }

            // Positive / Neutral / Caution summary
            SummaryRow(product: product)

            // Images strip
            HStack(spacing: 8) {
                Thumbnail(url: product.imageFrontUrl ?? product.imageUrl, label: "Front")
                Thumbnail(url: product.imageIngredientsUrl, label: "Ingredients")
                Thumbnail(url: product.imagePackagingUrl, label: "Packaging")
            }

            // Expandable sections
            DisclosureGroup("Ingredients") {
                IngredientList(ingredientsText: product.ingredientsText)
            }

            DisclosureGroup("Allergens / Safety") {
                if product.allergens.isEmpty {
                    Text("None detected").foregroundColor(.secondary)
                } else {
                    WrapTags(tags: product.allergens.map { $0.replacingOccurrences(of: "en:", with: "") })
                }
            }

            DisclosureGroup("Eco / Labels") {
                VStack(alignment: .leading, spacing: 8) {
                    if !product.labels.isEmpty {
                        WrapTags(tags: product.labels.map { $0.replacingOccurrences(of: "en:", with: "") })
                    } else {
                        Text("No labels provided").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Eco-score:")
                        EcoScoreBadge(grade: product.ecoScore)
                    }
                }
            }
        }
        .padding()
        .background(Color(red: 248/255, green: 249/255, blue: 250/255)) // #F8F9FA
        .cornerRadius(16)
    }
}

// MARK: - Components
struct TagView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 3).padding(.horizontal, 8)
            .background(Color(red: 242/255, green: 242/255, blue: 247/255)) // #F2F2F7
            .cornerRadius(8)
    }
}

struct Thumbnail: View {
    let url: URL?
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: url) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                ZStack { Color(red: 242/255, green: 242/255, blue: 247/255); Image(systemName: "photo").foregroundColor(.secondary) }
            }
            .frame(width: 80, height: 60)
            .clipped()
            .cornerRadius(8)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
    }
}

struct SummaryRow: View {
    let product: ProductInfo

    private var ingredientBuckets: (positive: Int, neutral: Int, caution: Int) {
        let (p, n, c) = IngredientClassifier.classify(text: product.ingredientsText ?? "")
        return (p.count, n.count, c.count)
    }

    var body: some View {
        HStack(spacing: 12) {
            SummaryPill(icon: "checkmark.circle.fill", color: Color(red: 52/255, green: 199/255, blue: 89/255), value: ingredientBuckets.positive, label: "Positive")
            SummaryPill(icon: "exclamationmark.circle.fill", color: Color(red: 255/255, green: 214/255, blue: 10/255), value: ingredientBuckets.neutral, label: "Neutral")
            SummaryPill(icon: "xmark.octagon.fill", color: Color(red: 255/255, green: 59/255, blue: 48/255), value: ingredientBuckets.caution, label: "Caution")
            Spacer()
        }
    }
}

struct SummaryPill: View {
    let icon: String
    let color: Color
    let value: Int
    let label: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(color)
            Text("\(value)")
                .font(.subheadline).bold()
            Text(label).font(.caption).foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(red: 242/255, green: 242/255, blue: 247/255)) // #F2F2F7
        .cornerRadius(10)
    }
}

struct IngredientList: View {
    let ingredientsText: String?
    private var items: [String] {
        IngredientClassifier.tokenize(text: ingredientsText ?? "")
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                let type = IngredientClassifier.classifySingle(item)
                HStack(alignment: .top, spacing: 8) {
                    switch type {
                    case .positive: Image(systemName: "checkmark.circle").foregroundColor(Color(red: 52/255, green: 199/255, blue: 89/255))
                    case .neutral: Image(systemName: "exclamationmark.circle").foregroundColor(Color(red: 255/255, green: 214/255, blue: 10/255))
                    case .caution: Image(systemName: "xmark.octagon").foregroundColor(Color(red: 255/255, green: 59/255, blue: 48/255))
                    }
                    Text(item).font(.footnote)
                }
            }
        }
    }
}

struct EcoScoreBadge: View {
    let grade: String?
    private var displayGrade: String { (grade ?? "-").uppercased() }
    var body: some View {
        Text(displayGrade)
            .font(.caption).bold()
            .padding(.vertical, 3).padding(.horizontal, 8)
            .background(color(for: displayGrade))
            .foregroundColor(.white)
            .cornerRadius(6)
    }
    private func color(for g: String) -> Color {
        switch g {
        case "A": return Color(red: 52/255, green: 199/255, blue: 89/255) // #34C759
        case "B": return Color(red: 52/255, green: 199/255, blue: 89/255).opacity(0.8)
        case "C": return Color(red: 255/255, green: 214/255, blue: 10/255) // #FFD60A
        case "D": return Color(red: 255/255, green: 149/255, blue: 0/255) // #FF9500
        case "E": return Color(red: 255/255, green: 59/255, blue: 48/255) // #FF3B30
        default: return Color(red: 142/255, green: 142/255, blue: 147/255) // #8E8E93
        }
    }
}

struct WrapTags: View {
    let tags: [String]
    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 8)]
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagView(text: tag)
            }
        }
    }
}

// MARK: - Simple Ingredient Classifier (heuristic)
enum IngredientType { case positive, neutral, caution }

enum IngredientClassifier {
    // Very simple heuristic lists
    static let positives = ["glycerin", "aloe", "aloe vera", "hyaluronic", "squalane", "niacinamide", "ceramide", "panthenol"]
    static let cautions = ["paraben", "parabens", "phthalate", "formaldehyde", "triclosan", "bha", "bht", "sls", "sodium lauryl sulfate", "aluminum", "lead", "fragrance", "parfum"]

    static func tokenize(text: String) -> [String] {
        return text
            .replacingOccurrences(of: "\n", with: " ")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func classify(text: String) -> (positive: [String], neutral: [String], caution: [String]) {
        var positive: [String] = []
        var neutral: [String] = []
        var caution: [String] = []
        for token in tokenize(text: text) {
            switch classifySingle(token) {
            case .positive: positive.append(token)
            case .neutral: neutral.append(token)
            case .caution: caution.append(token)
            }
        }
        return (positive, neutral, caution)
    }

    static func classifySingle(_ token: String) -> IngredientType {
        let lower = token.lowercased()
        if positives.contains(where: { lower.contains($0) }) { return .positive }
        if cautions.contains(where: { lower.contains($0) }) { return .caution }
        return .neutral
    }
}

struct ScannerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ScannerViewController

    var onScanned: (String) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onScanned = onScanned
        vc.onCancel = onCancel
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) { }
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onScanned: ((String) -> Void)?
    var onCancel: (() -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasCaptured = false
    private var confirmationView: UIView?

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    private func setupCamera() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = supportedTypes
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        // Starting the capture session on a background queue prevents UI freezes
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    private var supportedTypes: [AVMetadataObject.ObjectType] {
        // Restrict to retail product barcodes
        return [.ean13, .ean8, .upce]
    }

    private func setupOverlay() {
        view.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        // Simple white frame in the center
        let frameView = UIView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.borderWidth = 2
        frameView.layer.cornerRadius = 12
        view.addSubview(frameView)
        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            frameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            frameView.heightAnchor.constraint(equalTo: frameView.widthAnchor)
        ])
    }

    @objc private func cancelTapped() {
        captureSession.stopRunning()
        onCancel?()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasCaptured,
              let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = obj.stringValue else { return }

        // Keep digits only to normalize UPC/EAN formats
        let numeric = value.filter { $0.isNumber }
        guard numeric.count >= 8 else { return }

        hasCaptured = true

        // Visual confirmation: quick flash + overlay with code
        flashScreen()
        showConfirmationOverlay(code: numeric)

        // Stop session after brief delay to allow flash animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.captureSession.stopRunning()
        }

        // Return code slightly after UI feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.onScanned?(numeric)
        }
    }

    private func flashScreen() {
        let flash = UIView(frame: view.bounds)
        flash.backgroundColor = .white
        flash.alpha = 0.0
        view.addSubview(flash)
        UIView.animate(withDuration: 0.08, animations: {
            flash.alpha = 0.6
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                flash.alpha = 0.0
            }) { _ in
                flash.removeFromSuperview()
            }
        }
    }

    private func showConfirmationOverlay(code: String) {
        confirmationView?.removeFromSuperview()

        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 12
        container.clipsToBounds = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Scanned: \(code)"

        container.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: container.contentView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -12)
        ])

        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])

        self.confirmationView = container

        container.alpha = 0.0
        UIView.animate(withDuration: 0.15, animations: {
            container.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 1.0, options: .curveEaseInOut, animations: {
                container.alpha = 0.0
            }, completion: { _ in
                container.removeFromSuperview()
            })
        }
    }
}

#Preview {
    ContentView(
        onProductFound: { _, _ in },
        onProductNotFound: { _ in }
    )
}
