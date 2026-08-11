import SwiftUI

struct AddExerciseSheet: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    let dayID: WorkoutDay.ID
    let existingExercise: Exercise?
    var onExerciseAdded: ((Exercise.ID) -> Void)? = nil

    @State private var name = ""
    @State private var category = ExerciseCategory.chest
    @State private var minReps = 8
    @State private var maxReps = 12
    @State private var restSeconds = 120
    @State private var targetWorkingSets = 3

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section("Targets") {
                    Stepper("Min reps: \(minReps)", value: $minReps, in: 1...30)
                    Stepper("Max reps: \(max(maxReps, minReps))", value: $maxReps, in: minReps...30)
                    Stepper("Working sets: \(targetWorkingSets)", value: $targetWorkingSets, in: 1...8)
                    Stepper("Rest: \(restSeconds) sec", value: $restSeconds, in: 30...300, step: 15)
                }
            }
            .navigationTitle(existingExercise == nil ? "Add Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let existingExercise {
                            appModel.updateExercise(
                                dayID: dayID,
                                exerciseID: existingExercise.id,
                                name: trimmedName,
                                category: category,
                                targetRepRange: minReps...maxReps,
                                restSeconds: restSeconds,
                                targetWorkingSets: targetWorkingSets
                            )
                        } else {
                            let newExerciseID = appModel.addExercise(
                                dayID: dayID,
                                name: trimmedName,
                                category: category,
                                targetRepRange: minReps...maxReps,
                                restSeconds: restSeconds,
                                targetWorkingSets: targetWorkingSets
                            )
                            if let newExerciseID {
                                onExerciseAdded?(newExerciseID)
                            }
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: minReps) { _, newValue in
                if maxReps < newValue {
                    maxReps = newValue
                }
            }
            .onAppear {
                guard let existingExercise else {
                    return
                }

                name = existingExercise.name
                category = existingExercise.category
                minReps = existingExercise.targetRepRange.lowerBound
                maxReps = existingExercise.targetRepRange.upperBound
                restSeconds = existingExercise.restSeconds
                targetWorkingSets = existingExercise.targetWorkingSets
            }
        }
    }
}
