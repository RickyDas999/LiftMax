import Foundation
import Observation

@Observable
final class AppModel {
    var workoutDays: [WorkoutDay]

    init(workoutDays: [WorkoutDay] = SampleData.workoutDays) {
        self.workoutDays = workoutDays
    }

    var totalWorkingSets: Int {
        workoutDays
            .flatMap(\.exercises)
            .flatMap(\.sets)
            .filter { !$0.isWarmup }
            .count
    }

    var averageOneRepMax: Double {
        let maxes = workoutDays
            .flatMap(\.exercises)
            .map(\.estimatedOneRepMax)
            .filter { $0 > 0 }

        guard !maxes.isEmpty else {
            return 0
        }

        return maxes.reduce(0, +) / Double(maxes.count)
    }

    var recentPRs: [Exercise] {
        workoutDays
            .flatMap(\.exercises)
            .sorted { $0.estimatedOneRepMax > $1.estimatedOneRepMax }
            .prefix(3)
            .map { $0 }
    }
}

enum SampleData {
    static let workoutDays: [WorkoutDay] = [
        WorkoutDay(
            id: UUID(),
            title: "Push A",
            focus: "Upper chest + shoulders",
            exercises: [
                Exercise(
                    id: UUID(),
                    name: "Dumbbell Incline Press",
                    category: .chest,
                    targetRepRange: 5...8,
                    restSeconds: 150,
                    sets: [
                        ExerciseSet(id: UUID(), weight: 70, reps: 8, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 7)),
                        ExerciseSet(id: UUID(), weight: 75, reps: 7, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 3)),
                        ExerciseSet(id: UUID(), weight: 75, reps: 8, isWarmup: false, completedAt: .now.addingTimeInterval(-86400))
                    ]
                ),
                Exercise(
                    id: UUID(),
                    name: "Seated Dumbbell Shoulder Press",
                    category: .shoulders,
                    targetRepRange: 6...10,
                    restSeconds: 120,
                    sets: [
                        ExerciseSet(id: UUID(), weight: 50, reps: 10, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 5)),
                        ExerciseSet(id: UUID(), weight: 55, reps: 8, isWarmup: false, completedAt: .now.addingTimeInterval(-86400))
                    ]
                ),
                Exercise(
                    id: UUID(),
                    name: "Cable Lateral Raise",
                    category: .shoulders,
                    targetRepRange: 12...15,
                    restSeconds: 75,
                    sets: [
                        ExerciseSet(id: UUID(), weight: 20, reps: 15, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 2))
                    ]
                )
            ]
        ),
        WorkoutDay(
            id: UUID(),
            title: "Pull A",
            focus: "Lats + upper back",
            exercises: [
                Exercise(
                    id: UUID(),
                    name: "Weighted Pull-Up",
                    category: .back,
                    targetRepRange: 5...8,
                    restSeconds: 150,
                    sets: [
                        ExerciseSet(id: UUID(), weight: 25, reps: 8, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 4)),
                        ExerciseSet(id: UUID(), weight: 35, reps: 6, isWarmup: false, completedAt: .now.addingTimeInterval(-86400))
                    ]
                ),
                Exercise(
                    id: UUID(),
                    name: "Chest-Supported Row",
                    category: .back,
                    targetRepRange: 8...12,
                    restSeconds: 120,
                    sets: [
                        ExerciseSet(id: UUID(), weight: 80, reps: 12, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 6)),
                        ExerciseSet(id: UUID(), weight: 90, reps: 10, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 2))
                    ]
                )
            ]
        ),
        WorkoutDay(
            id: UUID(),
            title: "Legs A",
            focus: "Quads + posterior chain",
            exercises: [
                Exercise(
                    id: UUID(),
                    name: "Hack Squat",
                    category: .legs,
                    targetRepRange: 8...10,
                    restSeconds: 180,
                    sets: [
                        ExerciseSet(id: UUID(), weight: 225, reps: 10, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 4)),
                        ExerciseSet(id: UUID(), weight: 245, reps: 8, isWarmup: false, completedAt: .now.addingTimeInterval(-86400))
                    ]
                ),
                Exercise(
                    id: UUID(),
                    name: "Romanian Deadlift",
                    category: .legs,
                    targetRepRange: 6...8,
                    restSeconds: 180,
                    sets: [
                        ExerciseSet(id: UUID(), weight: 225, reps: 8, isWarmup: false, completedAt: .now.addingTimeInterval(-86400 * 5)),
                        ExerciseSet(id: UUID(), weight: 235, reps: 8, isWarmup: false, completedAt: .now.addingTimeInterval(-86400))
                    ]
                )
            ]
        )
    ]
}
