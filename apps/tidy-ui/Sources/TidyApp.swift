import SwiftUI

@main
struct TidyApp: App {
    @StateObject private var model = TidyModel()

    var body: some Scene {
        WindowGroup("Tidy") {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 820, minHeight: 480)
        }
        .defaultSize(width: 1000, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Repos") {
                Button("Refresh") { Task { await model.refresh() } }
                    .keyboardShortcut("r")
            }
        }
    }
}
