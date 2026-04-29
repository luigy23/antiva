import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    var onComplete: () -> Void

    private let steps: [(icon: String, titleKey: String, descKey: String)] = [
        ("menubar.arrow.up.rectangle", "onboarding_step1_title", "onboarding_step1_desc"),
        ("plus.circle", "onboarding_step2_title", "onboarding_step2_desc"),
        ("macwindow.on.rectangle", "onboarding_step3_title", "onboarding_step3_desc"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            Image(systemName: steps[currentStep].icon)
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .frame(height: 60)
                .padding(.bottom, 24)
                .id(currentStep)
                .transition(.opacity)

            // Title
            Text(NSLocalizedString(steps[currentStep].titleKey, comment: ""))
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
                .id("title-\(currentStep)")
                .transition(.opacity)

            // Description
            Text(NSLocalizedString(steps[currentStep].descKey, comment: ""))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 320)
                .padding(.bottom, 32)
                .id("desc-\(currentStep)")
                .transition(.opacity)

            Spacer()

            // Dots
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 24)

            // Button
            Button {
                if currentStep < steps.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                } else {
                    onComplete()
                }
            } label: {
                Text(currentStep < steps.count - 1
                     ? String(localized: "next")
                     : String(localized: "get_started"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 40)

            // Skip
            if currentStep < steps.count - 1 {
                Button(String(localized: "skip")) {
                    onComplete()
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
                .padding(.top, 10)
            }

            Spacer().frame(height: 20)
        }
        .frame(width: 420, height: 380)
        .background(.ultraThinMaterial)
        .preferredColorScheme(.light)
    }
}
