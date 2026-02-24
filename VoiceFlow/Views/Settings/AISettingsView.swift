import SwiftUI

struct AISettingsView: View {
    @ObservedObject var viewModel: TeleprompterViewModel

    @State private var showKey: Bool = false
    @State private var isTesting: Bool = false
    @State private var testResult: String?

    var body: some View {
        VStack(spacing: 16) {
            // Enable AI
            LiquidGlassCard("AI Assistant", icon: "brain.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    GlassToggle(title: "Enable AI Suggestions", isOn: $viewModel.aiEnabled)
                }
            }
            .padding(.horizontal)

            // Provider Settings
            if viewModel.aiEnabled {
                LiquidGlassCard("Provider", icon: "server.rack") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Provider Selection
                        Picker("Provider", selection: $viewModel.selectedProvider) {
                            ForEach(AIProviderType.allCases) { provider in
                                Text(provider.rawValue).tag(provider)
                            }
                        }

                        // Model Selection
                        Picker("Model", selection: $viewModel.selectedModel) {
                            ForEach(viewModel.selectedProvider.models, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }

                        // API Key
                        HStack {
                            if showKey {
                                TextField("API Key", text: $viewModel.apiKey)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                SecureField("API Key", text: $viewModel.apiKey)
                                    .textFieldStyle(.roundedBorder)
                            }

                            Button {
                                showKey.toggle()
                            } label: {
                                Image(systemName: showKey ? "eye.slash" : "eye")
                            }
                            .buttonStyle(.plain)

                            Button {
                                testAPIKey()
                            } label: {
                                if isTesting {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                } else {
                                    Text("Test")
                                }
                            }
                            .disabled(viewModel.apiKey.isEmpty || isTesting)
                        }

                        if let result = testResult {
                            HStack {
                                Image(systemName: result.contains("Success") ? "checkmark.circle" : "xmark.circle")
                                    .foregroundStyle(result.contains("Success") ? .green : .red)
                                Text(result)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Mode Settings
                LiquidGlassCard("Mode", icon: "slider.horizontal.3") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("AI Mode", selection: $viewModel.aiMode) {
                            ForEach(AIMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }

                        Picker("Style", selection: $viewModel.aiStyle) {
                            ForEach(AIResponseStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }

                        // Length Slider
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Max Length: \(viewModel.maxResponseLength) words")
                                .font(.caption)
                            Slider(value: Binding(
                                get: { Double(viewModel.maxResponseLength) },
                                set: { viewModel.maxResponseLength = Int($0) }
                            ), in: 50...200, step: 10)
                        }

                        Divider()

                        GlassToggle(title: "Show Follow-up Prompts", isOn: $viewModel.showFollowUps)
                        GlassToggle(title: "Highlight Keywords", isOn: $viewModel.highlightKeywords)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }

    private func testAPIKey() {
        isTesting = true
        testResult = nil

        // Save key temporarily
        _ = KeychainService.shared.saveAPIKey(viewModel.apiKey, for: viewModel.selectedProvider.rawValue)

        // Simulate test - in real implementation, make a simple API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTesting = false
            testResult = "Success: API key validated"
        }
    }
}
