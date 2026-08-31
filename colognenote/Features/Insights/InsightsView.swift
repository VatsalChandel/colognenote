import SwiftUI
import Charts

/// The payoff screen — why logging is worth it (screen spec #7). All **[PRIVATE]**.
struct InsightsView: View {
    @State private var model = InsightsViewModel()

    var body: some View {
        Group {
            switch model.state {
            case .loading:
                LoadingView(label: "Crunching the numbers…")
            case .failed(let message):
                ErrorView(message: message) { Task { await model.load() } }
            case .coldStart:
                EmptyStateView(
                    systemImage: "chart.bar",
                    title: "Not enough data yet",
                    message: "Add a few bottles and log some wears — your most-worn, best performers and cost-per-wear all show up here."
                )
            case .ready:
                content
            }
        }
        .navigationTitle("Insights")
        .navigationDestination(for: UUID.self) { BottleDetailView(itemID: $0) }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                header

                if !model.mostWorn.isEmpty {
                    InsightCard(title: "Most worn", systemImage: "flame") {
                        ForEach(model.mostWorn) { item in
                            InsightRow(item: item, trailing: pluralized(item.wearCount, "wear"))
                        }
                    }
                }

                if !model.bestPerformers.isEmpty {
                    InsightCard(title: "Best performers", systemImage: "hands.clap") {
                        ForEach(model.bestPerformers) { item in
                            InsightRow(item: item, trailing: pluralized(item.complimentCount, "compliment"))
                        }
                    }
                }

                if !model.byCostPerWear.isEmpty {
                    InsightCard(title: "Cost per wear", systemImage: "dollarsign.circle") {
                        ForEach(model.byCostPerWear.prefix(6)) { item in
                            InsightRow(item: item, trailing: item.costPerWear.map {
                                $0.formatted(.currency(code: "USD"))
                            } ?? "—")
                        }
                    }
                }

                InsightCard(title: "Most neglected", systemImage: "moon.zzz") {
                    ForEach(model.mostNeglected) { item in
                        InsightRow(item: item, trailing: item.lastWorn.map { "last \($0)" } ?? "never worn")
                    }
                }

                if !model.accordCounts.isEmpty {
                    InsightCard(title: "Accord breakdown", systemImage: "chart.bar.xaxis") {
                        Chart(model.accordCounts) { entry in
                            BarMark(
                                x: .value("Bottles", entry.count),
                                y: .value("Family", entry.family)
                            )
                            .foregroundStyle(Theme.Palette.accent)
                            .annotation(position: .trailing) {
                                Text("\(entry.count)").font(.caption2).foregroundStyle(Theme.Palette.secondaryText)
                            }
                        }
                        .chartXAxis(.hidden)
                        .frame(height: CGFloat(model.accordCounts.count) * 28 + 12)
                    }
                }

                if !model.gapFamilies.isEmpty {
                    InsightCard(title: "Wardrobe gaps", systemImage: "square.dashed") {
                        Text("No bottles lean these ways:")
                            .font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                        FlexWrap(spacing: Theme.Spacing.xs) {
                            ForEach(model.gapFamilies, id: \.self) { family in
                                Text(family)
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, Theme.Spacing.sm)
                                    .padding(.vertical, 4)
                                    .background(Theme.Palette.secondaryBackground, in: Capsule())
                            }
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(model.value?.totalValue.formatted(.currency(code: "USD").precision(.fractionLength(0)))
                     ?? "—")
                    .font(Theme.Typography.display(28))
                Text("\(pluralized(model.value?.itemCount ?? model.items.count, "bottle")) · \(pluralized(model.totalWears, "wear")) logged")
                    .font(.caption).foregroundStyle(Theme.Palette.secondaryText)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InsightCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(Theme.Palette.cardBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }
}

private struct InsightRow: View {
    let item: InsightItem
    let trailing: String

    var body: some View {
        NavigationLink(value: item.id) {
            HStack(spacing: Theme.Spacing.md) {
                RemoteImage(urlString: item.imageURL)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.name).font(.subheadline.weight(.medium)).lineLimit(1)
                    if let house = item.house, !house.isEmpty {
                        Text(house).font(.caption).foregroundStyle(Theme.Palette.secondaryText).lineLimit(1)
                    }
                }
                Spacer()
                Text(trailing)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.Palette.secondaryText)
                Image(systemName: "chevron.right")
                    .font(.caption2).foregroundStyle(Theme.Palette.tertiaryText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack { InsightsView() }
}
