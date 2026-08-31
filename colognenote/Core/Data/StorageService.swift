import Foundation
import Supabase

/// Uploads to and reads from the private Storage buckets. Files live under a
/// top-level folder named with the owner's UID, which is what the bucket RLS
/// policies check (`(storage.foldername(name))[1] = auth.uid()`).
struct StorageService {

    enum Bucket: String {
        case avatars
        case bottlePhotos = "bottle-photos"
    }

    /// Uploads image data and returns the storage path (e.g. `<uid>/avatar-169….jpg`).
    /// Store this path in the DB, not a URL — the bucket is private.
    func upload(_ data: Data, to bucket: Bucket, filename: String) async throws -> String {
        let uid = try currentUserID().uuidString.lowercased()
        let path = "\(uid)/\(filename)"
        try await supabase.storage
            .from(bucket.rawValue)
            .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
        return path
    }

    /// A time-limited URL for displaying a private object.
    func signedURL(for path: String, in bucket: Bucket, expiresIn: Int = 3600) async throws -> URL {
        try await supabase.storage
            .from(bucket.rawValue)
            .createSignedURL(path: path, expiresIn: expiresIn)
    }
}
