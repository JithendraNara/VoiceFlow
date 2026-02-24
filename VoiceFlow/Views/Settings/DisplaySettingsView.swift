import SwiftUI

struct DisplaySettingsView: View {
    @ObservedObject var viewModel: TeleprompterViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Playback Controls
            LiquidGlassCard("Playback", icon: "playpause.fill") {
                VStack(spacing: 16) {
                    // Speed
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Speed")
                            Spacer()
                            Text(String(format: "%.1fx", viewModel.scrollSpeed))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $viewModel.scrollSpeed,
                               in: viewModel.minSpeed...viewModel.maxSpeed,
                               step: 0.1)
                    }

                    // Control Buttons
                    HStack(spacing: 12) {
                        Button {
                            viewModel.resetScroll()
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                        }

                        Button {
                            viewModel.toggleScrolling()
                        } label: {
                            Label(viewModel.isScrolling ? "Pause" : "Play",
                                  systemImage: viewModel.isScrolling ? "pause.fill" : "play.fill")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            viewModel.jumpBack()
                        } label: {
                            Label("Back", systemImage: "gobackward")
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Display Settings
            LiquidGlassCard("Display", icon: "display") {
                VStack(spacing: 16) {
                    // Font Size
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Font Size")
                            Spacer()
                            Text("\(Int(viewModel.fontSize))pt")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $viewModel.fontSize,
                               in: viewModel.minFontSize...viewModel.maxFontSize,
                               step: 2)
                    }

                    // Background Opacity
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Background Opacity")
                            Spacer()
                            Text("\(Int(viewModel.backgroundOpacity * 100))%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $viewModel.backgroundOpacity, in: 0.3...1.0, step: 0.05)
                    }

                    Divider()

                    // Toggles
                    GlassToggle(title: "Mirror Mode", isOn: $viewModel.isMirrorMode)
                    GlassToggle(title: "Show Guide Line", isOn: $viewModel.showGuideLine)
                }
            }
            .padding(.horizontal)

            // Keyboard Shortcuts
            LiquidGlassCard("Keyboard Shortcuts", icon: "keyboard") {
                VStack(alignment: .leading, spacing: 8) {
                    ShortcutRow(keys: "⌥P", action: "Play/Pause")
                    ShortcutRow(keys: "⌥R", action: "Reset to top")
                    ShortcutRow(keys: "⌥J", action: "Jump back")
                    ShortcutRow(keys: "⌥H", action: "Hide/Show overlay")
                    ShortcutRow(keys: "⌥M", action: "Mirror toggle")
                    ShortcutRow(keys: "⌥A", action: "Accept AI suggestion")
                    ShortcutRow(keys: "⌥D", action: "Dismiss AI suggestion")
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct ShortcutRow: View {
    let keys: String
    let action: String

    var body: some View {
        HStack {
            Text(keys)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(action)
                .font(.caption)

            Spacer()
        }
    }
}
