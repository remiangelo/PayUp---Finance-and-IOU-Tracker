import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPayer: User?
    @State private var selectedBeneficiaries: Set<UUID> = []
    @State private var amount = ""
    @State private var description = ""
    @State private var splitEqually = true
    @State private var showAnimation = false

    var session: Session? {
        sessionManager.currentSession
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WallpaperBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        PayerSection(selectedPayer: $selectedPayer, users: session?.users ?? [])
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: showAnimation)

                        AmountSection(amount: $amount)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: showAnimation)

                        DescriptionSection(description: $description)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: showAnimation)

                        SplitSection(
                            splitEqually: $splitEqually,
                            selectedBeneficiaries: $selectedBeneficiaries,
                            users: session?.users ?? []
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: showAnimation)

                        if let amountDouble = Double(amount),
                           amountDouble > 0,
                           !selectedBeneficiaries.isEmpty {
                            SummarySection(amount: amountDouble, beneficiaryCount: selectedBeneficiaries.count)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: showAnimation)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.theme.sparkOrange)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if let payer = selectedPayer,
                           let amountDouble = Double(amount) {
                            sessionManager.addTransaction(
                                payerId: payer.id,
                                beneficiaryIds: Array(selectedBeneficiaries),
                                amount: amountDouble,
                                description: description
                            )
                            dismiss()
                        }
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.theme.brightCyan)
                    .disabled(selectedPayer == nil ||
                             amount.isEmpty ||
                             selectedBeneficiaries.isEmpty ||
                             description.isEmpty)
                }
            }
        }
        .onAppear {
            if splitEqually {
                selectedBeneficiaries = Set(session?.users.map { $0.id } ?? [])
            }
            showAnimation = true
        }
    }
}

struct PayerSection: View {
    @Binding var selectedPayer: User?
    let users: [User]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Who Paid?", systemImage: "person.fill")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.electricBlue, Color.theme.brightCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(users) { user in
                        UserChip(
                            user: user,
                            isSelected: selectedPayer?.id == user.id,
                            action: { selectedPayer = user }
                        )
                    }
                }
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
    }
}

struct AmountSection: View {
    @Binding var amount: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Amount", systemImage: "dollarsign.circle.fill")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.electricBlue, Color.theme.brightCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            HStack {
                Text("$")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.theme.electricBlue)

                TextField("0.00", text: $amount, prompt: Text("0.00").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .foregroundStyle(Color.theme.pureWhite)
                    .tint(Color.theme.brightCyan)
                    .accentColor(Color.theme.brightCyan)
            }
            .padding()
            .background(Color.theme.darkNavy.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
    }
}

struct DescriptionSection: View {
    @Binding var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.electricBlue, Color.theme.brightCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            TextField("What was this for?", text: $description, prompt: Text("What was this for?").foregroundColor(Color.theme.pureWhite.opacity(0.5)))
                .font(.system(size: 18, design: .rounded))
                .padding()
                .readableGlassCard(cornerRadius: 12)
                .foregroundStyle(Color.theme.pureWhite)
                .tint(Color.theme.brightCyan)
                .accentColor(Color.theme.brightCyan)
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
    }
}

struct SplitSection: View {
    @Binding var splitEqually: Bool
    @Binding var selectedBeneficiaries: Set<UUID>
    let users: [User]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("Split Between", systemImage: "person.2.fill")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.electricBlue, Color.theme.brightCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Spacer()

                Toggle("", isOn: $splitEqually)
                    .labelsHidden()
                    .tint(Color.theme.brightCyan)
            }

            if splitEqually {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(users) { user in
                        BeneficiaryChip(
                            user: user,
                            isSelected: selectedBeneficiaries.contains(user.id),
                            action: {
                                if selectedBeneficiaries.contains(user.id) {
                                    selectedBeneficiaries.remove(user.id)
                                } else {
                                    selectedBeneficiaries.insert(user.id)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
    }
}

struct SummarySection: View {
    let amount: Double
    let beneficiaryCount: Int

    var splitAmount: Double {
        amount / Double(beneficiaryCount)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Each person owes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("$\(String(format: "%.2f", splitAmount))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color.theme.darkNavy.opacity(0.3),
                    Color.theme.brightCyan.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.theme.brightCyan.opacity(0.3), lineWidth: 1)
        )
    }
}

struct UserChip: View {
    let user: User
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 20))
                Text(user.name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? LinearGradient(
                        colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isSelected ? Color.theme.electricBlue.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? Color.theme.electricBlue.opacity(0.3) : Color.clear,
                radius: 5
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BeneficiaryChip: View {
    let user: User
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [Color.theme.brightCyan, Color.theme.electricBlue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                : LinearGradient(
                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "person.circle")
                        .font(.system(size: 30))
                        .foregroundColor(isSelected ? .white : .gray)
                }

                Text(user.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(SessionManager())
}