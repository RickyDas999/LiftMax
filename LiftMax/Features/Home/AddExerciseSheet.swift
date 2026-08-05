import SwiftUI

struct AddExerciseSheet: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    let dayID: WorkoutDay.ID

    @State private var name = ""
    @State private var category = ExerciseCategory.chest
    @State private var minReps = 8
    @State private var maxReps = 12
    @State private var restSeconds = 120

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
                    Stepper("Rest: \(restSeconds) sec", value: $restSeconds, in: 30...300, step: 15)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        appModel.addExercise(
                            dayID: dayID,
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            category: category,
                            targetRepRange: minReps...maxReps,
                            restSeconds: restSeconds
                        )
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
        }
    }
}
