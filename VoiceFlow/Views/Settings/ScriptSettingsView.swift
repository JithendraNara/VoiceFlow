import SwiftUI

struct ScriptSettingsView: View {
    @ObservedObject var viewModel: TeleprompterViewModel

    var body: some View {
        LiquidGlassCard("Script", icon: "doc.text.fill") {
            VStack(alignment: .leading, spacing: 16) {
                // Script Editor
                VStack(alignment: .leading, spacing: 6) {
                    TextEditor(text: $viewModel.scriptText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(.black.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    HStack {
                        Text("\(viewModel.wordCount) words")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("\(viewModel.scriptText.count) characters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Actions
                HStack(spacing: 12) {
                    Button {
                        viewModel.loadFromFile()
                    } label: {
                        Label("Load", systemImage: "folder")
                    }

                    Button {
                        viewModel.saveToFile()
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }

                    Button {
                        viewModel.pasteFromClipboard()
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                    }

                    Spacer()

                    Button {
                        viewModel.clearScript()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .padding()
    }
}
