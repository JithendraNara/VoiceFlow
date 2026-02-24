import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TeleprompterViewModel
    @StateObject private var speechVM = SpeechRecognitionViewModel()

    @State private var selectedTab: SettingsTab = .voice

    enum SettingsTab: String, CaseIterable {
        case voice = "Voice"
        case script = "Script"
        case ai = "AI"
        case display = "Display"

        var icon: String {
            switch self {
            case .voice: return "mic.fill"
            case .script: return "doc.text.fill"
            case .ai: return "brain.fill"
            case .display: return "display"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("VoiceFlow", systemImage: "waveform.circle.fill")
                    .font(.headline)

                Spacer()

                Button {
                    viewModel.toggleOverlay()
                } label: {
                    Label("Show Overlay", systemImage: "rectangle.on.rectangle")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)

            // Tab Bar
            HStack(spacing: 4) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                            Text(tab.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTab == tab ? .ultraThinMaterial : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Content
            ScrollView {
                switch selectedTab {
                case .voice:
                    VoiceSettingsView(viewModel: viewModel, speechVM: speechVM)
                case .script:
                    ScriptSettingsView(viewModel: viewModel)
                case .ai:
                    AISettingsView(viewModel: viewModel)
                case .display:
                    DisplaySettingsView(viewModel: viewModel)
                }
            }

            // Status Bar
            StatusBarView(
                isListening: speechVM.isListening,
                isScrolling: viewModel.isScrolling,
                aiProvider: viewModel.aiEnabled ? viewModel.selectedModel : "Disabled"
            )
        }
        .frame(width: 420, height: 580)
    }
}

#Preview {
    SettingsView(viewModel: TeleprompterViewModel())
}
