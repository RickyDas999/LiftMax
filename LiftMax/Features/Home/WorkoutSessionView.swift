import SwiftUI

struct WorkoutSessionView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddSetSheet = false

    private var session: ActiveWorkoutSession? {
        appModel.activeWorkoutSession
    }

    private var day: WorkoutDay? {
        appModel.activeWorkoutDay
    }

    private var currentExercise: Exercise? {
        appModel.activeExercise
    }

    var body: some View {
        NavigationStack {
            Group {
                if let session, let day, let currentExercise {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            sessionHeader(session: session, day: day)
                            currentExerciseCard(exercise: currentExercise, day: day)
                            exerciseQueue(day: day, currentIndex: session.currentExerciseIndex)
                        }
                        .padding(20)
                    }
                    .background(backgroundGradient)
                    .navigationTitle("Workout Session")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("End") {
                                appModel.endWorkoutSession()
                                dismiss()
                            }
                        }
                    }
                    .sheet(isPresented: $showingAddSetSheet) {
                        SessionSetSheet(exercise: currentExercise) { weight, reps, isWarmup in
                            appModel.addSet(
                                dayID: day.id,
                                exerciseID: currentExercise.id,
                                weight: weight,
                                reps: reps,
                                isWarmup: isWarmup
                            )
                        }
                    }
                } else {
                    ContentUnavailableView("No active workout", systemImage: "figure.strengthtraining.traditional")
                }
            }
        }
    }

    private func sessionHeader(session: ActiveWorkoutSession, day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(day.title)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(day.focus)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))

            TimelineView(.periodic(from: session.startedAt, by: 1)) { context in
                HStack(spacing: 12) {
                    sessionMetric(title: "Elapsed", value: elapsedText(from: session.startedAt, to: context.date))
                    sessionMetric(title: "Exercise", value: "\(session.currentExerciseIndex + 1) / \(day.exercises.count)")
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func currentExerciseCard(exercise: Exercise, day: WorkoutDay) -> some View {
        let sessionSets = appModel.sessionWorkingSets(for: exercise.id)
        let isComplete = sessionSets.count >= exercise.targetWorkingSets
        let sessionRepTotal = sessionSets.map(\.reps).reduce(0, +)

        return VStack(alignment: .leading, spacing: 16) {
            Text("Current Exercise")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.62))

            Text(exercise.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("\(exercise.category.rawValue) • \(exercise.targetRepRange.displayText) reps • Rest \(exercise.restSeconds) sec")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.74))

            HStack {
                sessionBadge(title: "Working Sets", value: "\(sessionSets.count) / \(exercise.targetWorkingSets)")
                sessionBadge(title: "Session Reps", value: "\(sessionRepTotal)")
            }

            HStack {
                sessionBadge(title: "Last", value: exercise.lastPerformanceSummary)
                sessionBadge(title: "Best", value: exercise.personalBestSummary)
            }

            Button {
                showingAddSetSheet = true
            } label: {
                Label("Log Set", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(isComplete ? Color.green : Color(red: 0.36, green: 0.81, blue: 0.68))

            if !sessionSets.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Logged This Session")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.62))

                    ForEach(sessionSets) { set in
                        HStack {
                            Text("\(set.weight.formattedWeight) lb x \(set.reps)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Spacer()

                            Text(set.completedAt.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.62))
                        }
                    }
                }
            }

            if isComplete {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Target working sets completed")
                        .fontWeight(.bold)
                }
                .foregroundStyle(Color(red: 0.36, green: 0.90, blue: 0.62))
            } else {
                Text("Select another exercise from the queue whenever the gym setup changes.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func exerciseQueue(day: WorkoutDay, currentIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Exercise Queue")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            ForEach(Array(day.exercises.enumerated()), id: \.element.id) { index, exercise in
                Button {
                    appModel.goToExercise(index: index)
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(index == currentIndex ? Color.white : Color.white.opacity(0.14))
                                .frame(width: 34, height: 34)

                            Text("\(index + 1)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(index == currentIndex ? Color.black.opacity(0.86) : .white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)

                            Text(exercise.lastPerformanceSummary)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.66))
                        }

                        Spacer()

                        if appModel.isExerciseCompleteInSession(exercise.id) {
                            Text("Done")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.black.opacity(0.82))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green, in: Capsule())
                        } else if index == currentIndex {
                            Text("Live")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.black.opacity(0.82))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.99, green: 0.74, blue: 0.31), in: Capsule())
                        }
                    }
                    .padding(16)
                    .background(queueBackground(for: exercise, index: index, currentIndex: currentIndex), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func sessionMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.58))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func sessionBadge(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.58))
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func queueBackground(for exercise: Exercise, index: Int, currentIndex: Int) -> Color {
        if appModel.isExerciseCompleteInSession(exercise.id) {
            return Color.green.opacity(0.22)
        }

        if index == currentIndex {
            return .white.opacity(0.12)
        }

        return .white.opacity(0.06)
    }

    private func elapsedText(from startDate: Date, to currentDate: Date) -> String {
        let elapsed = Int(currentDate.timeIntervalSince(startDate))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.09, blue: 0.14),
                Color(red: 0.12, green: 0.15, blue: 0.24),
                Color(red: 0.18, green: 0.21, blue: 0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct SessionSetSheet: View {
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise
    let onSave: (Double, Int, Bool) -> Void

    @State private var weightText = ""
    @State private var repsText = ""
    @State private var isWarmup = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(exercise.name)
                        .font(.headline)

                    if let recentSet = exercise.recentSet {
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
            .navigationTitle("Log Set")
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
                if let recentSet = exercise.recentSet {
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
    WorkoutSessionView()
        .environment({
            let model = AppModel()
            model.startWorkoutSession(dayID: model.workoutDays[0].id)
            return model
        }())
}
