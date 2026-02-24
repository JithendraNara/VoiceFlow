import SwiftUI

struct StatusIndicator: View {
    enum Status {
        case idle
        case recording
        case processing
        case error

        var color: Color {
            switch self {
            case .idle: return .gray
            case .recording: return .green
            case .processing: return .blue
            case .error: return .red
            }
        }

        var icon: String {
            switch self {
            case .idle: return "circle"
            case .recording: return "record.circle"
            case .processing: return "waveform"
            case .error: return "exclamationmark.circle"
            }
        }

        var text: String {
            switch self {
            case .idle: return "Ready"
            case .recording: return "Recording"
            case .processing: return "Processing"
            case .error: return "Error"
            }
        }
    }

    let status: Status
    var showAnimation: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.caption)
                .foregroundStyle(status.color)
                .overlay {
                    if showAnimation && status == .recording {
                        Circle()
                            .stroke(status.color.opacity(0.5), lineWidth: 2)
                            .scaleEffect(1.5)
                            .opacity(0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: status)
                    }
                }

            Text(status.text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct StatusBarView: View {
    let isListening: Bool
    let isScrolling: Bool
    let aiProvider: String

    var body: some View {
        HStack(spacing: 16) {
            StatusIndicator(status: isListening ? .recording : .idle)

            Divider()
                .frame(height: 12)

            StatusIndicator(status: isScrolling ? .processing : .idle, showAnimation: false)

            Divider()
                .frame(height: 12)

            HStack(spacing: 4) {
                Image(systemName: "brain")
                    .font(.caption2)
                Text(aiProvider)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusIndicator(status: .idle)
        StatusIndicator(status: .recording)
        StatusIndicator(status: .processing)
        StatusIndicator(status: .error)

        StatusBarView(isListening: true, isScrolling: true, aiProvider: "gpt-5.2")
    }
    .padding()
}
