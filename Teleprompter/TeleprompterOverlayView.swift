import SwiftUI

struct TeleprompterOverlayView: View {
    @ObservedObject var viewModel: TeleprompterViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Dimmed background
                Rectangle()
                    .fill(Color.black.opacity(viewModel.backgroundOpacity))

                // Scrolling text
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.3)

                    Text(viewModel.scriptText)
                        .font(.system(size: viewModel.fontSize, weight: .medium, design: .rounded))
                        .foregroundColor(viewModel.fontColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .offset(y: -viewModel.scrollOffset)
                        .frame(maxWidth: geometry.size.width * 0.8)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .clipped()

                // Center guide line
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0),
                                Color.orange.opacity(0.6),
                                Color.orange.opacity(0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .offset(y: -geometry.size.height * 0.15)
                    .blur(radius: 2)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
