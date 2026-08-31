import SwiftUI

/// Displays a bottle / avatar image, trying each source in order, with a graceful
/// placeholder while loading and on failure. Caching + private-bucket signed URLs
/// are handled by ``ImageStore`` (task 6.1).
struct RemoteImage: View {
    private let sources: [ImageStore.Source]
    var contentMode: ContentMode = .fill

    /// A canonical, absolute image URL.
    init(url: String?, contentMode: ContentMode = .fill) {
        self.sources = Self.urlSources(url)
        self.contentMode = contentMode
    }

    /// A user's bottle photo (private `bottle-photos` path or absolute URL),
    /// falling back to the canonical bottle shot.
    init(bottlePhoto path: String?, fallbackURL: String?, contentMode: ContentMode = .fill) {
        var s = Self.assetOrURLSources(path, bucket: "bottle-photos")
        s.append(contentsOf: Self.urlSources(fallbackURL))
        self.sources = s
        self.contentMode = contentMode
    }

    /// A user's avatar (private `avatars` path or absolute URL).
    init(avatar path: String?, contentMode: ContentMode = .fill) {
        self.sources = Self.assetOrURLSources(path, bucket: "avatars")
        self.contentMode = contentMode
    }

    @State private var image: UIImage?
    @State private var finishedLoading = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().aspectRatio(contentMode: contentMode)
            } else {
                placeholder.overlay {
                    if !finishedLoading && !sources.isEmpty { ProgressView() }
                }
            }
        }
        .clipped()
        .task(id: sources) { await load() }
    }

    private func load() async {
        image = nil
        finishedLoading = false
        for source in sources {
            if let loaded = await ImageStore.shared.image(for: source) {
                image = loaded
                finishedLoading = true
                return
            }
        }
        finishedLoading = true
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Theme.Palette.secondaryBackground)
            .overlay(
                Image(systemName: "drop.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.Palette.tertiaryText)
            )
    }

    // MARK: Source building

    private static func urlSources(_ value: String?) -> [ImageStore.Source] {
        guard let value, !value.isEmpty else { return [] }
        return [.url(value)]
    }

    private static func assetOrURLSources(_ value: String?, bucket: String) -> [ImageStore.Source] {
        guard let value, !value.isEmpty else { return [] }
        if value.hasPrefix("http") { return [.url(value)] }
        return [.asset(bucket: bucket, path: value)]
    }
}

#Preview {
    HStack {
        RemoteImage(url: nil)
            .frame(width: 120, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        RemoteImage(url: "https://invalid.example/none.jpg")
            .frame(width: 120, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
    }
    .padding()
}
