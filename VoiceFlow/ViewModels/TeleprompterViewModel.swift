import SwiftUI
import Combine
import AppKit

@MainActor
class TeleprompterViewModel: ObservableObject {
    // MARK: - Script
    @Published var scriptText: String = ""
    @Published var wordCount: Int = 0

    // MARK: - Playback
    @Published var isScrolling: Bool = false
    @Published var scrollSpeed: Double = 1.0
    @Published var scrollOffset: CGFloat = 0

    // MARK: - Display
    @Published var fontSize: CGFloat = 48
    @Published var fontColor: Color = .white
    @Published var backgroundOpacity: Double = 0.7
    @Published var isMirrorMode: Bool = false
    @Published var showGuideLine: Bool = true

    // MARK: - Speech Recognition
    @Published var isListening: Bool = false
    @Published var transcribedText: String = ""
    @Published var speechMode: SpeechMode = .onDevice

    // MARK: - AI
    @Published var selectedProvider: AIProviderType = .openAI
    @Published var selectedModel: String = "gpt-5.2"
    @Published var apiKey: String = ""
    @Published var aiMode: AIMode = .interviewCoach
    @Published var aiStyle: AIResponseStyle = .professional
    @Published var maxResponseLength: Int = 100
    @Published var aiEnabled: Bool = false
    @Published var showFollowUps: Bool = true
    @Published var highlightKeywords: Bool = true

    // MARK: - AI Suggestions
    @Published var currentSuggestion: String?
    @Published var followUpPrompts: [String] = []
    @Published var confidenceScore: Double = 0

    // MARK: - State
    @Published var isOverlayVisible: Bool = false
    @Published var errorMessage: String?
    @Published var selectedMicrophone: String = "Built-in Microphone"

    // MARK: - Constants
    let minSpeed: Double = 0.2
    let maxSpeed: Double = 5.0
    let minFontSize: CGFloat = 24
    let maxFontSize: CGFloat = 96

    // MARK: - Private
    private var scrollTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSavedState()
        setupBindings()
    }

    private func setupBindings() {
        $scriptText
            .map { $0.split(separator: " ").count }
            .assign(to: &$wordCount)
    }

    // MARK: - Playback Controls
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
            Task { @MainActor in
                guard let self = self else { return }
                self.scrollOffset += self.scrollSpeed
            }
        }
    }

    private func stopScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }

    // MARK: - Script Management
    func loadFromFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, .rtf, .markdown]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                scriptText = try String(contentsOf: url, encoding: .utf8)
                saveScript()
            } catch {
                errorMessage = "Failed to load file: \(error.localizedDescription)"
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
                errorMessage = "Failed to save file: \(error.localizedDescription)"
            }
        }
    }

    func clearScript() {
        scriptText = ""
        saveScript()
    }

    func pasteFromClipboard() {
        if let clipboard = NSPasteboard.general.string(forType: .string) {
            scriptText = clipboard
            saveScript()
        }
    }

    // MARK: - AI Methods
    func acceptAISuggestion() {
        guard let suggestion = currentSuggestion else { return }
        scriptText += "\n\n" + suggestion
        currentSuggestion = nil
        followUpPrompts = []
    }

    func dismissAISuggestion() {
        currentSuggestion = nil
        followUpPrompts = []
    }

    func selectFollowUp(_ prompt: String) {
        scriptText += "\n\n" + prompt
    }

    // MARK: - Persistence
    private func loadSavedState() {
        scriptText = UserDefaults.standard.string(forKey: "scriptText") ?? ""
        scrollSpeed = UserDefaults.standard.double(forKey: "scrollSpeed")
        if scrollSpeed == 0 { scrollSpeed = 1.0 }
        fontSize = CGFloat(UserDefaults.standard.double(forKey: "fontSize"))
        if fontSize == 0 { fontSize = 48 }
        backgroundOpacity = UserDefaults.standard.double(forKey: "backgroundOpacity")
        if backgroundOpacity == 0 { backgroundOpacity = 0.7 }
        isMirrorMode = UserDefaults.standard.bool(forKey: "isMirrorMode")
        showGuideLine = UserDefaults.standard.bool(forKey: "showGuideLine")
        if !UserDefaults.standard.bool(forKey: "showGuideLineSet") {
            showGuideLine = true
        }
        aiEnabled = UserDefaults.standard.bool(forKey: "aiEnabled")
    }

    private func saveScript() {
        UserDefaults.standard.set(scriptText, forKey: "scriptText")
    }

    func saveSettings() {
        UserDefaults.standard.set(scrollSpeed, forKey: "scrollSpeed")
        UserDefaults.standard.set(Double(fontSize), forKey: "fontSize")
        UserDefaults.standard.set(backgroundOpacity, forKey: "backgroundOpacity")
        UserDefaults.standard.set(isMirrorMode, forKey: "isMirrorMode")
        UserDefaults.standard.set(showGuideLine, forKey: "showGuideLine")
        UserDefaults.standard.set(true, forKey: "showGuideLineSet")
        UserDefaults.standard.set(aiEnabled, forKey: "aiEnabled")
    }

    // MARK: - Overlay
    func toggleOverlay() {
        isOverlayVisible.toggle()
    }

    deinit {
        scrollTimer?.invalidate()
    }
}

enum SpeechMode: String, CaseIterable, Identifiable {
    case onDevice = "On-Device"
    case cloud = "Cloud (Whisper)"

    var id: String { rawValue }
}
