import SwiftUI

struct VoiceSettingsView: View {
    @ObservedObject var viewModel: TeleprompterViewModel
    @ObservedObject var speechVM: SpeechRecognitionViewModel

    var body: some View {
        LiquidGlassCard("Speech Input", icon: "mic.fill") {
            VStack(alignment: .leading, spacing: 16) {
                // Microphone Selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Microphone")
                        .font(.subheadline.weight(.medium))

                    Picker("Microphone", selection: $viewModel.selectedMicrophone) {
                        ForEach(speechVM.availableMicrophones, id: \.self) { mic in
                            Text(mic).tag(mic)
                        }
                    }
                    .labelsHidden()
                }

                // Speech Mode
                VStack(alignment: .leading, spacing: 6) {
                    Text("Speech Recognition")
                        .font(.subheadline.weight(.medium))

                    Picker("Mode", selection: $viewModel.speechMode) {
                        ForEach(SpeechMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Divider()

                // Live Transcription
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Transcription")
                        .font(.subheadline.weight(.medium))

                    ScrollView {
                        Text(speechVM.currentTranscription.isEmpty ?
                             "Transcription will appear here..." :
                             speechVM.currentTranscription)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(speechVM.currentTranscription.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 80)
                    .padding(8)
                    .background(.black.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Controls
                HStack(spacing: 12) {
                    Button {
                        if speechVM.isListening {
                            speechVM.stopListening()
                        } else {
                            speechVM.startListening()
                        }
                    } label: {
                        Label(speechVM.isListening ? "Stop" : "Start",
                              systemImage: speechVM.isListening ? "stop.fill" : "mic.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(speechVM.isListening ? .red : .blue)

                    Button {
                        speechVM.clearTranscription()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .disabled(speechVM.currentTranscription.isEmpty)
                }

                // Permission Status
                if !speechVM.isPermissionGranted {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Speech recognition permission required")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
    }
}
