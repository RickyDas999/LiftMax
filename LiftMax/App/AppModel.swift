import Foundation
import Observation

@Observable
final class AppModel {
    var workoutDays: [WorkoutDay]
    var saveErrorMessage: String?

    @ObservationIgnored private let storageURL: URL

    init(workoutDays: [WorkoutDay] = SampleData.workoutDays) {
        self.storageURL = Self.makeStorageURL()
        self.workoutDays = workoutDays
        load()
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

    func workoutDay(withID id: WorkoutDay.ID) -> WorkoutDay? {
        workoutDays.first(where: { $0.id == id })
    }

    func exercise(dayID: WorkoutDay.ID, exerciseID: Exercise.ID) -> Exercise? {
        workoutDay(withID: dayID)?.exercises.first(where: { $0.id == exerciseID })
    }

    func addSet(
        dayID: WorkoutDay.ID,
        exerciseID: Exercise.ID,
        weight: Double,
        reps: Int,
        isWarmup: Bool
    ) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.id == dayID }) else {
            return
        }

        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseID }) else {
            return
        }

        let newSet = ExerciseSet(
            id: UUID(),
            weight: weight,
            reps: reps,
            isWarmup: isWarmup,
            completedAt: .now
        )

        workoutDays[dayIndex].exercises[exerciseIndex].sets.append(newSet)
        save()
    }

    func addWorkoutDay(title: String, focus: String) {
        let newDay = WorkoutDay(
            id: UUID(),
            title: title,
            focus: focus,
            exercises: []
        )

        workoutDays.append(newDay)
        save()
    }

    func deleteWorkoutDay(dayID: WorkoutDay.ID) {
        workoutDays.removeAll(where: { $0.id == dayID })
        save()
    }

    func addExercise(
        dayID: WorkoutDay.ID,
        name: String,
        category: ExerciseCategory,
        targetRepRange: ClosedRange<Int>,
        restSeconds: Int
    ) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.id == dayID }) else {
            return
        }

        let newExercise = Exercise(
            id: UUID(),
            name: name,
            category: category,
            targetRepRange: targetRepRange,
            restSeconds: restSeconds,
            sets: []
        )

        workoutDays[dayIndex].exercises.append(newExercise)
        save()
    }

    func deleteExercise(dayID: WorkoutDay.ID, exerciseID: Exercise.ID) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.id == dayID }) else {
            return
        }

        workoutDays[dayIndex].exercises.removeAll(where: { $0.id == exerciseID })
        save()
    }

    func updateSet(
        dayID: WorkoutDay.ID,
        exerciseID: Exercise.ID,
        setID: ExerciseSet.ID,
        weight: Double,
        reps: Int,
        isWarmup: Bool
    ) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.id == dayID }) else {
            return
        }

        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseID }) else {
            return
        }

        guard let setIndex = workoutDays[dayIndex].exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setID }) else {
            return
        }

        workoutDays[dayIndex].exercises[exerciseIndex].sets[setIndex].weight = weight
        workoutDays[dayIndex].exercises[exerciseIndex].sets[setIndex].reps = reps
        workoutDays[dayIndex].exercises[exerciseIndex].sets[setIndex].isWarmup = isWarmup
        save()
    }

    func deleteSet(
        dayID: WorkoutDay.ID,
        exerciseID: Exercise.ID,
        setID: ExerciseSet.ID
    ) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.id == dayID }) else {
            return
        }

        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseID }) else {
            return
        }

        workoutDays[dayIndex].exercises[exerciseIndex].sets.removeAll(where: { $0.id == setID })
        save()
    }

    private func load() {
        do {
            let data = try Data(contentsOf: storageURL)
            workoutDays = try JSONDecoder().decode([WorkoutDay].self, from: data)
        } catch {
            if (error as NSError).code != NSFileReadNoSuchFileError {
                saveErrorMessage = "Could not load saved workouts."
            }

            save()
        }
    }

    private func save() {
        do {
            let directoryURL = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            let data = try JSONEncoder().encode(workoutDays)
            try data.write(to: storageURL, options: .atomic)
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "Could not save workouts."
        }
    }

    private static func makeStorageURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory

        return baseURL
            .appendingPathComponent("LiftMaxx", isDirectory: true)
            .appendingPathComponent("workout-days.json")
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
