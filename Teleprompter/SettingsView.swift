import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TeleprompterViewModel
    var showWindow: () -> Void
    var quitApp: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "text.alignleft")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Teleprompter")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Script Input
            VStack(alignment: .leading, spacing: 8) {
                Text("SCRIPT")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(1)

                TextEditor(text: $viewModel.scriptText)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(height: 180)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding()

            // File Controls
            HStack(spacing: 12) {
                Button(action: viewModel.loadFromFile) {
                    Label("Open", systemImage: "folder")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)

                Button(action: viewModel.saveToFile) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding(.horizontal)

            Divider()
                .padding(.vertical, 8)

            // Controls
            VStack(spacing: 16) {
                // Font Size
                HStack {
                    Text("Font Size")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Slider(value: $viewModel.fontSize, in: viewModel.fontSizeRange)
                        .frame(width: 150)
                    Text("\(Int(viewModel.fontSize))pt")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .trailing)
                }

                // Scroll Speed
                HStack {
                    Text("Speed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Slider(value: $viewModel.scrollSpeed, in: viewModel.speedRange)
                        .frame(width: 150)
                    Text(String(format: "%.1f", viewModel.scrollSpeed))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .trailing)
                }

                // Background Opacity
                HStack {
                    Text("Dimming")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Slider(value: $viewModel.backgroundOpacity, in: 0...1)
                        .frame(width: 150)
                    Text("\(Int(viewModel.backgroundOpacity * 100))%")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .trailing)
                }
            }
            .padding(.horizontal)

            Divider()
                .padding(.vertical, 8)

            // Action Buttons
            VStack(spacing: 12) {
                Button(action: showWindow) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Show Teleprompter")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                HStack(spacing: 12) {
                    Button(action: viewModel.toggleScrolling) {
                        Label(
                            viewModel.isScrolling ? "Pause" : "Play",
                            systemImage: viewModel.isScrolling ? "pause.fill" : "play.fill"
                        )
                    }
                    .buttonStyle(.bordered)

                    Button(action: viewModel.resetScroll) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)

                    Button(action: viewModel.jumpBack) {
                        Label("Back 5s", systemImage: "gobackward.5")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()

            // Keyboard Shortcuts Info
            VStack(spacing: 4) {
                Text("Keyboard Shortcuts")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    ShortcutHint(keys: "⌥P", action: "Play/Pause")
                    ShortcutHint(keys: "⌥R", action: "Reset")
                    ShortcutHint(keys: "⌥J", action: "-5s")
                }
                .font(.system(size: 10))
            }
            .padding(.bottom, 8)

            Divider()

            // Quit Button
            Button(action: quitApp) {
                Label("Quit Teleprompter", systemImage: "power")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .padding()
        }
        .frame(width: 400, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct ShortcutHint: View {
    let keys: String
    let action: String

    var body: some View {
        HStack(spacing: 4) {
            Text(keys)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
            Text(action)
                .foregroundColor(.secondary)
        }
    }
}
