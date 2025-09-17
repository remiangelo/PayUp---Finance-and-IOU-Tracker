import Foundation
import CoreData
import UIKit
import Combine

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PayUpDataModel")

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data failed to load: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func save() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
        } catch {
            print("Failed to save Core Data context: \(error)")
        }
    }

    // MARK: - User Operations

    func createUser(name: String, email: String? = nil, phoneNumber: String? = nil) -> UserEntity {
        let user = UserEntity(context: viewContext)
        user.id = UUID()
        user.name = name
        user.email = email
        user.phoneNumber = phoneNumber
        user.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        user.createdAt = Date()

        save()
        return user
    }

    func fetchUsers() -> [UserEntity] {
        let request = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch users: \(error)")
            return []
        }
    }

    // MARK: - Category Operations

    func createCategory(name: String, icon: String, color: String) -> CategoryEntity {
        let category = CategoryEntity(context: viewContext)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.color = color

        save()
        return category
    }

    func fetchCategories() -> [CategoryEntity] {
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }

    func setupDefaultCategories() {
        let existingCategories = fetchCategories()
        guard existingCategories.isEmpty else { return }

        let defaultCategories = [
            ("Food & Dining", "fork.knife", "orange"),
            ("Transportation", "car.fill", "blue"),
            ("Shopping", "bag.fill", "purple"),
            ("Entertainment", "tv.fill", "pink"),
            ("Bills & Utilities", "bolt.fill", "yellow"),
            ("Healthcare", "heart.fill", "red"),
            ("Education", "book.fill", "indigo"),
            ("Travel", "airplane", "teal"),
            ("Personal", "person.fill", "green"),
            ("Other", "ellipsis.circle.fill", "gray")
        ]

        for (name, icon, color) in defaultCategories {
            _ = createCategory(name: name, icon: icon, color: color)
        }
    }

    // MARK: - Transaction Operations

    func createTransaction(
        amount: Double,
        description: String,
        category: CategoryEntity?,
        paidBy: UserEntity,
        splitWith: [UserEntity] = [],
        paymentMethod: String = "cash",
        notes: String? = nil,
        tags: [String] = []
    ) -> TransactionEntity {
        let transaction = TransactionEntity(context: viewContext)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.descriptionText = description
        transaction.category = category
        transaction.paidBy = paidBy
        transaction.splitWith = Set(splitWith) as NSSet
        transaction.paymentMethod = paymentMethod
        transaction.notes = notes
        // Core Data handles Transformable automatically for arrays
        if !tags.isEmpty {
            transaction.setValue(tags, forKey: "tags")
        }
        transaction.currency = "USD"
        transaction.createdAt = Date()
        transaction.type = splitWith.isEmpty ? "personal" : "split"

        save()
        return transaction
    }

    func fetchTransactions(for group: GroupEntity? = nil) -> [TransactionEntity] {
        let request = TransactionEntity.fetchRequest()

        if let group = group {
            request.predicate = NSPredicate(format: "group == %@", group)
        }

        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }

    // MARK: - Budget Operations

    func createBudget(
        name: String,
        amount: Double,
        category: CategoryEntity?,
        period: String = "monthly"
    ) -> BudgetEntity {
        let budget = BudgetEntity(context: viewContext)
        budget.id = UUID()
        budget.name = name
        budget.amount = amount
        budget.categoryId = category?.id
        budget.period = period
        budget.createdAt = Date()

        let calendar = Calendar.current
        budget.startDate = calendar.startOfMonth(for: Date())
        budget.endDate = calendar.endOfMonth(for: Date())

        save()
        return budget
    }

    func fetchBudgets() -> [BudgetEntity] {
        let request = BudgetEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch budgets: \(error)")
            return []
        }
    }

    // MARK: - Group Operations

    func createGroup(name: String, type: String = "friends", members: [UserEntity]) -> GroupEntity {
        let group = GroupEntity(context: viewContext)
        group.id = UUID()
        group.name = name
        group.type = type
        group.members = Set(members) as NSSet
        group.isActive = true
        group.createdAt = Date()

        save()
        return group
    }

    func fetchGroups() -> [GroupEntity] {
        let request = GroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch groups: \(error)")
            return []
        }
    }

    // MARK: - Analytics

    func getSpendingByCategory(startDate: Date, endDate: Date) -> [(CategoryEntity, Double)] {
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", startDate as CVarArg, endDate as CVarArg)

        do {
            let transactions = try viewContext.fetch(request)
            var categorySpending: [CategoryEntity: Double] = [:]

            for transaction in transactions {
                if let category = transaction.category {
                    categorySpending[category, default: 0] += transaction.amount
                }
            }

            return categorySpending.sorted { $0.value > $1.value }
        } catch {
            print("Failed to calculate spending by category: \(error)")
            return []
        }
    }

    func getTotalSpending(for period: DateInterval) -> Double {
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", period.start as CVarArg, period.end as CVarArg)

        do {
            let transactions = try viewContext.fetch(request)
            return transactions.reduce(0) { $0 + $1.amount }
        } catch {
            print("Failed to calculate total spending: \(error)")
            return 0
        }
    }
}

// MARK: - Calendar Extensions

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }

    func endOfMonth(for date: Date) -> Date {
        guard let startOfMonth = self.date(from: dateComponents([.year, .month], from: date)),
              let endOfMonth = self.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return date
        }
        return endOfMonth
    }
}