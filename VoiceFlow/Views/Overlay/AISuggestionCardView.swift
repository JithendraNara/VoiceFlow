import SwiftUI

struct AISuggestionCardView: View {
    let suggestion: String
    let onAccept: () -> Void
    let onDismiss: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Suggested Response", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(.yellow)

                Spacer()

                Text("⌥A Accept  ⌥D Dismiss")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Suggestion text
            Text(suggestion)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineSpacing(4)

            // Confidence indicator
            HStack {
                Text("Confidence")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("85%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 4)
                        .clipShape(Capsule())

                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * 0.85, height: 4)
                        .clipShape(Capsule())
                }
            }
            .frame(height: 4)

            // Action buttons
            HStack(spacing: 16) {
                Button {
                    onAccept()
                } label: {
                    Label("Accept", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button {
                    onDismiss()
                } label: {
                    Label("Dismiss", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.3)) {
                appear = true
            }
        }
    }
}

struct FollowUpPromptsView: View {
    let prompts: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Follow-up Questions")
                .font(.caption)
                .foregroundStyle(.cyan)
                .padding(.horizontal, 32)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(prompts, id: \.self) { prompt in
                        Button {
                            onSelect(prompt)
                        } label: {
                            Text(prompt)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.cyan)
                    }
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        AISuggestionCardView(
            suggestion: "In my previous role at Company, I led a team of 5 engineers on an ML pipeline that reduced latency by 40%. The key challenge was balancing accuracy with performance.",
            onAccept: {},
            onDismiss: {}
        )
    }
    .frame(width: 800, height: 600)
    .background(Color.black)
}
