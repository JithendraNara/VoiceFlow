import SwiftUI
import Combine

class TeleprompterViewModel: ObservableObject {
    @Published var scriptText: String = "Welcome to Teleprompter\n\nEnter your script here and it will scroll automatically.\n\nUse the controls to adjust speed and flow.\n\nPerfect for presentations, lectures, and video recordings."
    @Published var isScrolling: Bool = false
    @Published var scrollSpeed: Double = 1.0
    @Published var fontSize: CGFloat = 32
    @Published var fontColor: Color = .white
    @Published var backgroundOpacity: Double = 0.7
    @Published var scrollOffset: CGFloat = 0

    private var scrollTimer: Timer?
    let minSpeed: Double = 0.2
    let maxSpeed: Double = 5.0

    var fontSizeRange: ClosedRange<CGFloat> { 16...72 }
    var speedRange: ClosedRange<Double> { 0.2...5.0 }

    func toggleScrolling() {
        isScrolling.toggle()
        if isScrolling {
            startScrolling()
        } else {
            stopScrolling()
        }
    }

    func resetScroll() {
        scrollOffset = 0
        isScrolling = false
        stopScrolling()
    }

    func jumpBack() {
        scrollOffset = max(0, scrollOffset - 100)
    }

    func increaseSpeed() {
        scrollSpeed = min(maxSpeed, scrollSpeed + 0.3)
    }

    func decreaseSpeed() {
        scrollSpeed = max(minSpeed, scrollSpeed - 0.3)
    }

    private func startScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.scrollOffset += self.scrollSpeed
        }
    }

    private func stopScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }

    func loadFromFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                scriptText = try String(contentsOf: url, encoding: .utf8)
            } catch {
                print("Error loading file: \(error)")
            }
        }
    }

    func saveToFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "script.txt"

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try scriptText.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                print("Error saving file: \(error)")
            }
        }
    }

    deinit {
        scrollTimer?.invalidate()
    }
}
