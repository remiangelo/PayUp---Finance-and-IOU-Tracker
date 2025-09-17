import Foundation
import SwiftUI
import UIKit
import Vision
import Combine

struct Receipt: Identifiable, Codable {
    let id: UUID
    let transactionId: UUID?
    let imageData: Data
    let merchantName: String?
    let totalAmount: Double?
    let date: Date?
    let items: [ReceiptItem]
    let rawText: String?
    let currency: Currency
    let taxAmount: Double?
    let tipAmount: Double?
    let createdAt: Date
    let processedAt: Date?
    let processingStatus: ProcessingStatus

    init(
        id: UUID = UUID(),
        transactionId: UUID? = nil,
        imageData: Data,
        merchantName: String? = nil,
        totalAmount: Double? = nil,
        date: Date? = nil,
        items: [ReceiptItem] = [],
        rawText: String? = nil,
        currency: Currency = .usd,
        taxAmount: Double? = nil,
        tipAmount: Double? = nil,
        processingStatus: ProcessingStatus = .pending
    ) {
        self.id = id
        self.transactionId = transactionId
        self.imageData = imageData
        self.merchantName = merchantName
        self.totalAmount = totalAmount
        self.date = date
        self.items = items
        self.rawText = rawText
        self.currency = currency
        self.taxAmount = taxAmount
        self.tipAmount = tipAmount
        self.createdAt = Date()
        self.processedAt = processingStatus == .completed ? Date() : nil
        self.processingStatus = processingStatus
    }

    var subtotal: Double {
        if let total = totalAmount,
           let tax = taxAmount,
           let tip = tipAmount {
            return total - tax - tip
        }
        return items.reduce(0) { $0 + $1.totalPrice }
    }

    var isProcessed: Bool {
        processingStatus == .completed
    }

    enum ProcessingStatus: String, Codable {
        case pending = "Pending"
        case processing = "Processing"
        case completed = "Completed"
        case failed = "Failed"

        var color: Color {
            switch self {
            case .pending: return .orange
            case .processing: return .blue
            case .completed: return .green
            case .failed: return .red
            }
        }

        var icon: String {
            switch self {
            case .pending: return "clock.fill"
            case .processing: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.triangle.fill"
            }
        }
    }
}

// MARK: - Receipt Item

struct ReceiptItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
    let category: String?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Int = 1,
        unitPrice: Double,
        category: String? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = unitPrice * Double(quantity)
        self.category = category
    }
}

// MARK: - Receipt Scanner

class ReceiptScanner: ObservableObject {
    @Published var isProcessing = false
    @Published var scannedText = ""
    @Published var extractedData: ExtractedReceiptData?

    struct ExtractedReceiptData {
        var merchantName: String?
        var date: Date?
        var items: [ReceiptItem]
        var subtotal: Double?
        var tax: Double?
        var tip: Double?
        var total: Double?
        var rawText: String
    }

    func scanReceipt(from imageData: Data) {
        guard let image = UIImage(data: imageData),
              let cgImage = image.cgImage else {
            return
        }

        isProcessing = true
        scannedText = ""

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                self?.isProcessing = false
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            DispatchQueue.main.async {
                self?.scannedText = recognizedStrings.joined(separator: "\n")
                self?.parseReceiptText(recognizedStrings)
                self?.isProcessing = false
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }

    private func parseReceiptText(_ lines: [String]) {
        var data = ExtractedReceiptData(items: [], rawText: lines.joined(separator: "\n"))

        // Extract merchant name (usually in first few lines)
        if let merchantLine = lines.first(where: { !$0.isEmpty && $0.count > 3 }) {
            data.merchantName = merchantLine
        }

        // Extract date
        for line in lines {
            if let date = extractDate(from: line) {
                data.date = date
                break
            }
        }

        // Extract items and prices
        var items: [ReceiptItem] = []
        for line in lines {
            if let item = extractItem(from: line) {
                items.append(item)
            }
        }
        data.items = items

        // Extract totals
        for line in lines {
            let lowercased = line.lowercased()
            if lowercased.contains("subtotal") {
                data.subtotal = extractAmount(from: line)
            } else if lowercased.contains("tax") {
                data.tax = extractAmount(from: line)
            } else if lowercased.contains("tip") || lowercased.contains("gratuity") {
                data.tip = extractAmount(from: line)
            } else if lowercased.contains("total") && !lowercased.contains("subtotal") {
                data.total = extractAmount(from: line)
            }
        }

        extractedData = data
    }

    private func extractDate(from text: String) -> Date? {
        let dateFormats = [
            "MM/dd/yyyy",
            "MM-dd-yyyy",
            "yyyy-MM-dd",
            "MMM dd, yyyy",
            "dd/MM/yyyy"
        ]

        for format in dateFormats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }

        // Try to find date pattern with regex
        let pattern = #"\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            let dateString = String(text[Range(match.range, in: text)!])
            for format in dateFormats {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
        }

        return nil
    }

    private func extractItem(from text: String) -> ReceiptItem? {
        // Look for pattern: item name followed by price
        let pattern = #"(.+?)\s+\$?(\d+\.?\d{0,2})"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }

        if match.numberOfRanges >= 3 {
            let itemRange = Range(match.range(at: 1), in: text)
            let priceRange = Range(match.range(at: 2), in: text)

            if let itemRange = itemRange,
               let priceRange = priceRange,
               let price = Double(text[priceRange]) {
                let itemName = String(text[itemRange]).trimmingCharacters(in: .whitespaces)
                return ReceiptItem(name: itemName, unitPrice: price)
            }
        }

        return nil
    }

    private func extractAmount(from text: String) -> Double? {
        let pattern = #"\$?(\d+\.?\d{0,2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }

        let range = Range(match.range(at: 1), in: text)
        if let range = range {
            return Double(text[range])
        }

        return nil
    }
}