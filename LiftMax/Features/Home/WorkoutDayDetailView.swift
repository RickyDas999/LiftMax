import SwiftUI

struct WorkoutDayDetailView: View {
    @Environment(AppModel.self) private var appModel

    let dayID: WorkoutDay.ID

    @State private var editingExercise: Exercise?

    private var day: WorkoutDay? {
        appModel.workoutDay(withID: dayID)
    }

    var body: some View {
        Group {
            if let day {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(day.focus)
                                .font(.headline)

                            Text("\(day.exercises.count) exercises • \(day.totalWorkingSets) working sets logged")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Session Mode") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Use a focused logging flow during training with a current exercise target and quick set entry.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button {
                                appModel.startWorkoutSession(dayID: day.id)
                            } label: {
                                Label("Start Workout", systemImage: "play.fill")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 0.97, green: 0.52, blue: 0.28))
                            .disabled(day.exercises.isEmpty)
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Exercises") {
                        if day.exercises.isEmpty {
                            ContentUnavailableView(
                                "No exercises yet",
                                systemImage: "dumbbell",
                                description: Text("Open Customize Split to add the lifts for this workout day.")
                            )
                        } else {
                            ForEach(day.exercises) { exercise in
                                NavigationLink {
                                    ExerciseDetailView(dayID: day.id, exerciseID: exercise.id)
                                } label: {
                                    exerciseRow(exercise)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(day.title)
                .navigationBarTitleDisplayMode(.inline)
                .brandedNavigationBar()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        BrandedTitle(text: day.title)
                    }
                }
                .fullScreenCover(
                    item: Binding(
                        get: { appModel.activeWorkoutSession },
                        set: { appModel.activeWorkoutSession = $0 }
                    )
                ) { _ in
                    WorkoutSessionView()
                        .environment(appModel)
                }
                .sheet(item: $editingExercise) { exercise in
                    AddExerciseSheet(dayID: day.id, existingExercise: exercise)
                        .environment(appModel)
                }
            } else {
                ContentUnavailableView("Workout not found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(exercise.category.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)

                Text("\(exercise.category.rawValue) • \(exercise.targetRepRange.displayText) reps")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Last \(exercise.lastPerformanceSummary) • Best \(exercise.personalBestSummary)")
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
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        WorkoutDayDetailView(dayID: AppModel().workoutDays[0].id)
            .environment(AppModel())
    }
}
