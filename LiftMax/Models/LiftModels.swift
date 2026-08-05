import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: ExerciseCategory
    var targetRepRange: ClosedRange<Int>
    var restSeconds: Int
    var targetWorkingSets: Int
    var sets: [ExerciseSet]

    var lastPerformanceSummary: String {
        guard let mostRecentSet = sets.sorted(by: { $0.completedAt > $1.completedAt }).first else {
            return "No sets yet"
        }

        return "\(mostRecentSet.weight.formattedWeight) lb x \(mostRecentSet.reps) reps"
    }

    var personalBestSummary: String {
        guard let heaviestSet = sets.max(by: { ($0.weight, $0.reps) < ($1.weight, $1.reps) }) else {
            return "No PR yet"
        }

        return "\(heaviestSet.weight.formattedWeight) lb x \(heaviestSet.reps)"
    }

    var estimatedOneRepMax: Double {
        guard let bestSet = sets.max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) }) else {
            return 0
        }

        return bestSet.weight * (1 + (Double(bestSet.reps) / 30))
    }

    var workingSets: [ExerciseSet] {
        sets
            .filter { !$0.isWarmup }
            .sorted(by: { $0.completedAt > $1.completedAt })
    }

    var recentSet: ExerciseSet? {
        workingSets.first
    }

    var previousWorkingSet: ExerciseSet? {
        guard workingSets.count > 1 else {
            return nil
        }

        return workingSets[1]
    }

    var progressInsight: ProgressInsight {
        guard let recentSet else {
            return ProgressInsight(
                status: .buildBaseline,
                headline: "Log your first working set",
                detail: "You need one clean baseline set before LiftMaxx can suggest overload.",
                suggestedWeight: nil
            )
        }

        if recentSet.reps >= targetRepRange.upperBound {
            return ProgressInsight(
                status: .increaseWeight,
                headline: "Increase the load next session",
                detail: "You hit the top of your rep range. Add weight and work back through the range.",
                suggestedWeight: nextWeight(from: recentSet.weight)
            )
        }

        if recentSet.reps >= targetRepRange.lowerBound {
            return ProgressInsight(
                status: .addReps,
                headline: "Keep the weight and chase more reps",
                detail: "You are inside the target range. Beat this set by 1-2 reps before adding load.",
                suggestedWeight: recentSet.weight
            )
        }

        return ProgressInsight(
            status: .holdWeight,
            headline: "Hold the weight steady",
            detail: "You are below the rep floor. Own this load before trying to progress it.",
            suggestedWeight: recentSet.weight
        )
    }

    var momentumSummary: String {
        guard let recentSet, let previousWorkingSet else {
            return "Need two logged working sets to measure trend."
        }

        if recentSet.weight > previousWorkingSet.weight {
            let weightIncrease = (recentSet.weight - previousWorkingSet.weight).formattedWeight
            return "Up \(weightIncrease) lb from the prior working set."
        }

        if recentSet.reps > previousWorkingSet.reps {
            return "Up \(recentSet.reps - previousWorkingSet.reps) reps at the same load."
        }

        if recentSet.reps == previousWorkingSet.reps && recentSet.weight == previousWorkingSet.weight {
            return "Matched the previous working set. Next goal: one more rep."
        }

        return "Recent set dipped. Recover and beat it next session."
    }

    private func nextWeight(from currentWeight: Double) -> Double {
        if currentWeight < 25 {
            return currentWeight + 2.5
        }

        return currentWeight + 5
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case targetRepRange
        case restSeconds
        case targetWorkingSets
        case sets
    }

    init(
        id: UUID,
        name: String,
        category: ExerciseCategory,
        targetRepRange: ClosedRange<Int>,
        restSeconds: Int,
        targetWorkingSets: Int,
        sets: [ExerciseSet]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.targetRepRange = targetRepRange
        self.restSeconds = restSeconds
        self.targetWorkingSets = targetWorkingSets
        self.sets = sets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(ExerciseCategory.self, forKey: .category)
        targetRepRange = try container.decode(ClosedRange<Int>.self, forKey: .targetRepRange)
        restSeconds = try container.decode(Int.self, forKey: .restSeconds)
        targetWorkingSets = try container.decodeIfPresent(Int.self, forKey: .targetWorkingSets) ?? 3
        sets = try container.decode([ExerciseSet].self, forKey: .sets)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(targetRepRange, forKey: .targetRepRange)
        try container.encode(restSeconds, forKey: .restSeconds)
        try container.encode(targetWorkingSets, forKey: .targetWorkingSets)
        try container.encode(sets, forKey: .sets)
    }
}

struct ProgressInsight: Hashable {
    let status: ProgressStatus
    let headline: String
    let detail: String
    let suggestedWeight: Double?
}

enum ProgressStatus: String, Hashable {
    case increaseWeight
    case addReps
    case holdWeight
    case buildBaseline

    var title: String {
        switch self {
        case .increaseWeight:
            return "Add Weight"
        case .addReps:
            return "Add Reps"
        case .holdWeight:
            return "Hold Steady"
        case .buildBaseline:
            return "Build Baseline"
        }
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

    var totalWorkingSets: Int {
        exercises.flatMap(\.workingSets).count
    }
}

struct ActiveWorkoutSession: Identifiable, Hashable {
    let id: UUID
    let dayID: WorkoutDay.ID
    let startedAt: Date
    var currentExerciseIndex: Int
}

extension ClosedRange<Int> where Bound == Int {
    var displayText: String {
        "\(lowerBound)-\(upperBound)"
    }
}

extension Double {
    var formattedWeight: String {
        if truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(self))
        }

        return String(format: "%.1f", self)
    }
}
