import SwiftUI

/// Loads a bottle / avatar image from a URL string, with a graceful placeholder while
/// loading and on failure. A fuller caching layer lands in Milestone 6 (task 6.1);
/// this is the shared entry point everything will call.
struct RemoteImage: View {
    var urlString: String?
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: contentMode)
                    case .failure:
                        placeholder
                    case .empty:
                        ZStack { placeholder; ProgressView() }
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipped()
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
}

#Preview {
    HStack {
        RemoteImage(urlString: nil)
            .frame(width: 120, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        RemoteImage(urlString: "https://invalid.example/none.jpg")
            .frame(width: 120, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
    }
    .padding()
}
