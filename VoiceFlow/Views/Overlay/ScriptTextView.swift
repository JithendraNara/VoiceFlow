import SwiftUI

struct ScriptTextView: View {
    @ObservedObject var viewModel: TeleprompterViewModel
    let containerHeight: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack {
                        // Top padding
                        Spacer()
                            .frame(height: containerHeight * 0.3)

                        Text(viewModel.scriptText)
                            .font(.system(size: viewModel.fontSize, weight: .medium, design: .rounded))
                            .foregroundColor(viewModel.fontColor)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .frame(maxWidth: geometry.size.width * 0.8)
                            .offset(y: -viewModel.scrollOffset)
                            .id("script")

                        // Bottom padding
                        Spacer()
                            .frame(height: containerHeight * 0.5)
                    }
                }
                .scrollDisabled(true)
                .onChange(of: viewModel.scrollOffset) { _, _ in
                    // Force update
                }
            }
        }
        .clipped()
    }
}

#Preview {
    ScriptTextView(viewModel: TeleprompterViewModel(), containerHeight: 600)
        .frame(width: 800, height: 600)
}
