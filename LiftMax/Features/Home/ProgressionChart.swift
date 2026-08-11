import SwiftUI
import Charts

struct ProgressionChart: View {
    let sets: [ExerciseSet]
    let tint: Color
    var highlightedSetIDs: Set<ExerciseSet.ID> = []
    var emptyMessageColor: Color = .secondary

    private var orderedSets: [ExerciseSet] {
        sets.sorted(by: { $0.completedAt < $1.completedAt })
    }

    var body: some View {
        if orderedSets.count < 2 {
            Text("Log at least two working sets to see your progression trend.")
                .font(.subheadline)
                .foregroundStyle(emptyMessageColor)
        } else {
            Chart(orderedSets) { set in
                LineMark(
                    x: .value("Date", set.completedAt),
                    y: .value("Est. 1RM", set.estimatedOneRepMax)
                )
                .foregroundStyle(tint)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", set.completedAt),
                    y: .value("Est. 1RM", set.estimatedOneRepMax)
                )
                .foregroundStyle(highlightedSetIDs.contains(set.id) ? liveColor : tint.opacity(0.7))
                .symbolSize(highlightedSetIDs.contains(set.id) ? 130 : 40)
            }
            .frame(height: 180)
        }
    }

    private var liveColor: Color {
        Color(red: 0.99, green: 0.58, blue: 0.27)
    }
}
