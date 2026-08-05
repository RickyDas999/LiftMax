import SwiftUI

struct SplitEditorView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddDaySheet = false
    @State private var dayPendingDeletion: WorkoutDay?

    var body: some View {
        NavigationStack {
            List {
                Section("Workout Days") {
                    if appModel.workoutDays.isEmpty {
                        ContentUnavailableView(
                            "No workout days yet",
                            systemImage: "calendar.badge.plus",
                            description: Text("Build your split by adding workout days and then filling them with exercises.")
                        )
                    } else {
                        ForEach(appModel.workoutDays) { day in
                            NavigationLink {
                                WorkoutDayCustomizationView(dayID: day.id)
                                    .environment(appModel)
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(day.title)
                                            .font(.headline)

                                        Text("\(day.focus) • \(day.exercises.count) exercises")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button {
                                        dayPendingDeletion = day
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                            .padding(8)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Delete \(day.title)")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Customize Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Day") {
                        showingAddDaySheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddDaySheet) {
                AddWorkoutDaySheet()
                    .environment(appModel)
            }
            .confirmationDialog(
                "Delete workout day?",
                isPresented: Binding(
                    get: { dayPendingDeletion != nil },
                    set: { if !$0 { dayPendingDeletion = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Workout", role: .destructive) {
                    if let dayPendingDeletion {
                        appModel.deleteWorkoutDay(dayID: dayPendingDeletion.id)
                    }
                    dayPendingDeletion = nil
                }

                Button("Cancel", role: .cancel) {
                    dayPendingDeletion = nil
                }
            } message: {
                if let dayPendingDeletion {
                    Text("This will remove \(dayPendingDeletion.title) and every exercise inside it.")
                }
            }
        }
    }
}

private struct WorkoutDayCustomizationView: View {
    @Environment(AppModel.self) private var appModel

    let dayID: WorkoutDay.ID

    @State private var showingAddExerciseSheet = false
    @State private var editingExercise: Exercise?
    @State private var exercisePendingDeletion: Exercise?

    private var day: WorkoutDay? {
        appModel.workoutDay(withID: dayID)
    }

    var body: some View {
        Group {
            if let day {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.title)
                                .font(.headline)
                            Text(day.focus)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Exercises") {
                        if day.exercises.isEmpty {
                            ContentUnavailableView(
                                "No exercises yet",
                                systemImage: "dumbbell",
                                description: Text("Add the lifts for this workout day here.")
                            )
                        } else {
                            ForEach(day.exercises) { exercise in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.name)
                                            .font(.headline)

                                        Text("\(exercise.category.rawValue) • \(exercise.targetRepRange.displayText) reps • \(exercise.targetWorkingSets) working sets • Rest \(exercise.restSeconds) sec")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button {
                                        editingExercise = exercise
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundStyle(.blue)
                                            .padding(8)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Edit \(exercise.name)")

                                    Button {
                                        exercisePendingDeletion = exercise
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                            .padding(8)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Delete \(exercise.name)")
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .navigationTitle(day.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add Exercise") {
                            showingAddExerciseSheet = true
                        }
                    }
                }
                .sheet(isPresented: $showingAddExerciseSheet) {
                    AddExerciseSheet(dayID: day.id, existingExercise: nil)
                        .environment(appModel)
                }
                .sheet(item: $editingExercise) { exercise in
                    AddExerciseSheet(dayID: day.id, existingExercise: exercise)
                        .environment(appModel)
                }
                .confirmationDialog(
                    "Delete exercise?",
                    isPresented: Binding(
                        get: { exercisePendingDeletion != nil },
                        set: { if !$0 { exercisePendingDeletion = nil } }
                    ),
                    titleVisibility: .visible
                ) {
                    Button("Delete Exercise", role: .destructive) {
                        if let exercisePendingDeletion {
                            appModel.deleteExercise(dayID: day.id, exerciseID: exercisePendingDeletion.id)
                        }
                        exercisePendingDeletion = nil
                    }

                    Button("Cancel", role: .cancel) {
                        exercisePendingDeletion = nil
                    }
                } message: {
                    if let exercisePendingDeletion {
                        Text("This will remove \(exercisePendingDeletion.name) from \(day.title). Logged sets for that exercise will also be removed.")
                    }
                }
            } else {
                ContentUnavailableView("Workout not found", systemImage: "exclamationmark.triangle")
            }
        }
    }
}

private struct AddWorkoutDaySheet: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var focus = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Day") {
                    TextField("Title", text: $title)
                    TextField("Focus", text: $focus)
                }
            }
            .navigationTitle("Add Workout Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        appModel.addWorkoutDay(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            focus: focus.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    SplitEditorView()
        .environment(AppModel())
}
