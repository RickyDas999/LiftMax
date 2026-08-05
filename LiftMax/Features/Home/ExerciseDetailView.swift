import SwiftUI

struct ExerciseDetailView: View {
    @Environment(AppModel.self) private var appModel

    let dayID: WorkoutDay.ID
    let exerciseID: Exercise.ID

    @State private var showingAddSetSheet = false

    private var exercise: Exercise? {
        appModel.exercise(dayID: dayID, exerciseID: exerciseID)
    }

    var body: some View {
        Group {
            if let exercise {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(exercise.targetRepRange.displayText) rep target")
                                .font(.headline.weight(.bold))
                            Text("Rest \(exercise.restSeconds) sec • Last \(exercise.lastPerformanceSummary)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Personal best \(exercise.personalBestSummary)")
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.vertical, 6)
                    }

                    Section("Progression Guidance") {
                        progressionCard(for: exercise)
                        momentumCard(for: exercise)
                    }

                    Section("Recent Sets") {
                        if exercise.sets.isEmpty {
                            Text("No sets logged yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(exercise.workingSets) { set in
                                setRow(set)
                            }
                        }
                    }
                }
                .navigationTitle(exercise.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add Set") {
                            showingAddSetSheet = true
                        }
                    }
                }
                .sheet(isPresented: $showingAddSetSheet) {
                    AddSetSheet(
                        exerciseName: exercise.name,
                        recentSet: exercise.recentSet
                    ) { weight, reps, isWarmup in
                        appModel.addSet(
                            dayID: dayID,
                            exerciseID: exerciseID,
                            weight: weight,
                            reps: reps,
                            isWarmup: isWarmup
                        )
                    }
                }
            } else {
                ContentUnavailableView("Exercise not found", systemImage: "dumbbell")
            }
        }
    }

    private func setRow(_ set: ExerciseSet) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(set.weight.formattedWeight) lb x \(set.reps)")
                    .font(.headline)

                Text(set.completedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if set.isWarmup {
                Text("Warm-up")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15), in: Capsule())
            }
        }
        .padding(.vertical, 2)
    }

    private func progressionCard(for exercise: Exercise) -> some View {
        let insight = exercise.progressInsight

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(insight.status.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(statusColor(for: insight.status))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor(for: insight.status).opacity(0.12), in: Capsule())

                Spacer()

                if let suggestedWeight = insight.suggestedWeight {
                    Text("\(suggestedWeight.formattedWeight) lb target")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(insight.headline)
                .font(.headline.weight(.bold))

            Text(insight.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func momentumCard(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Momentum")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(exercise.momentumSummary)
                .font(.subheadline.weight(.medium))
        }
        .padding(.vertical, 4)
    }

    private func statusColor(for status: ProgressStatus) -> Color {
        switch status {
        case .increaseWeight:
            return .green
        case .addReps:
            return .blue
        case .holdWeight:
            return .orange
        case .buildBaseline:
            return .gray
        }
    }
}

private struct AddSetSheet: View {
    @Environment(\.dismiss) private var dismiss

    let exerciseName: String
    let recentSet: ExerciseSet?
    let onSave: (Double, Int, Bool) -> Void

    @State private var weightText = ""
    @State private var repsText = ""
    @State private var isWarmup = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(exerciseName)
                        .font(.headline)

                    if let recentSet {
                        Text("Last working set: \(recentSet.weight.formattedWeight) lb x \(recentSet.reps)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Set Details") {
                    TextField("Weight", text: $weightText)
                        .keyboardType(.decimalPad)

                    TextField("Reps", text: $repsText)
                        .keyboardType(.numberPad)

                    Toggle("Warm-up set", isOn: $isWarmup)
                }
            }
            .navigationTitle("Add Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard let weight = Double(weightText), let reps = Int(repsText) else {
                            return
                        }

                        onSave(weight, reps, isWarmup)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let recentSet {
                    weightText = recentSet.weight.formattedWeight
                    repsText = String(recentSet.reps)
                }
            }
        }
    }

    private var canSave: Bool {
        guard let weight = Double(weightText), let reps = Int(repsText) else {
            return false
        }

        return weight > 0 && reps > 0
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(
            dayID: AppModel().workoutDays[0].id,
            exerciseID: AppModel().workoutDays[0].exercises[0].id
        )
        .environment(AppModel())
    }
}
