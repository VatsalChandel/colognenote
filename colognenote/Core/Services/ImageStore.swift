import UIKit

/// Loads images from either an absolute URL (canonical bottle shots) or a private
/// Storage path (user uploads), with in-memory + on-disk caching and signed-URL
/// reuse. One shared instance; task 6.1.
@MainActor
final class ImageStore {
    static let shared = ImageStore()

    enum Source: Hashable, Sendable {
        case url(String)
        case asset(bucket: String, path: String)
    }

    private let memory = NSCache<NSString, UIImage>()
    private var signedURLs: [String: (url: URL, expires: Date)] = [:]
    private let storage = StorageService()
    private let session: URLSession

    init() {
        memory.countLimit = 250
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 16 << 20, diskCapacity: 256 << 20)
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
    }

    func image(for source: Source) async -> UIImage? {
        let key = cacheKey(source) as NSString
        if let hit = memory.object(forKey: key) { return hit }
        guard
            let url = await resolve(source),
            let (data, response) = try? await session.data(from: url),
            ((response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } ?? true),
            let image = UIImage(data: data)
        else { return nil }
        memory.setObject(image, forKey: key)
        return image
    }

    private func resolve(_ source: Source) async -> URL? {
        switch source {
        case .url(let string):
            return URL(string: string)
        case .asset(let bucket, let path):
            let key = "\(bucket)/\(path)"
            if let entry = signedURLs[key], entry.expires > Date() { return entry.url }
            guard
                let bucketCase = StorageService.Bucket(rawValue: bucket),
                let url = try? await storage.signedURL(for: path, in: bucketCase, expiresIn: 3600)
            else { return nil }
            signedURLs[key] = (url, Date().addingTimeInterval(3000))   // refresh a little early
            return url
        }
    }

    private func cacheKey(_ source: Source) -> String {
        switch source {
        case .url(let s):                 "url:\(s)"
        case .asset(let bucket, let path): "asset:\(bucket)/\(path)"
        }
    }
}
