import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroCard
                    statsGrid
                    workoutDaysSection
                    prsSection
                }
                .padding(24)
            }
            .background(backgroundGradient)
            .navigationTitle("LiftMax")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Progressive overload, minus the messy notes.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Keep each workout day, working set, and rep target in one place so your next session has a clear benchmark.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.84))

            HStack(spacing: 12) {
                pill(text: "iPhone-first")
                pill(text: "Fast logging")
                pill(text: "PR aware")
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 14) {
            metricCard(title: "Workout Days", value: "\(appModel.workoutDays.count)", tint: Color(red: 0.36, green: 0.81, blue: 0.68))
            metricCard(title: "Working Sets", value: "\(appModel.totalWorkingSets)", tint: Color(red: 0.96, green: 0.73, blue: 0.35))
            metricCard(title: "Avg e1RM", value: "\(appModel.averageOneRepMax.formattedWeight) lb", tint: Color(red: 0.89, green: 0.45, blue: 0.44))
            metricCard(title: "Top Movers", value: "\(appModel.recentPRs.count)", tint: Color(red: 0.43, green: 0.58, blue: 0.95))
        }
    }

    private var workoutDaysSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Workout Split")

            ForEach(appModel.workoutDays) { day in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.title)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)

                            Text(day.focus)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Spacer()

                        Text("\(day.exercises.count) lifts")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.10), in: Capsule())
                    }

                    ForEach(day.exercises.prefix(3)) { exercise in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)

                                Text("\(exercise.targetRepRange.lowerBound)-\(exercise.targetRepRange.upperBound) reps target")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.65))
                            }

                            Spacer()

                            Text(exercise.lastPerformanceSummary)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.88))
                        }
                    }
                }
                .padding(18)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
    }

    private var prsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Best Current Estimates")

            ForEach(appModel.recentPRs) { exercise in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(exercise.category.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.65))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(exercise.estimatedOneRepMax.formattedWeight) lb")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)

                        Text(exercise.lastPerformanceSummary)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }
                .padding(18)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
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

    private func metricCard(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Circle()
                .fill(tint)
                .frame(width: 12, height: 12)

            Spacer(minLength: 0)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.68))
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(.white)
    }

    private func pill(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.10), in: Capsule())
    }
}

#Preview {
    HomeView()
        .environment(AppModel())
}
