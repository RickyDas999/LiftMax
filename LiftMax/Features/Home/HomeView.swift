import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showingSplitEditor = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    heroBanner
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if let saveErrorMessage = appModel.saveErrorMessage {
                    Section {
                        Label(saveErrorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    statsGrid
                        .padding(.vertical, 6)
                } header: {
                    sectionHeader("Overview")
                }

                Section {
                    if appModel.workoutDays.isEmpty {
                        ContentUnavailableView(
                            "No workout days yet",
                            systemImage: "calendar.badge.plus",
                            description: Text("Open Customize Split to build your training week.")
                        )
                    } else {
                        ForEach(appModel.workoutDays) { day in
                            NavigationLink {
                                WorkoutDayDetailView(dayID: day.id)
                            } label: {
                                dayRow(day)
                            }
                        }
                    }
                } header: {
                    sectionHeader("Workout Split")
                }

                if !appModel.recentPRs.isEmpty {
                    Section {
                        ForEach(appModel.recentPRs) { exercise in
                            prRow(exercise)
                        }
                    } header: {
                        sectionHeader("Best Current Estimates")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("LiftMaxx")
            .navigationBarTitleDisplayMode(.inline)
            .brandedNavigationBar()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    BrandedTitle(text: "LiftMaxx")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSplitEditor = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Customize split")
                }
            }
            .sheet(isPresented: $showingSplitEditor) {
                SplitEditorView()
                    .environment(appModel)
            }
        }
    }

    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LIFTMAXX")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(.white)

            Text("Progressive overload, minus the messy notes.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.58, blue: 0.27),
                    Color(red: 0.92, green: 0.30, blue: 0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(.primary)
            .textCase(nil)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
            statTile(value: "\(appModel.workoutDays.count)", label: "Workout Days", tint: Color(red: 0.36, green: 0.81, blue: 0.68))
            statTile(value: "\(appModel.totalWorkingSets)", label: "Working Sets", tint: Color(red: 0.96, green: 0.73, blue: 0.35))
            statTile(value: "\(appModel.averageOneRepMax.formattedWeight) lb", label: "Avg e1RM", tint: Color(red: 0.89, green: 0.45, blue: 0.44))
            statTile(value: "\(appModel.recentPRs.count)", label: "Top Movers", tint: Color(red: 0.43, green: 0.58, blue: 0.95))
        }
    }

    private func statTile(value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(tint)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dayRow(_ day: WorkoutDay) -> some View {
        HStack(spacing: 12) {
            iconBadge(systemName: "flame.fill", tint: Color(red: 0.97, green: 0.52, blue: 0.28))

            VStack(alignment: .leading, spacing: 4) {
                Text(day.title)
                    .font(.headline)

                Text("\(day.focus) • \(day.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func prRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            iconBadge(systemName: "trophy.fill", tint: exercise.category.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.headline)

                Text(exercise.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(exercise.estimatedOneRepMax.formattedWeight) lb")
                    .font(.headline)
                    .foregroundStyle(exercise.category.color)

                Text(exercise.lastPerformanceSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func iconBadge(systemName: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tint.opacity(0.16))

            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
        }
        .frame(width: 34, height: 34)
    }
}

#Preview {
    HomeView()
        .environment(AppModel())
}
