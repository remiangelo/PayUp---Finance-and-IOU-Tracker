import SwiftUI
import VisionKit
import Vision
import PhotosUI

struct ReceiptScannerView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss

    @State private var scannedImage: UIImage?
    @State private var extractedData = ExtractedReceiptData()
    @State private var isProcessing = false
    @State private var showingImagePicker = false
    @State private var showingScanner = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid glass background
                LiquidGlassBackground()

                if let scannedImage = scannedImage {
                    // Show extracted data
                    ExtractedDataView(
                        image: scannedImage,
                        data: $extractedData,
                        onSave: saveTransaction,
                        onRescan: resetScanner
                    )
                } else {
                    // Scanner options
                    ScannerOptionsView(
                        onCameraScan: {
                            if checkScanLimit() {
                                showingScanner = true
                            }
                        },
                        onPhotoSelect: {
                            if checkScanLimit() {
                                showingImagePicker = true
                            }
                        },
                        selectedItem: $selectedPhotoItem
                    )
                }

                if isProcessing {
                    ProcessingOverlay()
                }
            }
            .navigationTitle("Receipt Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(LiquidGlassUI.Colors.neonCyan)
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView { image in
                    scannedImage = image
                    processImage(image)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        scannedImage = image
                        processImage(image)
                    }
                }
            }
            .alert("Scan Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func checkScanLimit() -> Bool {
        if !subscriptionManager.checkLimit(for: .receiptScanning) {
            subscriptionManager.showPaywall = true
            return false
        }
        return true
    }

    private func processImage(_ image: UIImage) {
        isProcessing = true

        Task {
            do {
                let data = try await performOCR(on: image)
                await MainActor.run {
                    extractedData = data
                    isProcessing = false
                    subscriptionManager.incrementUsage(for: .receiptScanning)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to process receipt: \(error.localizedDescription)"
                    showingError = true
                    isProcessing = false
                }
            }
        }
    }

    private func performOCR(on image: UIImage) async throws -> ExtractedReceiptData {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let observations = request.results else {
            throw OCRError.noTextFound
        }

        // Extract text from observations
        var extractedText: [String] = []
        for observation in observations {
            if let topCandidate = observation.topCandidates(1).first {
                extractedText.append(topCandidate.string)
            }
        }

        // Parse extracted text
        return parseReceiptText(extractedText)
    }

    private func parseReceiptText(_ lines: [String]) -> ExtractedReceiptData {
        var data = ExtractedReceiptData()

        // Find merchant name (usually at the top)
        if let firstLine = lines.first {
            data.merchantName = firstLine
        }

        // Find total amount (look for patterns like "TOTAL", "Total:", etc.)
        for line in lines {
            if line.lowercased().contains("total") {
                if let amount = extractAmount(from: line) {
                    data.totalAmount = amount
                    break
                }
            }
        }

        // Find date
        for line in lines {
            if let date = extractDate(from: line) {
                data.date = date
                break
            }
        }

        // Extract items
        data.items = extractItems(from: lines)

        // Try to categorize based on merchant name
        data.suggestedCategory = categorizeReceipt(merchantName: data.merchantName)

        return data
    }

    private func extractAmount(from text: String) -> Double? {
        let pattern = #"\$?(\d+\.?\d*)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range(at: 1), in: text) {
                let amountString = String(text[range])
                return Double(amountString)
            }
        }
        return nil
    }

    private func extractDate(from text: String) -> Date? {
        let dateFormats = [
            "MM/dd/yyyy",
            "MM-dd-yyyy",
            "dd/MM/yyyy",
            "yyyy-MM-dd"
        ]

        let formatter = DateFormatter()
        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }

    private func extractItems(from lines: [String]) -> [ScannedReceiptItem] {
        var items: [ScannedReceiptItem] = []

        for line in lines {
            // Look for lines with prices
            if let amount = extractAmount(from: line) {
                let name = line.replacingOccurrences(of: #"\$?\d+\.?\d*"#, with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
                if !name.isEmpty && !name.lowercased().contains("total") && !name.lowercased().contains("tax") {
                    items.append(ScannedReceiptItem(name: name, amount: amount))
                }
            }
        }

        return items
    }

    private func categorizeReceipt(merchantName: String) -> String {
        let merchant = merchantName.lowercased()

        if merchant.contains("restaurant") || merchant.contains("cafe") || merchant.contains("pizza") || merchant.contains("burger") {
            return "Food & Dining"
        } else if merchant.contains("uber") || merchant.contains("lyft") || merchant.contains("taxi") {
            return "Transportation"
        } else if merchant.contains("hotel") || merchant.contains("airbnb") {
            return "Accommodation"
        } else if merchant.contains("bar") || merchant.contains("pub") || merchant.contains("club") {
            return "Entertainment"
        } else if merchant.contains("market") || merchant.contains("grocery") || merchant.contains("store") {
            return "Groceries"
        }

        return "General"
    }

    private func saveTransaction() {
        guard let currentUser = sessionManager.currentUser else { return }

        let beneficiaries = sessionManager.currentSession?.users.map { $0.id } ?? []

        sessionManager.addTransaction(
            payerId: currentUser.id,
            beneficiaryIds: beneficiaries,
            amount: extractedData.totalAmount,
            description: extractedData.description.isEmpty ? extractedData.merchantName : extractedData.description
        )

        dismiss()
    }

    private func resetScanner() {
        scannedImage = nil
        extractedData = ExtractedReceiptData()
    }
}

