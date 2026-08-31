//
//  colognenoteApp.swift
//  colognenote
//
//  Created by Vatsal Chandel on 8/29/26.
//

import SwiftUI

@main
struct colognenoteApp: App {
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .task { await session.start() }
                .task { await ConnectivityProbe.run() }
        }
    }
}
