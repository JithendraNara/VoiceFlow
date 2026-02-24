import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TeleprompterViewModel
    @StateObject private var speechVM: SpeechRecognitionViewModel

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

    init(viewModel: TeleprompterViewModel) {
        self.viewModel = viewModel
        self._speechVM = StateObject(wrappedValue: SpeechRecognitionViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            tabBarView
            Divider()
            contentView
            StatusBarView(
                isListening: speechVM.isListening,
                isScrolling: viewModel.isScrolling,
                aiProvider: viewModel.aiEnabled ? viewModel.selectedModel : "Disabled"
            )
        }
        .frame(width: 420, height: 580)
    }

    private var headerView: some View {
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
    }

    private var tabBarView: some View {
        HStack(spacing: 4) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func tabButton(for tab: SettingsTab) -> some View {
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
            .background(selectedTab == tab ? Color(nsColor: .controlBackgroundColor).opacity(0.5) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
    }

    @ViewBuilder
    private var contentView: some View {
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
    }
}

#Preview {
    SettingsView(viewModel: TeleprompterViewModel())
        .frame(width: 420, height: 580)
}