// MARK: - Scanner Options
struct ScannerOptionsView: View {
    let onCameraScan: () -> Void
    let onPhotoSelect: () -> Void
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: LiquidGlassUI.Spacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            LiquidGlassUI.Colors.neonCyan,
                            LiquidGlassUI.Colors.neonBlue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: LiquidGlassUI.Colors.neonCyan.opacity(0.5), radius: 20)

            VStack(spacing: LiquidGlassUI.Spacing.sm) {
                Text("Scan Receipt")
                    .font(LiquidGlassUI.Typography.title)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                Text("Take a photo or select from gallery")
                    .font(LiquidGlassUI.Typography.body)
                    .foregroundColor(LiquidGlassUI.Colors.textSecondary)
            }

            Spacer()

            // Options
            VStack(spacing: LiquidGlassUI.Spacing.md) {
                LiquidButton("Scan with Camera", icon: "camera.fill") {
                    onCameraScan()
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    PremiumGlassCard {
                        HStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20))
                                .foregroundColor(LiquidGlassUI.Colors.neonBlue)

                            Text("Choose from Gallery")
                                .font(LiquidGlassUI.Typography.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(LiquidGlassUI.Colors.textTertiary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

// MARK: - Extracted Data View
struct ExtractedDataView: View {
    let image: UIImage
    @Binding var data: ExtractedReceiptData
    let onSave: () -> Void
    let onRescan: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: LiquidGlassUI.Spacing.lg) {
                // Receipt Image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .padding()

                // Extracted Data Form
                PremiumGlassCard {
                    VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.md) {
                        Text("Extracted Information")
                            .font(LiquidGlassUI.Typography.headline)
                            .foregroundColor(LiquidGlassUI.Colors.textPrimary)

                        // Merchant
                        VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.xs) {
                            Text("Merchant")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textTertiary)

                            GlassTextField(placeholder: "Merchant name", text: $data.merchantName)
                        }

                        // Amount
                        VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.xs) {
                            Text("Total Amount")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textTertiary)

                            HStack {
                                Text("$")
                                    .font(LiquidGlassUI.Typography.headline)
                                    .foregroundColor(LiquidGlassUI.Colors.neonCyan)

                                TextField("0.00", value: $data.totalAmount, format: .number.precision(.fractionLength(2)))
                                    .font(LiquidGlassUI.Typography.headline)
                                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)
                                    .keyboardType(.decimalPad)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                        }

                        // Description
                        VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.xs) {
                            Text("Description")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textTertiary)

                            GlassTextField(placeholder: "Add description", text: $data.description)
                        }

                        // Category
                        VStack(alignment: .leading, spacing: LiquidGlassUI.Spacing.xs) {
                            Text("Category")
                                .font(LiquidGlassUI.Typography.caption)
                                .foregroundColor(LiquidGlassUI.Colors.textTertiary)

                            Text(data.suggestedCategory)
                                .font(LiquidGlassUI.Typography.body)
                                .foregroundColor(LiquidGlassUI.Colors.neonBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(LiquidGlassUI.Colors.neonBlue.opacity(0.2))
                                )
                        }
                    }
                }
                .padding(.horizontal)

                // Actions
                HStack(spacing: LiquidGlassUI.Spacing.md) {
                    Button("Rescan") {
                        onRescan()
                    }
                    .font(LiquidGlassUI.Typography.callout)
                    .foregroundColor(LiquidGlassUI.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )

                    LiquidButton("Save Transaction", style: .primary) {
                        onSave()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

// MARK: - Processing Overlay
struct ProcessingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: LiquidGlassUI.Spacing.lg) {
                LiquidLoader()

                Text("Processing Receipt...")
                    .font(LiquidGlassUI.Typography.headline)
                    .foregroundColor(LiquidGlassUI.Colors.textPrimary)
            }
            .padding(LiquidGlassUI.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Document Scanner
struct DocumentScannerView: UIViewControllerRepresentable {
    let completion: (UIImage) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let completion: (UIImage) -> Void

        init(completion: @escaping (UIImage) -> Void) {
            self.completion = completion
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true)
                return
            }

            let image = scan.imageOfPage(at: 0)
            completion(image)
            controller.dismiss(animated: true)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Data Models
struct ExtractedReceiptData {
    var merchantName: String = ""
    var totalAmount: Double = 0.0
    var date: Date = Date()
    var description: String = ""
    var suggestedCategory: String = "General"
    var items: [ScannedReceiptItem] = []
}

struct ScannedReceiptItem {
    let name: String
    let amount: Double
}

enum OCRError: Error {
    case invalidImage
    case noTextFound
    case parsingFailed
}

#Preview {
    ReceiptScannerView()
        .environmentObject(SessionManager())
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}