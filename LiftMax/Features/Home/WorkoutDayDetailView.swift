import SwiftUI

struct WorkoutDayDetailView: View {
    @Environment(AppModel.self) private var appModel

    let dayID: WorkoutDay.ID

    private var day: WorkoutDay? {
        appModel.workoutDay(withID: dayID)
    }

    var body: some View {
        Group {
            if let day {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        summaryCard(for: day)

                        if day.exercises.isEmpty {
                            emptyState
                        } else {
                            ForEach(day.exercises) { exercise in
                                NavigationLink {
                                    ExerciseDetailView(dayID: day.id, exerciseID: exercise.id)
                                } label: {
                                    exerciseRow(exercise)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
                .background(backgroundGradient)
                .navigationTitle(day.title)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Workout not found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private func summaryCard(for day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(day.focus)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("\(day.exercises.count) exercises • \(day.totalWorkingSets) working sets logged")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.76))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("\(exercise.category.rawValue) • \(exercise.targetRepRange.displayText) reps")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }

            HStack {
                metricPill(title: "Last", value: exercise.lastPerformanceSummary)
                metricPill(title: "Best", value: exercise.personalBestSummary)
            }
        }
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func metricPill(title: String, value: String) -> some View {
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

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("No exercises yet")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text("Open Customize Split to add the lifts for this workout day.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        WorkoutDayDetailView(dayID: AppModel().workoutDays[0].id)
            .environment(AppModel())
    }
}
