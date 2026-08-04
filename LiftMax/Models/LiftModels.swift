import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: ExerciseCategory
    var targetRepRange: ClosedRange<Int>
    var restSeconds: Int
    var sets: [ExerciseSet]

    var lastPerformanceSummary: String {
        guard let heaviestSet = sets.max(by: { $0.weight < $1.weight }) else {
            return "No sets yet"
        }

        return "\(heaviestSet.weight.formattedWeight) lb x \(heaviestSet.reps) reps"
    }

    var estimatedOneRepMax: Double {
        guard let bestSet = sets.max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) }) else {
            return 0
        }

        return bestSet.weight * (1 + (Double(bestSet.reps) / 30))
    }
}

enum ExerciseCategory: String, Codable, CaseIterable, Hashable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case legs = "Legs"
    case arms = "Arms"
    case core = "Core"
}

struct ExerciseSet: Identifiable, Codable, Hashable {
    let id: UUID
    var weight: Double
    var reps: Int
    var isWarmup: Bool
    var completedAt: Date
}

struct WorkoutDay: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var focus: String
    var exercises: [Exercise]
}

extension Double {
    var formattedWeight: String {
        if truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(self))
        }

        return String(format: "%.1f", self)
    }
}
