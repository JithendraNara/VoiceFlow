import SwiftUI

struct TeleprompterOverlayView: View {
    @ObservedObject var viewModel: TeleprompterViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Dimmed background
                Rectangle()
                    .fill(Color.black.opacity(viewModel.backgroundOpacity))

                // Main content
                VStack(spacing: 0) {
                    // Top margin for camera
                    Spacer()
                        .frame(height: geometry.size.height * 0.25)

                    // Script text with scroll
                    ScriptTextView(viewModel: viewModel, containerHeight: geometry.size.height)

                    Spacer()

                    // AI Suggestion Area
                    if let suggestion = viewModel.currentSuggestion {
                        AISuggestionCardView(suggestion: suggestion) {
                            viewModel.acceptAISuggestion()
                        } onDismiss: {
                            viewModel.dismissAISuggestion()
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Follow-up prompts
                    if viewModel.showFollowUps && !viewModel.followUpPrompts.isEmpty {
                        FollowUpPromptsView(prompts: viewModel.followUpPrompts) { prompt in
                            viewModel.selectFollowUp(prompt)
                        }
                    }

                    // Center guide line
                    if viewModel.showGuideLine {
                        CenterGuideLine()
                    }
                }
                .padding(.horizontal, 48)

                // Mirror transform if enabled
                .scaleEffect(x: viewModel.isMirrorMode ? -1 : 1, y: 1)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct CenterGuideLine: View {
    var body: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.4),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .blur(radius: 1)
        }
    }
}

#Preview {
    TeleprompterOverlayView(viewModel: TeleprompterViewModel())
        .frame(width: 800, height: 600)
}
